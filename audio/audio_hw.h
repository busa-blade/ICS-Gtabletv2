/*
 * Copyright (C) 2011 The Android Open Source Project
 * Copyright (C) 2011 Eduardo José Tagle <ejtagle@tutopia.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "audio_hw_primary"
#define LOG_NDEBUG 0

#include <errno.h>
#include <pthread.h>
#include <stdint.h>
#include <sys/time.h>
#include <stdlib.h>

#include <cutils/log.h>
#include <cutils/str_parms.h>
#include <cutils/properties.h>

#include <hardware/hardware.h>
#include <system/audio.h>
#include <hardware/audio.h>

#include <tinyalsa/asoundlib.h>
#include <audio_utils/resampler.h>
#include <audio_utils/echo_reference.h>
#include <hardware/audio_effect.h>
#include <audio_effects/effect_aec.h>

/* Mixer control names */
#define MIXER_PCM_PLAYBACK_VOLUME     		"PCM Playback Volume"

#define MIXER_HEADSET_PLAYBACK_VOLUME       "Headphone Playback Volume"
#define MIXER_SPEAKER_PLAYBACK_VOLUME       "Auxout Playback Volume"
#define MIXER_AUXOUT_ENABLE                 "Auxout Playback Switch"
#define MIXER_MIC_CAPTURE_VOLUME            "Mic1 Capture Volume" /*ok*/
#define MIXER_HEADSET_OUTENABLE             "Headphone Playback Switch"
#define MIXER_HEADSET_PLAYBACK_SWITCH       "Headphone Jack Switch"
#define MIXER_SPEAKER_PLAYBACK_SWITCH       "Int Spk Switch"
#define MIXER_MIC_CAPTURE_SWITCH            "Int Mic Switch"

#define MIXER_HPL_OUTMUX                    "Left Headphone Mux"
#define MIXER_HPR_OUTMUX                    "Right Headphone Mux"
#define MIXER_AUX_OUTMUX                    "AuxOut Mux"
#define MIXER_HP_ENABLE_DAC                 "HP Mix DAC2HP Playback Switch"
#define MIXER_SPK_ENABLE_DAC                "Speaker Mix DAC2SPK Playback Switch"

#define MIXER_HP_LEFT                       "HP Left Mix"
#define MIXER_HP_RIGHT                      "HP Right Mix"
#define MIXER_SPK                           "HPOut Mix"



/* ALSA card */
#define CARD_SMBA1002 0

/* ALSA ports for card0 */
#define PORT_MM    0 /* CODEC port */
#define PORT_VOICE 1 /* Bluetooth/3G port */
#define PORT_SPDIF 2 /* SPDIF (HDMI) port */

/* Minimum granularity - Arbitrary but small value */
#define CODEC_BASE_FRAME_COUNT 32

/* number of base blocks in a short period (low latency) */
#define SHORT_PERIOD_MULTIPLIER 16  /* 11 ms */
/* number of frames per short period (low latency) */
#define SHORT_PERIOD_SIZE (CODEC_BASE_FRAME_COUNT * SHORT_PERIOD_MULTIPLIER)
/* number of pseudo periods for low latency playback */
#define PLAYBACK_SHORT_PERIOD_COUNT 4

/* number of short periods in a long period (low power) */
#define LONG_PERIOD_MULTIPLIER 2  /*16*/ /* 341 ms */
/* number of frames per long period (low power) */
#define LONG_PERIOD_SIZE (SHORT_PERIOD_SIZE * LONG_PERIOD_MULTIPLIER)
/* number of periods for low power playback */
#define PLAYBACK_LONG_PERIOD_COUNT 2

/* number of periods for capture */
#define CAPTURE_PERIOD_COUNT 2

/* minimum sleep time in out_write() when write threshold is not reached */
#define MIN_WRITE_SLEEP_US 	5000

#define RESAMPLER_BUFFER_FRAMES (SHORT_PERIOD_SIZE * 2)
#define RESAMPLER_BUFFER_SIZE (4 * RESAMPLER_BUFFER_FRAMES)

/* Default sampling rate reported to Android */
#define DEFAULT_OUT_SAMPLING_RATE 44100

/* sampling rate when using MM low power port */
#define MM_LOW_POWER_SAMPLING_RATE 44100

/* sampling rate when using MM full power port */
#define MM_FULL_POWER_SAMPLING_RATE 48000

/* conversions from Percent to codec gains */
#define PERC_TO_PCM_VOLUME(x)     ( (int)((x) * 31 )) 
#define PERC_TO_CAPTURE_VOLUME(x) ( (int)((x) * 31 )) 
#define PERC_TO_HEADSET_VOLUME(x) ( (int)((x) * 31 )) 
#define PERC_TO_SPEAKER_VOLUME(x) ( (int)((x) * 31 )) 

#define PCM_CHANNELS_IN 2
#define PCM_CHANNELS_OUT 2
#define MIXER_PCM_PLAYBACK_VOLUME_DEFAULT 20
#define MIXER_SPEAKER_PLAYBACK_VOLUME_DEFAULT 20
#define MIXER_HEADSET_PLAYBACK_SWITCH_DEFAULT 0
#define MIXER_SPEAKER_PLAYBACK_SWITCH_DEFAULT 1
#define MIXER_MIC_CAPTURE_SWITCH_DEFAULT 1
#define MIXER_HEADSET_OUTENABLE_DEFAULT 1
#define MIXER_HP_ENABLE_DAC_DEFAULT 1
#define MIXER_SPK_ENABLE_DAC_DEFAULT 1
#define MIXER_AUXOUT_ENABLE_DEFAULT 1

struct pcm_config pcm_config_mm_out = {
    .channels = PCM_CHANNELS_OUT,
    .rate = MM_FULL_POWER_SAMPLING_RATE,
    .period_size = LONG_PERIOD_SIZE,
    .period_count = PLAYBACK_LONG_PERIOD_COUNT,
    .format = PCM_FORMAT_S16_LE,
};

struct pcm_config pcm_config_mm_in = {
    .channels = PCM_CHANNELS_IN,
    .rate = MM_FULL_POWER_SAMPLING_RATE,
    .period_size = SHORT_PERIOD_SIZE,
    .period_count = CAPTURE_PERIOD_COUNT,
    .format = PCM_FORMAT_S16_LE,
};

struct route_setting
{
    char *ctl_name;
    int intval;
    char *strval;
};

/* These are values that never change */
struct route_setting defaults[] = {
    /* general */
    {
        .ctl_name = MIXER_PCM_PLAYBACK_VOLUME,
        .intval = MIXER_PCM_PLAYBACK_VOLUME_DEFAULT,
    },
    {
        .ctl_name = MIXER_HEADSET_PLAYBACK_VOLUME,
        .intval = PERC_TO_HEADSET_VOLUME(1),
    },
    {
        .ctl_name = MIXER_SPEAKER_PLAYBACK_VOLUME,
        .intval = MIXER_SPEAKER_PLAYBACK_VOLUME_DEFAULT,
    },
    {
        .ctl_name = MIXER_MIC_CAPTURE_VOLUME,
        .intval = PERC_TO_CAPTURE_VOLUME(1),
    },
    {
        .ctl_name = MIXER_HEADSET_PLAYBACK_SWITCH,
        .intval = MIXER_HEADSET_PLAYBACK_SWITCH_DEFAULT,
    },
    {
        .ctl_name = MIXER_SPEAKER_PLAYBACK_SWITCH,
        .intval = MIXER_SPEAKER_PLAYBACK_SWITCH_DEFAULT,
    },
    {
        .ctl_name = MIXER_MIC_CAPTURE_SWITCH,
        .intval = MIXER_MIC_CAPTURE_SWITCH_DEFAULT,
    },
    {
	.ctl_name = MIXER_HEADSET_OUTENABLE,
        .intval = MIXER_HEADSET_OUTENABLE_DEFAULT,
    },
    {
        .ctl_name = MIXER_HPL_OUTMUX,
        .strval = MIXER_HP_LEFT,
    },
    {
        .ctl_name = MIXER_HPR_OUTMUX,
        .strval = MIXER_HP_RIGHT,
    },
    {
        .ctl_name = MIXER_AUX_OUTMUX,
        .strval = MIXER_SPK,
    },
    {
        .ctl_name = MIXER_HP_ENABLE_DAC,
        .intval = MIXER_HP_ENABLE_DAC_DEFAULT,
    },
    {
        .ctl_name = MIXER_SPK_ENABLE_DAC,
        .intval = MIXER_SPK_ENABLE_DAC_DEFAULT,
    },
    {
        .ctl_name = MIXER_AUXOUT_ENABLE,
        .intval = MIXER_AUXOUT_ENABLE_DEFAULT,
    },
    {
        .ctl_name = NULL,
    },

};


struct mixer_ctls
{
	
	struct mixer_ctl *pcm_volume;
	struct mixer_ctl *headset_volume;
	struct mixer_ctl *speaker_volume;
	struct mixer_ctl *mic_volume;
	struct mixer_ctl *headset_switch;
	struct mixer_ctl *speaker_switch;
	struct mixer_ctl *mic_switch;
	struct mixer_ctl *LHPMux;
	struct mixer_ctl *RHPMux;
	struct mixer_ctl *SpkMux;
	struct mixer_ctl *HPEnDAC;
	struct mixer_ctl *SpkEnDAC;

};

struct smba1002_audio_device {
	struct audio_hw_device hw_device;
	pthread_mutex_t lock;       /* see note below on mutex acquisition order */
	struct mixer *mixer;
	struct mixer_ctls mixer_ctls;
	int mode;
	int devices;
	int in_call;
	struct smba1002_stream_in *active_input;
	struct smba1002_stream_out *active_output;
	bool mic_mute;
	struct echo_reference_itfe *echo_reference;
	bool low_power; /* if system is in a low power state */
};

struct smba1002_stream_out {
	struct audio_stream_out stream;
	pthread_mutex_t lock;       /* see note below on mutex acquisition order */
	struct pcm_config config;
	struct pcm *pcm;
	struct resampler_itfe *resampler;
	char *buffer;
	int standby;
	struct echo_reference_itfe *echo_reference;
	struct smba1002_audio_device *dev;
	int write_threshold;
	bool low_power;				/* If the stream is in a low power playback mode */
};

#define MAX_PREPROCESSORS 3 /* maximum one AGC + one NS + one AEC per input stream */

struct smba1002_stream_in {
	struct audio_stream_in stream;

	pthread_mutex_t lock;       /* see note below on mutex acquisition order */
	struct pcm_config config;
	struct pcm *pcm;
	int device;
	struct resampler_itfe *resampler;
	struct resampler_buffer_provider buf_provider;
	int16_t *buffer;
	size_t frames_in;
	unsigned int requested_rate;
	int standby;
	int source;
	struct echo_reference_itfe *echo_reference;
	bool need_echo_reference;
	effect_handle_t preprocessors[MAX_PREPROCESSORS];
	int num_preprocessors;
	int16_t *proc_buf;
	size_t proc_buf_size;
	size_t proc_frames_in;
	int16_t *ref_buf;
	size_t ref_buf_size;
	size_t ref_frames_in;
	int read_status;
	struct smba1002_audio_device *dev;
};

