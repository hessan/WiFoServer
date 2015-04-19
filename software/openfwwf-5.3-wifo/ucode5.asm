#include "newreg.inc"
#include "spr.inc"
#include "shm.inc"
#include "cond.inc"
#include "tracker.inc"

// NOTE
// jext	0x3E -> jump on AP
// jnext 0x3D -> jump on AP
// jext 0x3D -> jump on STA

	#define		TS_ACK			0x035
	#define		TS_BEACON		0x020
	#define		TS_PROBE_RESP		0x014
	#define		TS_PROBE_REQ		0x010
	#define		TS_CTS			0x031
	#define		TS_PSPOLL		0x029

%arch 5

	orx	7, 8, 0x000, 0x000, SPR_GPIO_OUT

// ***********************************************************************************************
// HANDLER:	init
// PURPOSE:	Initializes the device.
//
init:
	mov	0, START_TIME0;
	orx	7, 8, 0x000, 0x000, SPR_PSM_0x4e
	orx	7, 8, 0x000, 0x000, SPR_PSM_0x0c
	orx	7, 8, 0x080, 0x000, SPR_SCC_Divisor
	orx	7, 8, 0x000, 0x002, SPR_SCC_Control
	orx	0, 1, 0x001, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	jnzx	0, 5, SPR_MAC_CMD, 0x000, do_not_erase_shm

	mov	SHM_LAST_WORD, SPR_BASE5
erase_shm:
	orx	7, 8, 0x000, 0x000, [0x00,off5]
	sub	SPR_BASE5, 0x001, SPR_BASE5
	jges	SPR_BASE5, 0x000, erase_shm
do_not_erase_shm:
	orx	7, 8, 0x000, 0x001, [SHM_UCODESTAT]
	orx	7, 8, 0x000, 0x000, REG34
	call	lr0, sel_phy_reg
	srx	7, 0, SPR_Ext_IHR_Data, 0x000, [SHM_PHYVER]
	srx	3, 8, SPR_Ext_IHR_Data, 0x000, [SHM_PHYTYPE]
	orx	7, 8, 0x000, 0x039, [0x0C0]
	orx	7, 8, 0x000, 0x050, [0x0C2]
	orx	7, 8, 0x0FC, 0x000, [SHM_PRPHYCTL]
	orx	7, 8, 0x000, 0x002, SPR_PHY_HDR_Parameter
	orx	7, 8, 0x000, 0x000, ANTENNA_DIVERSITY_CTR
	orx	7, 8, 0x000, 0x000, GPHY_SYM_WAR_FLAG
	orx	7, 8, 0x000, 0x000, GLOBAL_FLAGS_REG2
	orx	7, 8, 0x0FF, 0x000, [SHM_ACKCTSPHYCTL]
LABEL459:
	orx	7, 8, 0x001, 0x09A, [SHM_UCODEREV]
	orx	7, 8, 0x008, 0x070, [SHM_UCODEPATCH]
	orx	7, 8, 0x075, 0x01A, [SHM_UCODEDATE]
	orx	7, 8, 0x07C, 0x00A, [SHM_UCODETIME]
	orx	7, 8, 0x000, 0x000, [SHM_PCTLWDPOS]
	orx	7, 8, 0x000, 0x000, [0x005]
	mov	SHM_RXHEADER, SPR_BASE1
	mov	SHM_TXHEADER, SPR_BASE0
	orx	7, 8, 0x000, 0x000, [SHM_FIFOCTL1_RESET]
	or	MIN_CONTENTION_WIN, 0x000, CUR_CONTENTION_WIN
	and	SPR_TSF_Random, MIN_CONTENTION_WIN, SPR_IFS_BKOFFDELAY
	orx	7, 8, 0x040, 0x000, SPR_TSF_GPT0_STAT
	orx	7, 8, 0x045, 0x0C0, SPR_TSF_GPT0_CNTLO
	orx	7, 8, 0x000, 0x004, SPR_TSF_GPT0_CNTHI

	// if initvals do not, then let's do
	mov	0, SHORT_RETRIES
	mov	0, LONG_RETRIES
#define		DEFAULT_MAX_CW		0x03FF
	mov	DEFAULT_MAX_CW, MAX_CONTENTION_WIN
#define		DEFAULT_MIN_CW		0x001F
	mov	DEFAULT_MIN_CW, MIN_CONTENTION_WIN
#define DEFAULT_RETRY_LIMIT 7
	mov	DEFAULT_RETRY_LIMIT, SHORT_RETRY_LIMIT
	mov	DEFAULT_RETRY_LIMIT, LONG_RETRY_LIMIT
	jext	COND_TRUE, mac_suspend

// ***********************************************************************************************
// HANDLER:	state_machine_start
// PURPOSE:	Checks conditions looking for something to do. If there is no coming job firmware sleeps for a while or suspends device. 
//
state_machine_idle:
	jext	COND_PSM(0), state_machine_start

	// do not sleep if measuring bg noise
	jnzx	0, 3, GLOBAL_FLAGS_REG3, 0x000, state_machine_start

	// bit 0x0400 is always zero (cca in progress, we don't do it)
	//jnzx	0, 10, GLOBAL_FLAGS_REG1, 0x000, state_machine_start

	// bit 0x0002 and 0x0004 are always zero though some handler
	// continue to clean them. GFR2 is zero at beginning
	//jnzx	1, 1, GLOBAL_FLAGS_REG2, 0x000, state_machine_start

	// we don't enable bluetooth during transmission, do not support
	// jnzx	0, 9, [SHM_HF_MI], 0x000, state_machine_start

	orx	7, 8, 0x0FF, 0x0FF, SPR_MAC_MAX_NAP
//	nap

state_machine_start:
	orx	0, 0, 0x000, SPR_PSM_COND, SPR_PSM_COND

	// TRACKER begin
	jne	START_TIME0, 0, tracker_inited
	mov	0xFFFF, CURRENT_STATE
	mov	LIST_START, LIST_POINTER
	mov	LIST_END, MEMORY_END
	mov	1, START_TIME0
	mov	0, r54
tracker_inited:
	mov	0x396, TRACKER_TEMP1
//	mov	63, TRACKER_TEMP1
	and	SPR_IFS_STAT, TRACKER_TEMP1, TRACKER_TEMP1
	je	TRACKER_TEMP1, CURRENT_STATE, tracker_end
	mov	CURRENT_STATE, LAST_STATE
	mov	TRACKER_TEMP1, CURRENT_STATE
	
	or	SPR_TSF_WORD0, 0, TRACKER_TEMP0
	or	SPR_TSF_WORD1, 0, TRACKER_TEMP1
	sub.	TRACKER_TEMP0, SPR_TSF_0x3a, TRACKER_TEMP0 // Remove the offset
	subc	TRACKER_TEMP1, 0, TRACKER_TEMP1
	
	mov	SPR_BASE0, TRACKER_BASE_BACKUP
	mov	LIST_POINTER, SPR_BASE0
	
//	sl	r54, 8, TRACKER_TEMP2
	mov	CURRENT_STATE, TRACKER_TEMP2
//	or	CURRENT_STATE, TRACKER_TEMP2, TRACKER_TEMP2 // include the counter
//	add.	r54, 1, r54 // add one to the counter

	or	TRACKER_TEMP0, 0, [0, off0]
	or	TRACKER_TEMP1, 0, [1, off0]
	or	TRACKER_TEMP2, 0, [2, off0]
	
	mov	LIST_POINTER, [LIST_POINTER_OUT]
	add	LIST_POINTER, 3, LIST_POINTER
	jle	LIST_POINTER, MEMORY_END, memory_not_full_yet
	mov	LIST_START, LIST_POINTER
memory_not_full_yet:
	mov	TRACKER_BASE_BACKUP, SPR_BASE0
	mov	SPR_TSF_WORD0, START_TIME0
	mov	SPR_TSF_WORD1, START_TIME1
tracker_end:
	// TRACKER end

	// not sure if eoi can replace jnext other than jext
	extcond_eoi_only(COND_RADAR)
	extcond_eoi_only(COND_PHY0)
	extcond_eoi_only(COND_PHY1)
	jzx	0, 2, SPR_IFS_STAT, 0x000, dont_check_txe0_status
	jzx	0, 0, SPR_TXE0_STATUS, 0x000, reset_2us_waiting
dont_check_txe0_status:

	// check bit 0x0008, it is set by tx_timers_setup it rx needed
	jzx	0, 3, GLOBAL_FLAGS_REG2, 0x000, reset_2us_waiting
	jdn	SPR_TSF_WORD0, [SHM_WAIT2_CLOCK], continue_2us_waiting
reset_2us_waiting:
	orx	1, 3, 0x000, GLOBAL_FLAGS_REG2, GLOBAL_FLAGS_REG2
continue_2us_waiting:
	jzx	0, 3, SPR_IFS_STAT, 0x000, check_mac_status
	orx	1, 1, 0x000, GLOBAL_FLAGS_REG2, GLOBAL_FLAGS_REG2
	or	[SHM_GCLASSCTL], 0x000, REG35
	call	lr1, gphy_classify_control_with_arg
check_mac_status:
	orx	7, 8, 0x045, 0x0C0, SPR_TSF_GPT0_VALLO
	orx	7, 8, 0x000, 0x004, SPR_TSF_GPT0_VALHI
	orx	7, 8, 0x0C0, 0x000, SPR_TSF_GPT0_STAT
	jnext	COND_MACEN, mac_suspend_check
check_conditions:
	jext	EOI(COND_TX_NOW), tx_frame_now
	jext	EOI(COND_TX_POWER), tx_infos_update
	jext	EOI(COND_TX_UNDERFLOW), Lrecode1
Lrecode1:
	jext	COND_TX_DONE, tx_end_wait_10us

check_conditions_no_tx:
	jext	COND_TX_PHYERR, tx_phy_error

check_rx_conditions:
	// if bit 0x0002 and 0x0004 of SPR_BRWK0 are (both) zero, skip ifs check
	jzx	1, 1, SPR_BRWK0, 0x000, skip_ifs_check

	jext	COND_RX_IFS2, prepare_to_set_ifs2
	jnext	COND_RX_IFS1, skip_ifs_check

	// for my memory: linksys in ap mode never gets here
	// it cleans bit 0x0002 and 0x0004 of SPR_BRWK0
prepare_to_set_ifs2:
	orx	1, 1, 0x000, SPR_BRWK0, SPR_BRWK0
	jext	COND_TRUE, set_ifs2

skip_ifs_check:
	jext	EOI(COND_RX_WME8), tx_timers_setup
	jext	EOI(COND_RX_PLCP), rx_plcp
	jext	COND_RX_COMPLETE, rx_complete
	jext	COND_TX_PMQ, tx_contention_params_update
	jext	EOI(COND_RX_BADPLCP), rx_badplcp
	jnext	COND_RX_FIFOFULL, rx_fifofull

	// only pccard execute the following (means: fifo can be full)
	jnext	COND_REC_IN_PROGRESS, rx_fifo_overflow

rx_fifofull:
	jnzx	0, 15, SPR_RXE_0x1a, 0x000, rx_fifo_overflow
	extcond_eoi_only(COND_TX_NAV)
	jnext	COND_FRAME_NEED_ACK, channel_setup
	extcond_eoi_only(COND_PHY6)
	jext	COND_TRUE, state_machine_idle

/* --------------------------------------------------- HANDLERS ---------------------------------------------------------- */
// ***********************************************************************************************
// HANDLER:	channel_setup
// PURPOSE:	If TBTT expired prepares a beacon transmission else checks FIFO queue for incoming frames.	
//		The condition on SPR_BRC involves
//		COND_NEED_BEACON|COND_NEED_RESPONSEFR|COND_NEED_PROBE_RESP|COND_CONTENTION_PARAM_MODIFIED|COND_MORE_FRAGMENT
//
channel_setup:
	call	lr2, bg_noise_sample
	jext	COND_MORE_FRAGMENT, skip_beacon_ops
	jext	COND_TX_TBTTEXPIRE, prepare_beacon_tx

	jzx	0, 2, SPR_IFS_STAT, 0x000, no_gpio_hack
	jnzx	0, 15, SPR_TSF_GPT1_STAT, 0x000, no_gpio_hack
	jzx	0, 4, [SHM_HF_LO], 0x000, no_gpio_hack

	// this is executed only on pccard
	orx	0, 8, 0x000, SPR_GPIO_OUT, SPR_GPIO_OUT

no_gpio_hack:
	js	0x003, SPR_MAC_CMD, reset_mac_cmd_on_ap

skip_beacon_ops:
	extcond_eoi_only(COND_RX_ATIMWINEND)
	jand	SPR_TXE0_CTL, 0x001, check_tx_data_with_disabled_engine
check_tx_data:
	jext	EOI(COND_PHY6), check_tx_data
	jnand	0x01F, SPR_BRC, state_machine_idle
	srx	6, 3, SPR_IFS_0x0c, 0x000, REG34
	jl	REG34, 0x004, state_machine_start
	jext	COND_TRUE, state_machine_idle

	// for my memory: only aspirino_ap larrybird_ap panatta_ap get here
	// and larrybird_ap jumps immediately to state_machine_idle 
reset_mac_cmd_on_ap:
	jnand	0x020, SPR_BRC, state_machine_idle
	srx	1, 7, GLOBAL_FLAGS_REG3, 0x000, REG34
	orx	1, 0, REG34, 0x000, SPR_MAC_CMD
	orx	7, 8, 0x000, 0x002, SPR_MAC_IRQLO
	srx	1, 0, SPR_MAC_CMD, 0x000, REG34
	orx	1, 7, REG34, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	jext	COND_TRUE, state_machine_idle

// ***********************************************************************************************
// HANDLER:	prepare_beacon_tx
// PURPOSE:	Prepares parameters (PHY and MAC) needed for a correct Beacon transmission.
//		The condition on SPR_BRC involves
//		COND_NEED_BEACON|COND_NEED_RESPONSEFR|COND_FRAME_BURST|COND_REC_IN_PROGRESS|COND_FRAME_NEED_ACK
//
prepare_beacon_tx:
	jnand	0x0E3, SPR_BRC, state_machine_idle
	jnzx	0, 2, GLOBAL_FLAGS_REG2, 0x000, state_machine_idle
	jext	COND_PSM(1), state_machine_start
	jzx	0, 4, [SHM_HF_LO], 0x000, no_gpio_hack2

	// run only on pccard
	orx	0, 8, 0x001, SPR_GPIO_OUT, SPR_GPIO_OUT

no_gpio_hack2:
	jnext	0x3D, beacon_tx_param_update
	jext	0x3E, beacon_tx_param_update

	// run only on STA
inhibit_sleep_call:
	call	lr0, inhibit_sleep_at_tbtt
	jext	COND_TRUE, state_machine_idle

	// run only on AP
beacon_tx_param_update:
	jzx	1, 0, SPR_MAC_CMD, 0x000, inhibit_sleep_call
	call	lr0, flush_and_stop_tx_engine
	or	[SHM_BEACPHYCTL], 0x000, SPR_TXE0_PHY_CTL
bcn_no_hw_pwr_ctl:
	call	lr1, prep_phy_txctl_encoding_already_set
	orx	7, 8, 0x000, 0x020, TX_TYPE_SUBTYPE
	call	lr3, LABEL559
	jext	COND_CONTENTION_PARAM_MODIFIED, skip_parameter_preservation
	orx	7, 8, 0x000, 0x004, SPR_MAC_IRQLO
	orx	7, 8, 0x000, 0x000, SPR_TSF_Random
skip_parameter_preservation:
	or	[SHM_BTSFOFF], 0x000, SPR_TSF_0x3a
	orx	2, 0, 0x001, SPR_BRC, SPR_BRC
	orx	0, 3, 0x001, SPR_BRC, SPR_BRC
goto_set_ifs:
	orx	7, 8, 0x049, 0x083, SPR_TXE0_CTL
	jext	COND_TRUE, state_machine_idle

// ***********************************************************************************************
// HANDLER:	check_tx_data
// PURPOSE:	Checks if there is a frame into the FIFO queue. If a frame is incoming from host loads BCM
//		header into SHM and analyzes frame properties, then prepares PHY and MAC parameters for transmission.
//		This code should be invoke with TX engine disabled.
//		The condition on SPR_BRC involves
//		COND_NEED_BEACON|COND_NEED_RESPONSEFR|COND_NEED_PROBE_RESP|COND_CONTENTION_PARAM_MODIFIED|COND_FRAME_BURST
//
check_tx_data_with_disabled_engine:
	jext	COND_PSM(1), state_machine_start
	extcond_eoi_only(COND_PHY6)
	jnand	0x02F, SPR_BRC, state_machine_idle
	jext	COND_TX_NOW, state_machine_start
	jnzx	0, 0, SPR_TXE0_STATUS, 0x000, ready_for_header_copy

	// for my memory: only linksys in STA mode get here
	orx	0, 4, 0x000, SPR_BRC, SPR_BRC
	jext	COND_TRUE, state_machine_idle

ready_for_header_copy:
	jzx	0, 2, SPR_MAC_CMD, 0x000, slow_clock_control
	jzx	0, 1, SPR_TXE0_FIFO_RDY, 0x000, slow_clock_control
	orx	2, 8, 0x001, 0x000, [SHM_TXFCUR]
copy_header_into_shm:
	call	lr3, load_tx_header_into_shm
	jext	COND_TRUE, check_tx_channel

check_tx_channel:
	srx	1, 7, [TXHDR_MACLO,off0], 0x000, REG34
	srx	7, 8, [TXHDR_EFT,off0], 0x000, REG35
	orx	1, 8, REG34, REG35, REG34
	srx	9, 0, [SHM_CHAN], 0x000, REG35
	je	REG34, REG35, check_pmq_tx_header_info

	// only STAs get here
	orx	2, 2, 0x004, [TXHDR_STAT,off0], [TXHDR_STAT,off0]
	jext	COND_TRUE, suppress_this_frame

check_pmq_tx_header_info:
	or	[TXHDR_PHYCTL,off0], 0x000, SPR_TXE0_PHY_CTL
	jext	COND_MORE_FRAGMENT, skip_pmq_op
	jnand	[TXHDR_MACLO,off0], 0x020, skip_pmq_op
	or	[TXHDR_RA,off0], 0x000, SPR_PMQ_pat_0
	or	[TXHDR_PMQ1,off0], 0x000, SPR_PMQ_pat_1
	or	[TXHDR_PMQ2,off0], 0x000, SPR_PMQ_pat_2
	orx	7, 8, 0x000, 0x004, SPR_PMQ_control_low
skip_pmq_op:
	orx	1, 1, 0x002, [TXHDR_HK5,off0], [TXHDR_HK5,off0]
	jext	COND_MORE_FRAGMENT, extract_phy_info
	or	[TXHDR_FES,off0], 0x000, SPR_TX_FES_Time
	jzx	0, 4, [TXHDR_HK5,off0], 0x000, dont_set_fallback_fes_time
	/* POLICE COMMENTING */
//	or	[TXHDR_FESFB,off0], 0x000, SPR_TX_FES_Time
dont_set_fallback_fes_time:
	jnzx	0, 5, [TXHDR_MACLO,off0], 0x000, extract_phy_info
wait_pmq_to_clean:
	jnzx	0, 2, SPR_PMQ_control_low, 0x000, wait_pmq_to_clean
extract_phy_info:
	/* POLICE COMMENTING */
//	jnzx	0, 4, [TXHDR_HK5,off0], 0x000, extract_fallback_info
	srx	7, 0, [TXHDR_PHYRATES,off0], 0x000, REG0
	srx	1, 0, [TXHDR_PHYCTL,off0], 0x000, REG1
	jext	COND_TRUE, extract_tx_type_subtype
extract_fallback_info:
	srx	7, 0, [TXHDR_PLCPFB0,off0], 0x000, REG0
	srx	1, 0, [TXHDR_EFT,off0], 0x000, REG1
extract_tx_type_subtype:
	srx	5, 2, [TXHDR_FCTL,off0], 0x000, TX_TYPE_SUBTYPE
LABEL103:
	call	lr1, get_ptr_from_rate_table
check_tx_no_hw_pwr_ctl:
	call	lr1, prep_phy_txctl_with_encoding
	srx	0, 4, SPR_TXE0_PHY_CTL, 0x000, REG1
	orx	0, 4, REG1, [SHM_CURMOD], REG1
	call	lr0, get_rate_table_duration
	add	REG34, [SHM_SLOTT], REG34
	orx	11, 3, REG34, 0x000, SPR_TXE0_TIMEOUT
	call	lr3, LABEL559

check_tx_next_txe_ctl_1:
	orx	7, 8, 0x04C, 0x01D, NEXT_TXE0_CTL
	jne	TX_TYPE_SUBTYPE, TS_PROBE_RESP, check_tx_next_txe_ctl_2

	// only AP get here
	// but I think after removing probe response offloading it will
	// not get here anymore
	orx	7, 8, 0x04D, 0x01D, NEXT_TXE0_CTL
check_tx_next_txe_ctl_2:
	jext	COND_TRUE, set_ifs

// ***********************************************************************************************
// HANDLER:	suppress_this_frame
// PURPOSE:	Flushes frame and tells the host that transmission failed.
//
// Only STAs may suppress frame, AP never
suppress_this_frame:
	orx	7, 8, 0x000, 0x000, SPR_TXE0_SELECT
	jext	COND_TRUE, report_tx_status_to_host

// ***********************************************************************************************
// HANDLER:	set_ifs
// PURPOSE:	Prepares backoff time (if it is equal to zero) for the next contention stage.
// 
set_ifs:
	extcond_eoi_only(COND_RX_ATIMWINEND)
	orx	7, 8, 0x000, 0x001, [0x042]
	or	NEXT_TXE0_CTL, 0x000, SPR_TXE0_CTL
	jne	SPR_IFS_BKOFFDELAY, 0x000, state_machine_idle
set_ifs2:
	jext	COND_RX_IFS1, go_with_ifs1
	jext	COND_RX_IFS2, go_with_ifs2
	orx	1, 1, 0x003, SPR_BRWK0, SPR_BRWK0
	jext	COND_TRUE, state_machine_idle
go_with_ifs2:
	jext	EOI(COND_TX_NOW), tx_frame_now
go_with_ifs1:
	orx	7, 8, 0x000, 0x000, SPR_TSF_Random
	call	lr1, set_backoff_time
	jext	COND_TRUE, state_machine_idle

// ***********************************************************************************************
// HANDLER:	tx_frame_now
// PURPOSE:	Performs a data, ACK or Beacon frame transmission according to the PHY and MAC parameters that have been set.
//
tx_frame_now:
	orx	7, 8, 0x000, 0x004, SPR_RXE_FIFOCTL1
	nand	SPR_BRC, 0x180, SPR_BRC
	orx	7, 8, 0x083, 0x000, SPR_WEP_CTL
	jzx	0, 4, [SHM_HF_LO], 0x000, no_gpio_hack3
	// only pc card get here
	jnzx	0, 5, GLOBAL_FLAGS_REG2, 0x000, no_gpio_hack3
	orx	0, 8, 0x001, SPR_GPIO_OUT, SPR_GPIO_OUT
no_gpio_hack3:
	orx	0, 15, 0x000, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	jne	[0x042], 0x001, no_param_update_needed
	or	SPR_TSF_WORD0, 0x000, [0x043]
no_param_update_needed:
	orx	0, 5, 0x001, SPR_BRC, SPR_BRC
	orx	0, 4, 0x001, SPR_IFS_CTL, SPR_IFS_CTL
	orx	1, 1, 0x000, SPR_BRWK0, SPR_BRWK0
	orx	7, 8, 0x000, 0x000, SPR_TXE0_WM0
	orx	7, 8, 0x000, 0x000, SPR_TXE0_WM1
	jnext	COND_NEED_RESPONSEFR, tx_beacon_or_data
	orx	7, 8, 0x000, 0x0FF, SPR_TXE0_WM0
	srx	0, 5, GLOBAL_FLAGS_REG3, 0x000, REG34
	orx	0, 12, REG34, SPR_TME_VAL6, SPR_TME_VAL6
	jles	SPR_TME_VAL8, 0x000, dont_update_preamble
	sub	SPR_TME_VAL8, [SHM_PREAMBLE_DURATION], SPR_TME_VAL8
	jzx	0, 4, SPR_TXE0_PHY_CTL, 0x000, dont_use_short_preamble

	// only AP get here (till next label)
	sr	[SHM_PREAMBLE_DURATION], 0x001, REG34
	add	SPR_TME_VAL8, REG34, SPR_TME_VAL8
dont_use_short_preamble:
	jges	SPR_TME_VAL8, 0x000, dont_update_preamble

	// only AP execute the following line
	orx	7, 8, 0x000, 0x000, SPR_TME_VAL8
dont_update_preamble:
	orx	7, 8, 0x000, 0x000, SPR_TXE0_SELECT
	orx	7, 8, 0x000, 0x000, SPR_TXE0_Template_TX_Pointer
	orx	7, 8, 0x000, 0x010, SPR_TXE0_TX_COUNT
	orx	7, 8, 0x008, 0x026, SPR_TXE0_SELECT
	jext	COND_TRUE, complete_tx

tx_beacon_or_data:
	jnext	COND_NEED_BEACON, tx_data

	// the following is executed only on AP, tx a beacon
	orx	0, 3, 0x000, SPR_BRC, SPR_BRC

	// this can be: jump if beacon is untouch, or actually it doesn't jump at all
	jnext	0x3D, dont_touch_beacon

	jgs	CURRENT_DTIM_COUNTER, 0x000, dont_update_tim_counter
	or	[SHM_DTIMPER], 0x000, CURRENT_DTIM_COUNTER
dont_update_tim_counter:
	sub	CURRENT_DTIM_COUNTER, 0x001, CURRENT_DTIM_COUNTER
	orx	7, 8, 0x000, 0x000, REG35
	jgs	CURRENT_DTIM_COUNTER, 0x000, load_beacon_tim
	srx	0, 4, SPR_TXE0_FIFO_RDY, 0x000, REG35
	orx	0, 10, REG35, SPR_BRC, SPR_BRC
load_beacon_tim:
	orx	0, 1, 0x001, SPR_TXE0_AUX, SPR_TXE0_AUX
	orx	7, 8, 0x004, 0x06A, REG34
	add	REG34, [SHM_TIMBPOS], REG34

	mov	SHM_BEACON_TIM_PTR, SPR_BASE5
	sl	SPR_BASE5, 0x001, SPR_TXE0_TX_SHM_ADDR
	orx	7, 8, 0x000, 0x000, SPR_TXE0_SELECT
	orx	1, 0, 0x000, REG34, SPR_TXE0_Template_TX_Pointer
	orx	7, 8, 0x000, 0x008, SPR_TXE0_TX_COUNT
	orx	7, 8, 0x008, 0x005, SPR_TXE0_SELECT

wait_tx_bcn_free:
	jnext	COND_TX_BUSY, wait_tx_bcn_free
wait_tx_bcn_write:
	jext	COND_TX_BUSY, wait_tx_bcn_write
	orx	7, 0, CURRENT_DTIM_COUNTER, [0x00,off5], [0x00,off5]
	orx	0, 0, REG35, [0x01,off5], [0x01,off5]
end_dtim_update:
	orx	1, 0, 0x000, REG34, SPR_TXE0_Template_Pointer
	or	[0x00,off5], 0x000, SPR_TXE0_Template_Data_Low
	or	[0x01,off5], 0x000, SPR_TXE0_Template_Data_High
wait_tmpl_ram:
	jnzx	0, 0, SPR_TXE0_Template_Pointer, 0x000, wait_tmpl_ram
	add	SPR_TXE0_Template_Pointer, 0x004, SPR_TXE0_Template_Pointer
	or	[0x02,off5], 0x000, SPR_TXE0_Template_Data_Low
	or	[0x03,off5], 0x000, SPR_TXE0_Template_Data_High
dont_touch_beacon:
	// only on AP
	orx	0, 14, 0x001, SPR_TXE0_WM0, SPR_TXE0_WM0
	add	SEQUENCE_CTR, 0x001, SEQUENCE_CTR
	orx	11, 4, SEQUENCE_CTR, 0x000, SPR_TME_VAL28
	orx	7, 8, 0x000, 0x000, SPR_TXE0_SELECT
	orx	7, 8, 0x000, 0x068, SPR_TXE0_Template_TX_Pointer
	or	[SHM_BTL0], 0x000, SPR_TXE0_TX_COUNT
	jnzx	0, 7, GLOBAL_FLAGS_REG3, 0x000, bcn_tmpl_off1
	orx	7, 8, 0x004, 0x068, SPR_TXE0_Template_TX_Pointer
	or	[SHM_BTL1], 0x000, SPR_TXE0_TX_COUNT

bcn_tmpl_off1:
	orx	7, 8, 0x008, 0x026, SPR_TXE0_SELECT
	orx	0, 6, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	extcond_eoi_only(COND_TX_TBTTEXPIRE)

no_params_preservation:
	or	MIN_CONTENTION_WIN, 0x000, CUR_CONTENTION_WIN
	jnzx	0, 0, SPR_TSF_0x0e, 0x000, params_restored
	and	SPR_TSF_Random, CUR_CONTENTION_WIN, SPR_IFS_BKOFFDELAY

params_restored:
	orx	7, 8, 0x000, 0x008, SPR_MAC_IRQLO
	orx	0, 4, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
complete_tx:
	orx	0, 8, 0x001, 0x000, SPR_WEP_CTL
	jext	COND_NEED_BEACON, update_txe_timeout
// TTT 	jzx	0, 12, GLOBAL_FLAGS_REG1, 0x000, update_txe_timeout2
	jext	COND_TRUE, update_txe_timeout2
tx_data:
	srx	0, 6, [TXHDR_MACLO,off0], 0x000, REG34
	xor	REG34, 0x001, REG34
	orx	0, 14, REG34, SPR_TXE0_CTL, SPR_TXE0_CTL
	/* police BEGIN */
	jext	COND_TRUE, no_fallback_updates;
	/* police END */
	jext	COND_NEED_PROBE_RESP, force_fallback_updates
	jzx	0, 4, [TXHDR_HK5,off0], 0x000, no_fallback_updates
force_fallback_updates:
	or	[TXHDR_PLCPFB0,off0], 0x000, SPR_TME_VAL0
	or	[TXHDR_PLCPFB1,off0], 0x000, SPR_TME_VAL2
	or	[TXHDR_DURFB,off0], 0x000, SPR_TME_VAL8
	or	SPR_TXE0_WM0, 0x013, SPR_TXE0_WM0
no_fallback_updates:
	orx	0, 14, 0x001, [SHM_TXFCUR], SPR_TXE0_FIFO_CMD
	or	[SHM_TXFCUR], 0x000, SPR_TXE0_SELECT
	orx	7, 8, 0x000, 0x068, SPR_TXE0_TX_COUNT
	or	[SHM_TXFCUR], 0x007, SPR_TXE0_SELECT
	orx	1, 0, 0x002, [SHM_TXFCUR], SPR_TXE0_SELECT
	srx	1, 0, TX_TYPE_SUBTYPE, 0x000, REG34
	je	REG34, 0x001, dont_update_seq_ctr_value_for_control_frame
	jnzx	3, 12, [TXHDR_STAT,off0], 0x000, update_seq_ctr_value
	jzx	0, 3, [TXHDR_MACLO,off0], 0x000, update_seq_ctr_value
	add	SEQUENCE_CTR, 0x001, SEQUENCE_CTR
	srx	11, 0, SEQUENCE_CTR, 0x000, [TXHDR_RTSSEQCTR,off0]
update_seq_ctr_value:
	orx	11, 4, [TXHDR_RTSSEQCTR,off0], 0x000, SPR_TME_VAL28
	orx	0, 14, 0x001, SPR_TXE0_WM0, SPR_TXE0_WM0
dont_update_seq_ctr_value_for_control_frame:
	srx	0, 9, SPR_MAC_CTLHI, 0x000, REG34
	orx	0, 5, REG34, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
// TTT 	jext	0x3D, tx_frame_update_status_info
// RRR	jext	COND_TRUE, tx_frame_update_status_info
tx_frame_update_status_info:
	orx	0, 7, REG34, [TXHDR_STAT,off0], [TXHDR_STAT,off0]
	orx	0, 12, REG34, 0x000, SPR_TME_VAL6
	orx	0, 12, 0x001, 0x000, SPR_TME_MASK6
	orx	0, 3, 0x001, SPR_TXE0_WM0, SPR_TXE0_WM0
	srx	1, 0, TX_TYPE_SUBTYPE, 0x000, REG34
	je	REG34, 0x001, tx_frame_analysis
	jzx	3, 12, [TXHDR_STAT,off0], 0x000, update_gpreg5_with_cur_fifo
	orx	0, 11, 0x001, SPR_TME_VAL6, SPR_TME_VAL6
	orx	0, 11, 0x001, SPR_TME_MASK6, SPR_TME_MASK6
update_gpreg5_with_cur_fifo:
	srx	2, 8, [SHM_TXFCUR], 0x000, REG34
tx_frame_analysis:
	orx	0, 8, 0x001, 0x000, SPR_WEP_CTL
find_tx_frame_type:
	orx	7, 8, 0x000, 0x000, SPR_TSF_Random
	or	SPR_TSF_0x40, 0x000, [TXHDR_RTSPLCP,off0]
	orx	7, 8, 0x000, 0x000, EXPECTED_CTL_RESPONSE
	je	TX_TYPE_SUBTYPE, 0x02D, LABEL182
	jzx	0, 0, [TXHDR_MACLO,off0], 0x000, reset_cur_contention_window
LABEL182:
	orx	0, 7, 0x001, SPR_BRC, SPR_BRC
	or	SPR_BRC, 0x000, 0x000
	orx	7, 8, 0x000, 0x031, EXPECTED_CTL_RESPONSE
	je	TX_TYPE_SUBTYPE, 0x02D, update_txe_timeout2
	orx	7, 8, 0x000, 0x035, EXPECTED_CTL_RESPONSE
	jext	COND_TRUE, update_txe_timeout2
reset_cur_contention_window:
	or	MIN_CONTENTION_WIN, 0x000, CUR_CONTENTION_WIN
	call	lr1, set_backoff_time
update_txe_timeout:
	orx	7, 8, 0x000, 0x000, SHORT_RETRIES
	orx	7, 8, 0x000, 0x000, LONG_RETRIES
update_txe_timeout2:
	jnext	COND_FRAME_NEED_ACK, dont_update_txe_timeout
	orx	0, 15, 0x001, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
dont_update_txe_timeout:
no_radar_war:
// TTT 	jne	[SHM_PHYTYPE], 0x001, tx_frame_no_B_phy
// RRR	jext	COND_TRUE, tx_frame_no_B_phy
tx_frame_no_B_phy:
	je	[SHM_PHYTYPE], 0x000, tx_frame_A_phy
	jnzx	1, 0, SPR_TXE0_PHY_CTL, 0x000, tx_frame_A_phy
	add	SPR_TSF_WORD0, 0x028, REG34
	jext	COND_TRUE, tx_frame_wait_16us
tx_frame_A_phy:
	add	SPR_TSF_WORD0, 0x010, REG34
tx_frame_wait_16us:
	jext	COND_TX_DONE, state_machine_idle
	jne	SPR_TSF_WORD0, REG34, tx_frame_wait_16us
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x000, aphy_tssi_selection
	orx	7, 8, 0x000, 0x029, REG34
	mov	SHM_TSSI_CCK_LO, SPR_BASE5
	jext	COND_TRUE, update_phy_params
aphy_tssi_selection:
	orx	7, 8, 0x004, 0x07B, REG34
	mov	SHM_TSSI_OFDM_G_LO, SPR_BASE5
update_phy_params:
	call	lr0, sel_phy_reg
	rr	[0x01,off5], 0x008, [0x01,off5]
	srx	7, 8, [0x00,off5], 0x000, REG34
	orx	7, 0, REG34, [0x01,off5], [0x01,off5]
	rr	[0x00,off5], 0x008, [0x00,off5]
	orx	7, 0, SPR_Ext_IHR_Data, [0x00,off5], [0x00,off5]

// TTT 	jzx	0, 10, GLOBAL_FLAGS_REG1, 0x000, tx_frame_no_cca_in_progress
// RRR	jext	COND_TRUE, tx_frame_no_cca_in_progress
tx_frame_no_cca_in_progress:
	jnzx	0, 11, SPR_IFS_STAT, 0x000, state_machine_idle
// *** JUMPDOC panatta panatta_ap
	jge	SPR_NAV_0x04, 0x0A0, state_machine_idle
// *** JUMPDOC panatta panatta_ap
	orx	7, 8, 0x0FF, 0x0FF, SPR_NAV_0x04
	orx	0, 10, 0x001, 0x05F, REG34
// DOC panatta panatta_ap
wait_for_ihr_data_to_clear:
	call	lr0, sel_phy_reg
	and	SPR_Ext_IHR_Data, 0x01F, REG35
	je	REG35, 0x016, wait_for_ihr_data_to_clear
// *** JUMPDOC panatta panatta_ap
	orx	7, 8, 0x000, 0x000, SPR_NAV_0x04
	jext	COND_TRUE, state_machine_idle

// ***********************************************************************************************
// HANDLER:	tx_infos_update
// PURPOSE:	Updates retries informations and looks for transmission error. If sent frame doesn't require ACK, tells the host that transmission was successfully performed.
//
tx_infos_update:
	orx	0, 5, 0x000, SPR_BRC, SPR_BRC
	orx	7, 8, 0x087, 0x000, SPR_WEP_CTL
	jnzx	0, 10, [TXHDR_FCTL,off0], 0x000, need_ack
	orx	0, 4, 0x000, SPR_BRC, SPR_BRC
need_ack:
	jext	COND_NEED_RESPONSEFR, need_response_frame
	jext	EOI(COND_TX_UNDERFLOW), Lrecode11
Lrecode11:
	jext	EOI(COND_TX_PHYERR), tx_clear_issues
	jnext	COND_NEED_BEACON, dont_need_beacon
	// glad to see that only AP may not jump from the jump above

need_response_frame:
	orx	1, 0, 0x000, SPR_BRC, SPR_BRC
	jext	COND_TRUE, state_machine_start
dont_need_beacon:
	orx	7, 8, 0x000, 0x001, REG34
	srx	3, 12, [TXHDR_STAT,off0], 0x000, REG11
	add	REG11, REG34, REG11
	orx	3, 12, REG11, [TXHDR_STAT,off0], [TXHDR_STAT,off0]
	jext	COND_FRAME_NEED_ACK, state_machine_start
	jext	COND_TRUE, report_tx_status_to_host

// ***********************************************************************************************
// HANDLER:	tx_end_wait_10us
// PURPOSE:	Doesn't allow noise measurement for 10us after transmission. 
//
tx_end_wait_10us:
	jnzx	0, 4, GLOBAL_FLAGS_REG1, 0x000, tx_end_completed
	orx	0, 4, 0x001, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	or	SPR_TSF_WORD0, 0x000, [SHM_WAIT10_CLOCK]
// TTT 	jzx	0, 7, GLOBAL_FLAGS_REG2, 0x000, LABEL217
// RRR	jext	COND_TRUE, LABEL217
LABEL217:
	orx	7, 8, 0x040, 0x000, SPR_TSF_GPT2_STAT
	call	lr3, LABEL559
// TTT 	jzx	0, 6, [SHM_HF_LO], 0x000, tx_end_completed
// RRR	jext	COND_TRUE, tx_end_completed
tx_end_completed:
	sub	SPR_TSF_WORD0, [SHM_WAIT10_CLOCK], REG38
	jl	REG38, 0x008, check_conditions_no_tx
	orx	7, 8, 0x000, 0x027, REG34
	call	lr0, sel_phy_reg
	and	SPR_Ext_IHR_Data, 0x0FF, [SHM_PHYTXNOI]
	orx	0, 4, 0x000, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	jext	EOI(COND_TX_DONE), state_machine_idle
	jext	COND_TRUE, report_tx_status_to_host

// ***********************************************************************************************
// HANDLER:	report_tx_status_to_host
// PURPOSE:	Reports informations about transmission to the host, informing it about success or failure of the operation.
//
// In 5.2 there was an entry point to handle RTS, I removed it
report_tx_status_to_host:
	jand	[TXHDR_HK4,off0], 0x003, dont_clear_housekeeping
	jnext	EOI(COND_RX_FIFOFULL), rx_fifo_not_full

	// for my memory this line is needed only for pccard
	orx	1, 8, [SHM_FIFOCTL1_RESET], 0x014, SPR_RXE_FIFOCTL1
	jext	COND_TRUE, rx_fifo_handled

rx_fifo_not_full:
	jext	COND_RX_FIFOBUSY, report_tx_status_to_host
	jext	COND_RX_CRYPTBUSY, report_tx_status_to_host
rx_fifo_handled:
	orx	7, 8, 0x000, 0x000, [TXHDR_RTS,off0]
	orx	0, 13, 0x001, [SHM_TXFCUR], SPR_TXE0_FIFO_CMD
	jzx	0, 0, [TXHDR_STAT,off0], 0x000, rise_status_interrupt
	or	SPR_RXE_PHYRXSTAT1, 0x000, [TXHDR_RTS,off0]
rise_status_interrupt:
	orx	7, 8, 0x000, 0x080, SPR_MAC_IRQLO
	jnzx	0, 13, SPR_MAC_CTLHI, 0x000, discard_tx_status
	or	[TXHDR_STAT,off0], 0x000, REG34
	orx	0, 1, REG34, REG34, REG34
	or	[TXHDR_RTSPHYSTAT,off0], 0x000, SPR_TX_STATUS3
	or	[TXHDR_RTSSEQCTR,off0], 0x000, SPR_TX_STATUS2
	or	[TXHDR_COOKIE,off0], 0x000, SPR_TX_STATUS1
	orx	0, 0, 0x001, REG34, SPR_TX_STATUS0
discard_tx_status:
	orx	1, 0, 0x000, [TXHDR_HK4,off0], [TXHDR_HK4,off0]
dont_clear_housekeeping:
	orx	0, 6, 0x000, [TXHDR_STAT,off0], [TXHDR_STAT,off0]
	orx	0, 11, 0x000, SPR_BRC, SPR_BRC
	orx	7, 8, 0x000, 0x000, [TXHDR_RTSPHYSTAT,off0]
	jext	COND_MORE_FRAGMENT, check_tx_data_with_disabled_engine
	jext	COND_TRUE, state_machine_start

// ***********************************************************************************************
// HANDLER:	tx_contention_params_update
// PURPOSE:	Updates current window parameter according to success or failure of transmission operation. Checks if retries reached the top limit and eventually commands a drop operation.
//
tx_contention_params_update:
	jnext	COND_FRAME_NEED_ACK, finish_updates
	jext	COND_REC_IN_PROGRESS, finish_updates
	jext	COND_FRAME_BURST, finish_updates
	orx	0, 7, 0x000, SPR_BRC, SPR_BRC
	jnext	EOI(COND_TX_PMQ), reset_antenna_ctr_if_needed
	jnzx	0, 1, GLOBAL_FLAGS_REG2, 0x000, update_params_on_success
	add	[0x09A], 0x001, [0x09A]
	jext	COND_TRUE, update_contention_params
reset_antenna_ctr_if_needed:
	jnext	COND_RX_FCS_GOOD, dont_reset_antenna_ctr
	je	REG19, TS_CTS, dont_reset_antenna_ctr
	orx	7, 8, 0x000, 0x000, ANTENNA_DIVERSITY_CTR
dont_reset_antenna_ctr:
	jext	COND_TX_ERROR, update_contention_params
	jext	EOI(COND_RX_FCS_GOOD), update_params_on_success
update_contention_params:
	orx	0, 8, 0x000, SPR_BRC, SPR_BRC
	call	lr1, antenna_diversity_helper
	orx	0, 4, 0x000, SPR_BRC, SPR_BRC
	orx	14, 1, CUR_CONTENTION_WIN, 0x001, CUR_CONTENTION_WIN
	and	CUR_CONTENTION_WIN, MAX_CONTENTION_WIN, CUR_CONTENTION_WIN
	je	EXPECTED_CTL_RESPONSE, TS_CTS, using_fallback
	jnzx	0, 1, [TXHDR_MACLO,off0], 0x000, use_long_retry
using_fallback:
	or	SHORT_RETRY_LIMIT, 0x000, REG36
	or	[SHM_SFFBLIM], 0x000, REG37
	jl	REG11, REG37, dont_use_fallback_short
	/* POLICE COMMENTING */
//	orx	0, 4, 0x001, [TXHDR_HK5,off0], [TXHDR_HK5,off0]
dont_use_fallback_short:
	add	SHORT_RETRIES, 0x001, SHORT_RETRIES
	jne	SHORT_RETRIES, REG36, short_retry_limit_not_reached_yet
	// only the pc with the pccard execute the following
	or	MIN_CONTENTION_WIN, 0x000, CUR_CONTENTION_WIN
short_retry_limit_not_reached_yet:
	jge	REG11, REG36, retry_limit_reached
	jext	COND_TRUE, retry_limit_not_reached
use_long_retry:
	or	LONG_RETRY_LIMIT, 0x000, REG36
	or	[SHM_LFFBLIM], 0x000, REG37
	jl	REG11, REG37, dont_use_fallback_long
	/* POLICE COMMENTING */
//	orx	0, 4, 0x001, [TXHDR_HK5,off0], [TXHDR_HK5,off0]
dont_use_fallback_long:
	add	LONG_RETRIES, 0x001, LONG_RETRIES
	jne	LONG_RETRIES, REG36, long_retry_limit_not_reached_yet
	or	MIN_CONTENTION_WIN, 0x000, CUR_CONTENTION_WIN
long_retry_limit_not_reached_yet:
	jl	REG11, REG36, retry_limit_not_reached
retry_limit_reached:
	extcond_eoi_only(COND_TX_PMQ)
	call	lr1, set_backoff_time
	orx	0, 3, 0x001, [TXHDR_HK5,off0], [TXHDR_HK5,off0]
	orx	0, 11, 0x000, SPR_BRC, SPR_BRC
	jext	COND_TRUE, report_tx_status_to_host
retry_limit_not_reached:
	call	lr1, set_backoff_time
	orx	0, 2, 0x000, SPR_BRC, SPR_BRC
	orx	0, 12, 0x000, SPR_BRC, SPR_BRC
finish_updates:
	extcond_eoi_only(COND_TX_PMQ)
	jext	COND_NEED_RTS, report_tx_status_to_host
	jext	COND_TRUE, state_machine_start
update_params_on_success:
	srx	1, 0, TX_TYPE_SUBTYPE, 0x000, REG34
	je	REG34, 0x001, update_params_control_frame
	or	MIN_CONTENTION_WIN, 0x000, CUR_CONTENTION_WIN
update_params_control_frame:
	call	lr1, set_backoff_time
	orx	7, 8, 0x000, 0x000, SHORT_RETRIES
	jzx	0, 1, [TXHDR_MACLO,off0], 0x000, use_short_retry
	orx	7, 8, 0x000, 0x000, LONG_RETRIES
use_short_retry:
	orx	0, 0, 0x001, [TXHDR_STAT,off0], [TXHDR_STAT,off0]
	jext	COND_TRUE, report_tx_status_to_host

// ***********************************************************************************************
// HANDLER:	send_response
// PURPOSE:	Sends an ACK back to the station whose MAC was contained in the source address header field.
//		At the end set the NEED_RESPONSEFR bit in SPR_BRC that will trigger the condition COND_NEED_RESPONSEFR
//		that will be evaluated at next tx_frame_now
//		Values are taken from the tables in initvals.asm
//		e.g. for CCK
//		1Mb/s	(A)	off5=37E
//		2Mb/s	(4)	off5=389
//		5.5Mb/s	(7)	off5=394
//		11Mb/s	(E)	off5=39F
//
send_response:
	jext	COND_RX_ERROR, rx_complete


	/* DISCARDER */
//	sub	1, r54, r54;
//	jg	r54, 0, do_not_discard;
//	orx	0, 0, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3;/* GLOBAL_FLAGS_REG3 = RX_FRAME_DISCARD | (GLOBAL_FLAGS_REG3 & ~RX_FRAME_DISCARD) */
//	jext	COND_TRUE, rx_complete;
//do_not_discard:
	/* DISCARDER END */


	orx	7, 8, 0x000, 0x00E, REG34
	or	[0x01,off2], 0x000, SPR_TME_VAL0
	je	[SHM_CURMOD], 0x000, cck_mod
	orx	10, 5, REG34, [0x01,off2], SPR_TME_VAL0
cck_mod:
	or	[0x02,off2], 0x000, SPR_TME_VAL2
	orx	7, 8, 0x000, 0x000, SPR_TME_VAL4
	or	[RX_FRAME_ADDR2_1,off1], 0x000, SPR_TME_VAL10
	orx	7, 8, 0x0FF, 0x0FF, SPR_TME_MASK10
	or	[RX_FRAME_ADDR2_2,off1], 0x000, SPR_TME_VAL12
	orx	7, 8, 0x0FF, 0x0FF, SPR_TME_MASK12
	or	[RX_FRAME_ADDR2_3,off1], 0x000, SPR_TME_VAL14
	orx	7, 8, 0x0FF, 0x0FF, SPR_TME_MASK14
	or	[SHM_ACKCTSPHYCTL], 0x000, SPR_TXE0_PHY_CTL
no_hw_pwr_ctl:
	srx	1, 0, [SHM_CURMOD], 0x000, REG1
	call	lr1, prep_phy_txctl_with_encoding
	call	lr3, LABEL559
	orx	0, 2, 0x001, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	orx	7, 8, 0x0FF, 0x0FF, SPR_TME_MASK6
	orx	7, 8, 0x000, 0x0D4, SPR_TME_VAL6
	orx	7, 8, 0x000, 0x035, TX_TYPE_SUBTYPE
	je	REG19, TS_PSPOLL, pspoll_frame
// RRR	jext	COND_TRUE, ctl_more_frag
ctl_more_frag:
	or	[SHM_CURMOD], 0x000, REG1
	call	lr0, get_rate_table_duration
	sub	REG34, [SHM_PREAMBLE_DURATION], REG34
	jgs	REG34, [RX_FRAME_DURATION,off1], pspoll_frame
	sub	[RX_FRAME_DURATION,off1], REG34, SPR_TME_VAL8
	jext	COND_TRUE, trigger_cts_ack_transmission
pspoll_frame:
	orx	7, 8, 0x000, 0x000, SPR_TME_VAL8
// TTT 	jnext	0x71, trigger_cts_ack_transmission
// RRR	jext	COND_TRUE, trigger_cts_ack_transmission
trigger_cts_ack_transmission:
	orx	2, 0, 0x002, SPR_BRC, SPR_BRC
// TTT 	je	GPHY_SYM_WAR_FLAG, 0x000, sym_war_txe_ctl
// RRR	jext	COND_TRUE, sym_war_txe_ctl
sym_war_txe_ctl:
	orx	7, 8, 0x040, 0x021, NEXT_TXE0_CTL
send_response_end:
	je	REG19, 0x02D, send_control_frame_to_host
	jext	COND_RX_COMPLETE, rx_complete
	jext	COND_TRUE, state_machine_idle

// ***********************************************************************************************
// HANDLER:	tx_timers_setup
// PURPOSE:	Updates timers informations.
//
// Cleans bit 0x0018 of GLOBAL_FLAGS_REG2. Then if no update needed, exits.
// If update needed, start waiting 2us in state_machine_start.
// If needed by RX clean bit 0x0010 and set bit 0x0008 of GLOBAL_FLAGS_REG2.
// When state_machine_start finishes waiting 2 us, then it will clean bit 0x0018
// of GLOBAL_FLAGS_REG2.
//
tx_timers_setup:
	jzx	0, 8, SPR_BRPO0, 0x000, proceed_with_timer_update
	orx	1, 3, 0x000, GLOBAL_FLAGS_REG2, GLOBAL_FLAGS_REG2
	orx	0, 8, 0x000, SPR_BRPO0, SPR_BRPO0
	orx	0, 15, 0x000, SPR_TSF_GPT0_STAT, SPR_TSF_GPT0_STAT
	orx	0, 15, 0x001, SPR_TSF_GPT0_STAT, SPR_TSF_GPT0_STAT
	jext	COND_TRUE, state_machine_idle
proceed_with_timer_update:
	jnzx	0, 11, SPR_IFS_STAT, 0x000, timers_update_goon
	orx	0, 8, 0x001, SPR_BRPO0, SPR_BRPO0
	jzx	0, 6, GLOBAL_FLAGS_REG2, 0x000, timers_update_goon

	// only STA get here
	call	lr2, LABEL588

timers_update_goon:
	orx	7, 8, 0x040, 0x000, SPR_TSF_GPT2_STAT
	add	SPR_TSF_WORD0, 0x002, [SHM_WAIT2_CLOCK]
	jnzx	0, 7, SPR_RXE_0x1a, 0x000, state_machine_start
	orx	1, 3, 0x001, GLOBAL_FLAGS_REG2, GLOBAL_FLAGS_REG2
	jext	COND_TRUE, state_machine_start

// ***********************************************************************************************
// HANDLER:	rx_plcp
// PURPOSE:	If header was successfully received, extracts from it frame related informations.
//		Current time is stored inside four registers RX_TIME_WORD[0-3]
//		RX_PHY_ENCODING stores the kind of encoding for all the succeeding analysis: 0 is CCK, 1 is OFDM
//		At the beginning switch off the TX engine if it is not
//
rx_plcp:
	jext	EOI(COND_RX_FCS_GOOD), rx_plcp
	orx	7, 8, 0x000, 0x000, GPHY_SYM_WAR_FLAG
	jnzx	0, 2, SPR_RXE_FIFOCTL1, 0x000, state_machine_idle
	jzx	0, 0, SPR_TXE0_CTL, 0x000, sync_rx_frame_time_with_TSF
	orx	7, 8, 0x000, 0x000, SPR_TXE0_CTL
	orx	2, 0, 0x000, SPR_BRC, SPR_BRC
sync_rx_frame_time_with_TSF:
	or	SPR_TSF_WORD0, 0x000, REG31
	or	SPR_TSF_WORD1, 0x000, REG30
	or	SPR_TSF_WORD2, 0x000, REG29
	or	SPR_TSF_WORD3, 0x000, REG28
	jne	REG31, SPR_TSF_WORD0, sync_rx_frame_time_with_TSF
	add	[0x088], 0x001, [0x088]
	srx	0, 13, SPR_RXE_ENCODING, 0x000, REG23
// TTT 	jne	[SHM_PHYTYPE], 0x000, rx_plcp_not_A_phy
// RRR	jext	COND_TRUE, rx_plcp_not_A_phy
rx_plcp_not_A_phy:
	orx	7, 8, 0x000, 0x008, REG34
	call	lr0, sel_phy_reg
	srx	0, 8, [SHM_CHAN], 0x000, REG34
	orx	0, 8, REG34, SPR_Ext_IHR_Data, REG34
	orx	9, 3, REG34, [SHM_PHYTYPE], [SHM_RXHDR_RXCHAN]
	or	SPR_BRC, 0x140, SPR_BRC
	orx	0, 9, 0x000, SPR_BRC, SPR_BRC
	orx	0, 0, 0x000, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
wait_for_header_to_be_received:
	jext	COND_RX_COMPLETE, header_received
	jl	SPR_RXE_FRAMELEN, 0x026, wait_for_header_to_be_received
header_received:
	orx	7, 8, 0x000, 0x000, [SHM_RXHDR_MACST_LOW]
	orx	7, 8, 0x000, 0x000, [SHM_RXHDR_MACST_HIGH]
	jl	SPR_RXE_FRAMELEN, 0x010, rx_too_short
	srx	5, 2, [RX_FRAME_FC,off1], 0x000, REG19
	srx	1, 2, [RX_FRAME_FC,off1], 0x000, REG43
	orx	1, 12, 0x000, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	srx	0, 8, [RX_FRAME_FC,off1], 0x000, REG34
	srx	0, 9, [RX_FRAME_FC,off1], 0x000, REG35
	and	REG34, REG35, REG35
	orx	0, 11, REG35, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	and	REG19, 0x023, REG34
	jne	REG34, 0x022, not_qos_data
	orx	0, 12, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	xor	REG35, 0x001, REG35
	add	SPR_BASE1, SHM_PLCP_MAC3ADDR_HDR_SIZE, SPR_BASE5
	jzx	0, 11, GLOBAL_FLAGS_REG3, 0x000, rx_plcp_not_wds
	add	SPR_BASE5, SHM_MAC_ADDR_SIZE, SPR_BASE5
rx_plcp_not_wds:
	or	[0x00,off5], 0x000, REG33
	jzx	1, 5, [0x00,off5], 0x000, not_qos_data
	orx	0, 13, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
not_qos_data:
	orx	0, 5, REG35, 0x000, SPR_RXE_FIFOCTL1
	jext	COND_RX_RAMATCH, rx_plcp_and_ra_match
	jnzx	0, 15, [RX_FRAME_DURATION,off1], 0x000, check_frame_version_validity
	or	[RX_FRAME_DURATION,off1], 0x000, SPR_NAV_ALLOCATION
	orx	4, 11, 0x002, SPR_NAV_CTL, SPR_NAV_CTL
	jext	COND_TRUE, check_frame_version_validity
rx_plcp_and_ra_match:
	jzx	0, 4, [SHM_HF_LO], 0x000, check_frame_version_validity
	// only on pccard
	orx	0, 8, 0x001, SPR_GPIO_OUT, SPR_GPIO_OUT
check_frame_version_validity:
	jzx	1, 0, [RX_FRAME_FC,off1], 0x000, disable_crypto_engine
	orx	0, 0, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	jext	COND_TRUE, rx_too_short
disable_crypto_engine:
	orx	7, 8, 0x083, 0x000, SPR_WEP_CTL
	orx	1, 0, 0x002, SPR_RXE_FIFOCTL1, SPR_RXE_FIFOCTL1
	je	REG19, TS_ACK, rx_plcp_not_data_frame
	srx	7, 0, [RX_FRAME_PLCP_0,off1], 0x000, REG0
	or	REG23, 0x000, REG1
	call	lr1, get_ptr_from_rate_table
	jne	REG43, 0x002, rx_plcp_not_data_frame
	jext	COND_TRUE, rx_data_plus
rx_plcp_not_data_frame:
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	jnzx	0, 15, SPR_RXE_0x1a, 0x000, rx_fifo_overflow_pre
	jnext	COND_RX_COMPLETE, rx_plcp_not_data_frame
rx_plcp_wait_RXE_x1a:
	jzx	0, 14, SPR_RXE_0x1a, 0x000, rx_plcp_wait_RXE_x1a
	srx	0, 5, SPR_RXE_PHYRXSTAT0, 0x000, [SHM_LAST_RX_ANTENNA]
	jg	SPR_RXE_FRAMELEN, [SHM_MAXPDULEN], rx_complete
	jext	COND_RX_FCS_GOOD, rx_plcp_good_fcs
	call	lr1, check_gphy_sym_war
	je	GPHY_SYM_WAR_FLAG, 0x000, rx_complete
// *** JUMPDOC aspirino linksys03
rx_plcp_good_fcs:
	jne	REG43, 0x000, rx_plcp_control_frame
	je	REG19, TS_BEACON, rx_beacon_probe_resp
	je	REG19, TS_PROBE_RESP, rx_beacon_probe_resp
	je	REG19, TS_PROBE_REQ, send_response_if_ra_match
	jext	COND_TRUE, send_response_if_ra_match
rx_plcp_control_frame:
	je	REG19, TS_ACK, rx_ack
	je	REG19, TS_CTS, rx_ack
	je	REG19, TS_PSPOLL, rx_check_promisc
	jext	COND_TRUE, send_control_frame_to_host

// ***********************************************************************************************
// HANDLER:	rx_too_short
// PURPOSE:	Reports reception error and checks if frame must be kept.
//	
// XXX need rework to report short frames..
rx_too_short:
	orx	0, 9, 0x001, SPR_BRC, SPR_BRC
	jext	COND_TRUE, disable_crypto_engine

// ***********************************************************************************************
// HANDLER:	rx_complete
// PURPOSE:	Completes reception and classifies frame. 
//
rx_complete:
clear_rxe_x1a:
	jzx	0, 14, SPR_RXE_0x1a, 0x000, clear_rxe_x1a
	or	SPR_TSF_0x3e, 0x000, [SHM_RXHDR_MACTIME]
	orx	0, 6, 0x000, SPR_BRC, SPR_BRC
wait_for_rec_completion:
	jnext	EOI(COND_RX_COMPLETE), wait_for_rec_completion
	jnzx	0, 15, SPR_RXE_0x1a, 0x000, rx_fifo_overflow_pre
	jg	SPR_RXE_FRAMELEN, [SHM_MAXPDULEN], rx_too_long
	jext	COND_RX_FCS_GOOD, frame_successfully_received
	jne	GPHY_SYM_WAR_FLAG, 0x000, frame_successfully_received
	orx	0, 9, 0x001, SPR_BRC, SPR_BRC
	orx	0, 1, 0x000, SPR_BRC, SPR_BRC
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	orx	0, 0, 0x001, [SHM_RXHDR_MACST_LOW], [SHM_RXHDR_MACST_LOW]
	orx	0, 0, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	jext	COND_TRUE, send_frame_to_host
frame_successfully_received:
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	jnext	COND_NEED_RESPONSEFR, check_frame_subtype
// TTT 	jzx	0, 13, GLOBAL_FLAGS_REG3, 0x000, need_regular_ack
// RRR	jext	COND_TRUE, need_regular_ack
need_regular_ack:
	je	[SHM_CURMOD], 0x001, ofdm_modulation
	jne	[SHM_CURMOD], 0x000, no_cck_modulation
	jzx	3, 4, [0x01,off2], 0x000, ofdm_modulation
no_cck_modulation:
	srx	0, 7, SPR_RXE_PHYRXSTAT0, 0x000, REG34
	orx	0, 4, REG34, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
ofdm_modulation:
	orx	0, 1, 0x001, [SHM_RXHDR_MACST_LOW], [SHM_RXHDR_MACST_LOW]
	or	NEXT_TXE0_CTL, 0x000, SPR_TXE0_CTL
check_frame_subtype:
	srx	1, 0, REG19, 0x000, REG34
	je	REG34, 0x001, rx_control_frame
	jext	COND_RX_RAMATCH, rx_frame_and_ra_match
	jzx	0, 0, [RX_FRAME_ADDR1_1,off1], 0x000, not_multicast_frame
	jne	REG43, 0x002, rx_not_data_frame_type
	add	[0x094], 0x001, [0x094]
rx_not_data_frame_type:
	jnzx	0, 11, GLOBAL_FLAGS_REG3, 0x000, send_frame_to_host
	jnzx	0, 8, [RX_FRAME_FC,off1], 0x000, discard_frame
	jnzx	0, 9, [RX_FRAME_FC,off1], 0x000, control_frame_from_ds
	jext	COND_RX_BSSMATCH, frame_from_our_BSS
	jext	COND_TRUE, could_be_multicast_frame
// DOC aspirino federer larrybird larrybird_ap linksys03 linksys03_ap panatta pescosolido
control_frame_from_ds:
	jnext	0x62, could_be_multicast_frame
// *** JUMPDOC aspirino federer larrybird linksys03 panatta pescosolido
	je	REG19, TS_BEACON, frame_from_our_BSS
// *** JUMPDOC aspirino federer larrybird linksys03 panatta pescosolido
	orx	0, 6, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
// DOC aspirino federer larrybird linksys03 panatta pescosolido
frame_from_our_BSS:
	je	REG19, TS_PROBE_REQ, send_frame_to_host
// *** JUMPDOC aspirino federer larrybird linksys03 panatta pescosolido
	jext	COND_TRUE, LABEL345
not_multicast_frame:
	jnext	0x3D, check_frame_type
	jnext	0x62, check_frame_type
// *** JUMPDOC aspirino federer larrybird linksys03 panatta pescosolido
	orx	0, 6, 0x000, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
check_frame_type:
	jne	REG43, 0x002, not_data_frame_and_ra_doesnt_match
	add	[0x08F], 0x001, [0x08F]
	jext	COND_TRUE, data_frame_and_ra_doesnt_match
could_be_multicast_frame:
	je	REG43, 0x002, data_frame_and_ra_doesnt_match
	jnzx	0, 0, [RX_FRAME_ADDR3_1,off1], 0x000, send_frame_to_host
not_data_frame_and_ra_doesnt_match:
	jzx	0, 4, SPR_MAC_CTLHI, 0x000, data_frame_and_ra_doesnt_match
// *** JUMPDOC aspirino federer larrybird linksys03 panatta pescosolido
	je	REG19, TS_BEACON, send_frame_to_host
// *** JUMPDOC aspirino federer larrybird linksys03 panatta pescosolido
	je	REG19, TS_PROBE_RESP, send_frame_to_host
// *** JUMPDOC aspirino federer larrybird linksys03 panatta pescosolido
data_frame_and_ra_doesnt_match:
// TTT 	jzx	0, 8, SPR_MAC_CTLHI, 0x000, discard_frame
	jext	COND_TRUE, discard_frame
rx_control_frame:
	jnext	COND_RX_RAMATCH, send_frame_to_host
	je	REG19, 0x02D, LABEL345
	je	REG19, TS_PSPOLL, LABEL345
	jext	COND_TRUE, send_frame_to_host
rx_frame_and_ra_match:
// TTT 	jzx	0, 11, GLOBAL_FLAGS_REG3, 0x000, not_wds_frame
// RRR	jext	COND_TRUE, not_wds_frame
not_wds_frame:
	jnext	COND_FRAME_NEED_ACK, LABEL343
	srx	5, 2, [TXHDR_FCTL,off0], 0x000, REG36
// TTT 	jne	REG36, 0x029, LABEL343
// RRR	jext	COND_TRUE, LABEL343
LABEL343:
	je	REG19, 0x000, send_frame_to_host
	je	REG19, 0x008, send_frame_to_host
	je	REG19, 0x02C, send_frame_to_host
LABEL345:
	or	[RX_FRAME_ADDR2_1,off1], 0x000, SPR_PMQ_pat_0
	or	[RX_FRAME_ADDR2_2,off1], 0x000, SPR_PMQ_pat_1
	or	[RX_FRAME_ADDR2_3,off1], 0x000, SPR_PMQ_pat_2
	srx	0, 12, [RX_FRAME_FC,off1], 0x000, REG34
	add	REG34, 0x001, SPR_PMQ_dat
	or	[0x016], 0x000, SPR_PMQ_control_low
	or	SPR_PMQ_control_low, 0x000, 0x000
	srx	5, 9, SPR_PMQ_control_high, 0x000, REG34
// TTT 	jle	REG34, [0x015], send_frame_to_host
// RRR	
	jext	COND_TRUE, send_frame_to_host

// ***********************************************************************************************
// HANDLER:	send_frame_to_host
// PURPOSE:	Prepares the frame before sending it to the host.
//
send_frame_to_host:
	jnzx	0, 0, GLOBAL_FLAGS_REG3, 0x000, discard_frame
	or	SPR_RXE_FRAMELEN, 0x000, REG34
	or	REG34, 0x000, [SHM_RXHDR_FLEN]
	jzx	0, 5, SPR_RXE_FIFOCTL1, 0x000, no_hdr_length_update
	add	REG34, [SHM_RXPADOFF], [SHM_RXHDR_FLEN]
	orx	0, 2, 0x001, [SHM_RXHDR_MACST_LOW], [SHM_RXHDR_MACST_LOW]
no_hdr_length_update:
	srx	0, 4, GLOBAL_FLAGS_REG3, 0x000, REG34
	orx	0, 15, REG34, [SHM_RXHDR_MACST_LOW], [SHM_RXHDR_MACST_LOW]
wait_crypto_engine:
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	jext	COND_RX_CRYPTBUSY, wait_crypto_engine
	srx	0, 15, SPR_WEP_CTL, 0x000, REG34
	orx	0, 4, REG34, [SHM_RXHDR_MACST_LOW], [SHM_RXHDR_MACST_LOW]
	or	SPR_RXE_PHYRXSTAT0, 0x000, [SHM_RXHDR_PHYST0]
	or	SPR_RXE_PHYRXSTAT1, 0x000, [SHM_RXHDR_PHYST1]
	or	SPR_RXE_PHYRXSTAT2, 0x000, [SHM_RXHDR_PHYST2]
	or	SPR_RXE_PHYRXSTAT3, 0x000, [SHM_RXHDR_PHYST3]
	srx	0, 5, SPR_RXE_PHYRXSTAT0, 0x000, [SHM_LAST_RX_ANTENNA]
	orx	7, 8, 0x0FF, 0x0FE, ANTENNA_DIVERSITY_CTR
	call	lr1, antenna_diversity_helper
	call	lr0, push_frame_into_fifo
	nand	SPR_RXE_FIFOCTL1, 0x002, SPR_RXE_FIFOCTL1
	jext	COND_TRUE, tx_contention_params_update

// ***********************************************************************************************
// HANDLER:	rx_too_long
// PURPOSE:	Reports reception error.	
//
rx_too_long:
	add	[0x082], 0x001, [0x082]
LABEL351:
	orx	0, 8, 0x001, SPR_BRC, SPR_BRC
	orx	0, 9, 0x001, SPR_BRC, SPR_BRC
	jext	COND_TRUE, discard_frame

// ***********************************************************************************************
// HANDLER:	rx_ack
// PURPOSE:i	Performs operations related to ACK reception.	
//
rx_ack:
	jnext	COND_RX_RAMATCH, LABEL359
	add	[0x08E], 0x001, [0x08E]
// RRR	jext	COND_TRUE, LABEL354
LABEL354:
	jnext	COND_FRAME_NEED_ACK, send_control_frame_to_host
	jne	REG19, EXPECTED_CTL_RESPONSE, send_control_frame_to_host
	orx	0, 15, 0x000, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 8, 0x000, SPR_BRC, SPR_BRC
	or	REG34, 0x000, REG34
	jle	0x000, 0x001, flush_pipe
// RRR	jext	COND_TRUE, flush_pipe
flush_pipe:
	jext	EOI(COND_TX_PMQ), LABEL356
LABEL356:
// TTT 	jzx	0, 10, [0x02,off0], 0x000, send_control_frame_to_host
	jext	COND_TRUE, send_control_frame_to_host
LABEL359:
	jne	REG19, TS_CTS, send_control_frame_to_host
	add	[0x093], 0x001, [0x093]
	jext	COND_TRUE, send_control_frame_to_host

// ***********************************************************************************************
// HANDLER:	send_control_frame_to_host
// PURPOSE:	Decides if control frame must be sent to host.	
//
send_control_frame_to_host:
	jext	COND_RX_RAMATCH, send_control_frame_and_ra_match
// TTT 	jzx	0, 8, SPR_MAC_CTLHI, 0x000, rx_discard_frame
	jext	COND_TRUE, rx_discard_frame
send_control_frame_and_ra_match:
	jnzx	0, 6, SPR_MAC_CTLHI, 0x000, rx_complete
	jext	COND_TRUE, rx_discard_frame

// ***********************************************************************************************
// HANDLER:	rx_check_promisc
// PURPOSE:	Controls if promiscuous mode was enable.	
//
rx_check_promisc:
	jnzx	0, 8, SPR_MAC_CTLHI, 0x000, rx_complete

// ***********************************************************************************************
// HANDLER:	rx_discard_frame	
// PURPOSE:	Commands a frame discard.
//
rx_discard_frame:
	orx	0, 0, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	jext	COND_TRUE, rx_complete

// ***********************************************************************************************
// HANDLER:	rx_data_plus
// PURPOSE:	Manages data frame reception.	
//
rx_data_plus:
	jext	COND_RX_COMPLETE, end_rx_data_plus
	jl	SPR_RXE_FRAMELEN, 0x01C, rx_data_plus
end_rx_data_plus:
	jl	SPR_RXE_FRAMELEN, 0x01C, rx_check_promisc
	jnext	COND_RX_RAMATCH, rx_ra_dont_match
	jext	COND_TRUE, send_response

// ***********************************************************************************************
// HANDLER:	tx_underflow	
// PURPOSE:	Prepares device for TX underflow error management.	
//
// XXX

// ***********************************************************************************************
// HANDLER:	tx_fifo_underflow
// PURPOSE:	Manages TX underflow error.	
//
// XXX

	// for my memory only larrybird linksys03 pescosolido execute the following
	// though the linksys is that it reveals executing the code after the jumps
tx_clear_issues:
	orx	7, 8, 0x000, 0x001, REG36

tx_dont_clear_issues:
	jnext	COND_FRAME_NEED_ACK, check_underflow_cond

	// for my memory only linksys as STA execute the following
	orx	0, 7, 0x000, SPR_BRC, SPR_BRC
	orx	7, 8, 0x000, 0x000, EXPECTED_CTL_RESPONSE
	orx	0, 15, 0x000, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 4, 0x000, SPR_BRC, SPR_BRC
	call	lr1, set_backoff_time
check_underflow_cond:
	extcond_eoi_only(COND_TX_POWER)
	extcond_eoi_only(COND_TX_NOW)
	orx	0, 5, 0x000, SPR_BRC, SPR_BRC
	extcond_eoi_only(COND_TX_UNDERFLOW)
	orx	7, 8, 0x000, 0x000, SPR_TXE0_SELECT
	orx	7, 8, 0x000, 0x007, REG34
	je	[SHM_PHYTYPE], 0x000, end_tx_fifo_underflow
	orx	0, 10, SPR_TXE0_PHY_CTL, REG34, REG34
end_tx_fifo_underflow:
	call	lr0, sel_phy_reg
	or	SPR_Ext_IHR_Data, 0x000, REG38
	orx	7, 8, 0x0FF, 0x0FF, REG35
	call	lr0, write_phy_reg
	xor	REG34, REG37, REG34
	call	lr0, write_phy_reg
	je	REG36, 0x000, state_machine_idle
	or	REG38, 0x000, [TXHDR_RTSPHYSTAT,off0]
	jext	COND_TRUE, suppress_this_frame

// ***********************************************************************************************
// HANDLER:	tx_phy_error
// PURPOSE:	Manages TX phy errors.
//
// XXX
// DOC larrybird linksys03 pescosolido
tx_phy_error:
// TTT 	jext	COND_FRAME_BURST, check_rx_conditions
	jext	COND_TRUE, check_rx_conditions

// ***********************************************************************************************
// HANDLER:	rx_fifo_overflow
// PURPOSE:	Manages RX overflow error.	
//		Is the first instruction useful to clear some hardware exception? Can be safely removed?
//
// This code seems to be useful only on pccard
rx_fifo_overflow_pre:
	orx	0, 6, 0x000, SPR_BRC, SPR_BRC

rx_fifo_overflow:
overflow_frame_too_long:
	jext	COND_REC_IN_PROGRESS, rx_complete
	extcond_eoi_only(COND_RX_FIFOFULL)
	orx	0, 9, 0x001, SPR_BRC, SPR_BRC
	jext	COND_TRUE, discard_frame


// ***********************************************************************************************
// HANDLER:	mac_suspend_check	
// PURPOSE:	Checks if device can be suspended.
//		The condition on SPR_BRC involves
//		COND_NEED_RESPONSEFR|COND_FRAME_BURST|COND_REC_IN_PROGRESS|COND_FRAME_NEED_ACK
//
mac_suspend_check:
	jnand	0x0E2, SPR_BRC, check_conditions
	jnzx	0, 8, SPR_IFS_STAT, 0x000, check_conditions
	jext	COND_TX_DONE, check_conditions
	jnzx	0, 8, SPR_IFS_STAT, 0x000, check_conditions
	jext	COND_TX_DONE, check_conditions
	jext	COND_TX_PHYERR, check_conditions
	call	lr0, flush_and_stop_tx_engine

// ***********************************************************************************************
// HANDLER:	mac_suspend	
// PURPOSE:	Suspends device.
//		
mac_suspend:
	orx	7, 8, 0x000, 0x001, SPR_MAC_IRQLO
	orx	0, 15, 0x000, SPR_TSF_GPT0_STAT, SPR_TSF_GPT0_STAT
	orx	7, 8, 0x000, 0x003, [SHM_UCODESTAT]
	orx	7, 8, 0x003, 0x003, SPR_WEP_0x50
wait_for_mac_to_disable:
	jnext	COND_MACEN, wait_for_mac_to_disable
	orx	7, 8, 0x000, 0x002, [SHM_UCODESTAT]
	orx	7, 8, 0x003, 0x0B4, [0x05F]
	orx	7, 8, 0x003, 0x0B4, [0x05E]
	srx	0, 15, SPR_MAC_CTLHI, 0x000, GLOBAL_FLAGS_REG1
	orx	7, 8, 0x003, 0x001, SPR_WEP_0x50
	orx	7, 8, 0x083, 0x000, SPR_WEP_CTL

	orx	7, 8, 0x000, 0x000, SPR_BRC
	nand	GLOBAL_FLAGS_REG2, 0x01A, GLOBAL_FLAGS_REG2
	orx	7, 8, 0x0FF, 0x0FF, SPR_BRCL0
	orx	7, 8, 0x0FF, 0x0FF, SPR_BRCL1
	orx	7, 8, 0x0FF, 0x0FF, SPR_BRCL2
	orx	7, 8, 0x0FF, 0x0FF, SPR_BRCL3
	orx	0, 2, 0x001, SPR_RXE_FIFOCTL1, SPR_RXE_FIFOCTL1
wait_RXE_FIFOCTL1_cond_to_clear:
	jnzx	0, 2, SPR_RXE_FIFOCTL1, 0x000, wait_RXE_FIFOCTL1_cond_to_clear
	orx	0, 15, 0x001, SPR_TSF_GPT0_STAT, SPR_TSF_GPT0_STAT
	orx	7, 8, 0x000, 0x000, SPR_BRCL0
	orx	7, 8, 0x000, 0x000, SPR_BRCL1
	orx	7, 8, 0x000, 0x000, SPR_BRCL2
	orx	7, 8, 0x000, 0x000, SPR_BRCL3
	orx	7, 8, 0x003, 0x001, [0x017]
	srx	0, 13, SPR_MAC_CTLHI, 0x000, REG34
	orx	0, 4, REG34, [0x017], [0x017]
	srx	0, 14, SPR_MAC_CTLHI, 0x000, REG34
	xor	REG34, 0x001, REG34
	orx	0, 1, REG34, 0x000, [0x016]

	orx	7, 8, 0x073, 0x060, SPR_BRWK0
	orx	7, 8, 0x000, 0x000, SPR_BRWK1
	orx	7, 8, 0x073, 0x00F, SPR_BRWK2
	orx	7, 8, 0x000, 0x057, SPR_BRWK3
	jext	COND_TRUE, state_machine_start

// ***********************************************************************************************
// HANDLER:	rx_badplcp	
// PURPOSE:	Manages reception of a frame with not valid PLCP.
//
// Will set bit 0x0010 of GLOBAL_FLAGS_REG2
rx_badplcp:
	jnzx	0, 11, SPR_RXE_0x1a, 0x000, state_machine_idle
	jnzx	0, 12, SPR_RXE_0x1a, 0x000, rx_badplcp
	orx	0, 4, 0x001, GLOBAL_FLAGS_REG2, GLOBAL_FLAGS_REG2
	add	[0x086], 0x001, [0x086]
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	jnzx	0, 15, SPR_RXE_0x1a, 0x000, rx_fifo_overflow
update_RXE_FIFOCTL1_value:
	orx	7, 8, 0x000, 0x004, SPR_RXE_FIFOCTL1
	or	SPR_RXE_FIFOCTL1, 0x000, REG34
	jext	COND_TRUE, state_machine_start

// ***********************************************************************************************
// HANDLER:	discard_frame	
// PURPOSE:	Discards the frame into the FIFO.
//
// if calling flush_and_stop_tx_engine then set bit 0x1000 of GLOBAL_FLAGS_REG1
// NOTE interesting the SPR_RXE_FIFOCTL1 should be read even not assigned
// Will set bit 0x1000 of GLOBAL_FLAGS_REG1
discard_frame:
	orx	7, 8, 0x000, 0x014, SPR_RXE_FIFOCTL1
	or	SPR_RXE_FIFOCTL1, 0x000, 0x000
	srx	2, 5, SPR_WEP_CTL, 0x000, REG34
	jnext	COND_RX_ERROR, tx_contention_params_update
	orx	0, 12, 0x001, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	call	lr0, flush_and_stop_tx_engine
	orx	0, 0, 0x001, SPR_TXE0_AUX, SPR_TXE0_AUX
	or	REG34, 0x000, REG34
	orx	0, 0, 0x000, SPR_TXE0_AUX, SPR_TXE0_AUX
	jext	COND_TRUE, tx_contention_params_update

// ***********************************************************************************************
// HANDLER:	flush_and_stop_tx_engine	
// PURPOSE:	Checks if there are any other frames into the queue, flushes the TX engine and stops it.
//
// With respect to 5.2 the WEP conditional jump was removed (I'm removing WEP support).
// Currently I switch back to Broadcom style for going back to caller (but it "sucks")
//
// May clear both bits 0x2000 | 0x1000 of GLOBAL_FLAGS_REG1
flush_and_stop_tx_engine:
	orx	7, 8, 0x040, 0x000, SPR_TXE0_CTL
	or	SPR_TXE0_CTL, 0x000, 0x000
	jle	0x000, 0x001, check_pending_tx_and_stop
check_pending_tx_and_stop:
	jnext	EOI(COND_TX_NOW), pending_tx_resolved
	// not all device jump above:
	// for my memory only the following devices may jump to tx_frame_now
	// AP = [aspirino_ap larrybird_ap linksys03_ap]
	// STA = [larrybird linksys03 pescosolido]
	jext	COND_TRUE, tx_frame_now
pending_tx_resolved:
	nand	SPR_BRC, 0x027, SPR_BRC
	orx	7, 8, 0x000, 0x000, SPR_TXE0_SELECT
	orx	0, 15, 0x000, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 4, 0x000, SPR_BRC, SPR_BRC
	orx	1, 12, 0x000, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	ret	lr0, lr0

// ***********************************************************************************************
// HANDLER:	rx_beacon_probe_resp	
// PURPOSE:	Analyzes Beacon or Probe Response frame that has been received. Important for time synchronization.
//		off3 is a pointer that has been load before by get_ptr_from_rate_table with a value coming
//		from the second level rate tables, e.g., on a beacon in 2.4MHz off3 = 0x37E
//
// Question: who is setting SHM_TBL_OFF2DUR? SHM(0x038) /* Offset to duration in second level rate tables */
// Maybe initvals. TBC
// NOTE: a lot of stuff was removed with respect to 5.2.
// NOTE: bit 0x0040 of GLOBAL_FLAGS_REG3 tells if the last received beacon was carrying a DTIM saying there is multicast or broadcast
//       traffic in the AP queue (not sure)
rx_beacon_probe_resp:
	jl	SPR_RXE_FRAMELEN, 0x02C, rx_discard_frame

	// STA may jump here, AP NEVER!
	jext	COND_RX_BSSMATCH, rx_bss_match

	// STA and AP can get here
	jext	COND_TRUE, no_time_informations

rx_bss_match:
	// from here on only STA
	je	REG19, TS_PROBE_RESP, check_beacon_time
	jext	0x3E, rx_beacon_probe_resp_end

check_beacon_time:
	jext	0x3E, rx_beacon_probe_resp_end
	or	[SHM_TBL_OFF2DUR], 0x000, REG34
	add	REG34, [0x00,off3], REG34
	add.	REG31, REG34, REG31
	addc.	REG30, 0x000, REG30
	addc.	REG29, 0x000, REG29
	addc	REG28, 0x000, REG28

	// an old jump from 5.2: but in STA mode it always jump, the old code
	// was removed
	// jext	0x3D, sync_TSF
	// REMOVED

sync_TSF:
	or	SPR_TSF_WORD0, 0x000, [SHM_RX_TIME_WORD0]
	or	SPR_TSF_WORD1, 0x000, [SHM_RX_TIME_WORD1]
	or	SPR_TSF_WORD2, 0x000, [SHM_RX_TIME_WORD2]
	or	SPR_TSF_WORD3, 0x000, [SHM_RX_TIME_WORD3]
	jne	[SHM_RX_TIME_WORD0], SPR_TSF_WORD0, sync_TSF
	sub.	[SHM_RX_TIME_WORD0], REG31, REG31
	subc.	[SHM_RX_TIME_WORD1], REG30, REG30
	subc.	[SHM_RX_TIME_WORD2], REG29, REG29
	subc	[SHM_RX_TIME_WORD3], REG28, REG28
update_TSF_words:
	add.	REG31, [RX_FRAME_BCN_TIMESTAMP_0,off1], REG34
	or	REG34, 0x000, SPR_TSF_WORD0
	addc.	REG30, [RX_FRAME_BCN_TIMESTAMP_1,off1], SPR_TSF_WORD1
	addc.	REG29, [RX_FRAME_BCN_TIMESTAMP_2,off1], SPR_TSF_WORD2
	// in 5.2 we are using addc. instead of addc here below
	addc	REG28, [RX_FRAME_BCN_TIMESTAMP_3,off1], SPR_TSF_WORD3
	jne	REG34, SPR_TSF_WORD0, update_TSF_words
	jnext	0x3D, rx_beacon_probe_resp_end
no_time_informations:

	// ap can get here: we should check CF (contention free) info if interested in this point
	je	REG19, TS_PROBE_RESP, rx_beacon_probe_resp_end

	// ZZZ 0xA32 in SPR_BASE5, andrebbe ricodificato come SPR_BASE1 + SHM_OFFSET(0x2A)
	mov	SHM_BEACON_DATA, SPR_BASE5
	jnext	0x3D, rx_beacon_probe_resp_end
	jext	0x3E, rx_beacon_probe_resp_end

	// following code not executed on AP
	je	REG19, TS_PROBE_RESP, rx_beacon_probe_resp_end
	jnext	COND_RX_BSSMATCH, rx_beacon_probe_resp_end
	// find TIM data in beacon (tag number 5)
	orx	7, 8, 0x000, 0x005, REG37
	call	lr0, find_beacon_info_elem
	// not found!
	jne	REG37, 0x005, rx_beacon_probe_resp_end
	jzx	0, 15, SPR_BASE5, 0x000, load_tim_from_even_addr
	srx	7, 8, [0x01,off5], 0x000, CURRENT_DTIM_COUNTER
	srx	7, 8, [0x02,off5], 0x000, REG34
	jext    COND_TRUE, tim_loaded
load_tim_from_even_addr:
	srx	7, 0, [0x01,off5], 0x000, CURRENT_DTIM_COUNTER
	srx	7, 0, [0x02,off5], 0x000, REG34
tim_loaded:
	// I'm not sure here TBC
	// CURRENT_DTIM_COUNTER should be the DTIM_COUNTER
	// REG34 should be the Bitmap Control whose lsb set to 1 tells that
	// there is broadcast or multicast traffic for some station
	// Remember in bit 0x0040 of GLOBAL_FLAGS_REG3 and copy its value
	// in bit 0x8000 of SPR_TSF_GPT1_STAT (this should avoid sleeping
	// like we do for TBTT)
	orx	0, 6, REG34, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	orx	0, 15, REG34, SPR_TSF_GPT1_STAT, SPR_TSF_GPT1_STAT
rx_beacon_probe_resp_end:
	jext	COND_RX_RAMATCH, send_response
	jext	COND_TRUE, rx_complete

// ***********************************************************************************************
// HANDLER:	send_response_if_ra_match
// PURPOSE:	Decides if frame needs a response.
//
send_response_if_ra_match:
	jext	COND_RX_RAMATCH, send_response
rx_ra_dont_match:
	jzx	0, 0, [RX_FRAME_ADDR1_1,off1], 0x000, rx_check_promisc
	jext	COND_TRUE, rx_complete

// ***********************************************************************************************
// HANDLER:	slow_clock_control
// PURPOSE:	Updates SCC.
//
// This operation is skipped if
// 1) bit 0x0004 of GLOBAL_FLAGS_REG3 is not zero
// 2) bit 0x0002 of SPR_SCC_Control is not zero
// 3) something is being handled by the state machine (jnand on SPR_BRC)
// When executed, set bit 0x0004 of GLOBAL_FLAGS_REG3 to 1 (0x0004)
// so that the operation is not repeated until the same bit is cleared by someone else.
// Unfortunately it seems that no one will ever clear this bit!!
// Does this mean that we perform SCC just once?
slow_clock_control:
	// this seems to be useless since we clear bit 0x8000 that is initially zero and never set to 1 (0x8000)
	//orx	0, 15, 0x000, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	jnand	0x0FF, SPR_BRC, state_machine_idle
	jnzx	0, 2, GLOBAL_FLAGS_REG3, 0x000, skip_scc_update
	jnzx	0, 1, SPR_SCC_Control, 0x000, state_machine_idle
	orx	14, 1, SPR_SCC_Timer_Low, 0x000, SPR_SCC_Period_Divisor
	srx	0, 15, SPR_SCC_Timer_Low, 0x000, REG34
	orx	14, 1, SPR_SCC_Timer_High, REG34, SPR_SCC_Period
	orx	0, 2, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
skip_scc_update:
	jext	COND_TRUE, state_machine_idle

/* --------------------------------------------------- FUNCTIONS ---------------------------------------------------------- */


// ***********************************************************************************************
// FUNCTION:	push_frame_into_fifo
// PURPOSE:	Copies received frame into the RX host queue.
//
// Tells the host that a new packet is available at RX raising a IRQ on IRQLO
push_frame_into_fifo:
	mov	SHM_RXHDR, SPR_RXE_RXHDR_OFFSET
	mov	SHM_RXHDR_LEN, SPR_RXE_RXHDR_LEN
	orx	1, 0, 0x001, SPR_RXE_FIFOCTL1, SPR_RXE_FIFOCTL1
wait_rx_fifo_1:
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	jnext	COND_RX_FIFOBUSY, wait_rx_fifo_1
wait_rx_fifo_2:
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	jext	COND_RX_FIFOBUSY, wait_rx_fifo_2
	or	REG34, 0x000, REG34
	jle	0x000, 0x001, check_rx_fifo_overflow
check_rx_fifo_overflow:
	jext	COND_RX_FIFOFULL, rx_fifo_overflow
	orx	7, 8, 0x001, 0x000, SPR_MAC_IRQLO
	ret	lr0, lr0

// ***********************************************************************************************
// FUNCTION:	load_tx_header_into_shm
// PURPOSE:	Loads BCM header into SHM.
//
// Since we are fetching packets from one queue only we can assign
// SPR_BASE0 immediately.
// NOTE: header is copied actually only if bit 0x0002 of TXHDR_HK4 is zero
// After the copy it is initialized to 1 (TXHDR_HK4 |= 0x0002)
// so that calling this function again does not overwrite the header
// and the temporary information stored during the access attempt.
// The bit will be cleared by report_tx_status_to_host at the end
// of the current transmission.
load_tx_header_into_shm:
	mov	SHM_TXHEADER, SPR_BASE0
	mov	0x0000, REG34
	jnzx	0, 1, [TXHDR_HK4,off0], 0x000, load_tx_hdr_done
	orx	0, 14, 0x001, [SHM_TXFCUR], SPR_TXE0_FIFO_CMD
	sl	SPR_BASE0, 0x001, SPR_TXE0_TX_SHM_ADDR
	or	[SHM_TXFCUR], 0x000, SPR_TXE0_SELECT
	mov	TXHDR_LEN, SPR_TXE0_TX_COUNT
	or	[SHM_TXFCUR], 0x005, SPR_TXE0_SELECT
load_hdr_wait_for_tx_engine:
	jnext	COND_TX_BUSY, load_hdr_wait_for_tx_engine
load_hdr_wait_for_tx_engine_again:
	jext	COND_TX_BUSY, load_hdr_wait_for_tx_engine_again
	orx	1, 0, 0x002, [TXHDR_HK4,off0], [TXHDR_HK4,off0]
	jzx	0, 3, [TXHDR_MACLO,off0], 0x000, load_tx_hdr_done
	nand	[TXHDR_HK5,off0], 0x018, [TXHDR_HK5,off0]
load_tx_hdr_done:
	ret	lr3, lr3

// ***********************************************************************************************
// FUNCTION:	inhibit_sleep_at_tbtt
// PURPOSE:	Forces device to not sleep at TBTT. If DTIM counter goes zero
//              reset it back.
//
// Execute only on STA, never on AP
// Question: who initialize SHM_NOSLPZNATDTIM? SHM(0x04C)
inhibit_sleep_at_tbtt:
	orx	7, 8, 0x000, 0x004, SPR_MAC_IRQLO
	sub	CURRENT_DTIM_COUNTER, 0x001, CURRENT_DTIM_COUNTER
	jges	CURRENT_DTIM_COUNTER, 0x000, LABEL53
	sub	[SHM_DTIMPER], 0x001, CURRENT_DTIM_COUNTER
LABEL53:
	extcond_eoi_only(COND_TX_TBTTEXPIRE)
	sl	[SHM_NOSLPZNATDTIM], 0x003, SPR_TSF_GPT1_CNTLO
	sr	[SHM_NOSLPZNATDTIM], 0x00D, SPR_TSF_GPT1_CNTHI
	orx	7, 8, 0x0C0, 0x000, SPR_TSF_GPT1_STAT
	ret	lr0, lr0

// ***********************************************************************************************
// FUNCTION:	sel_phy_reg
// PURPOSE:	Selects a phy register.
//
sel_phy_reg:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x000, sel_phy_reg
	orx	0, 12, 0x001, REG34, SPR_Ext_IHR_Address
wait_sel_phy_cond_to_clear:
	jnzx	0, 12, SPR_Ext_IHR_Address, 0x000, wait_sel_phy_cond_to_clear
	or	REG34, 0x000, REG34
	ret	lr0, lr0

// ***********************************************************************************************
// FUNCTION:	write_phy_reg
// PURPOSE:	Writes the value contained in GP_REG6 into phy register. 
//
write_phy_reg:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x000, write_phy_reg
	or	REG35, 0x000, SPR_Ext_IHR_Data
	orx	0, 13, 0x001, REG34, SPR_Ext_IHR_Address
	jnzx	0, 3, GLOBAL_FLAGS_REG1, 0x000, end_write_phy_reg
wait_write_phy_cond_to_clear:
	jnzx	0, 13, SPR_Ext_IHR_Address, 0x000, wait_write_phy_cond_to_clear
end_write_phy_reg:
	or	REG34, 0x000, REG34
	ret	lr0, lr0

// ***********************************************************************************************
// FUNCTION:	get_ptr_from_rate_table
// PURPOSE:	Makes pointer refers to the correct preamble informations.
//		It takes the rate in GP_REG0 and the control in GP_REG1
//		rate values (from the b43 driver, xmit.c)
//
//		cck  at [1, 2, 5, 11] => [ 0x0A, 0x14, 0x37, 0x6E ]
//		ofdm at [6, 9, 12, 18, 24, 36, 48, 54] => [0xB, 0xF, 0xA, 0xE, 0x9, 0xD, 0x8, 0xC]
//
//		e.g. on reception of a beacon we have gp_reg0 = 0x0A and gp_reg1 = 0x00
//
get_ptr_from_rate_table:
	orx	7, 8, 0x000, 0x014, [SHM_PREAMBLE_DURATION]
	orx	11, 4, 0x000, REG0, REG0
	je	[SHM_PHYTYPE], 0x000, get_ptr_from_rate_table_ofdm
	jzx	1, 0, REG1, 0x000, get_ptr_from_rate_table_cck
get_ptr_from_rate_table_ofdm:
	orx	7, 8, 0x000, 0x0F0, REG34
	add	REG0, REG34, SPR_BASE5
	orx	7, 8, 0x000, 0x0E0, REG34
	add	REG0, REG34, SPR_BASE4
	orx	7, 8, 0x000, 0x001, [SHM_CURMOD]
	jext	COND_TRUE, get_ptr_from_rate_table_out
get_ptr_from_rate_table_cck:
	orx	7, 8, 0x001, 0x010, REG34
	add	REG0, REG34, SPR_BASE5
	orx	7, 8, 0x001, 0x000, REG34
	add	REG0, REG34, SPR_BASE4
	orx	7, 8, 0x000, 0x0C0, [SHM_PREAMBLE_DURATION]
	orx	7, 8, 0x000, 0x000, [SHM_CURMOD]
get_ptr_from_rate_table_out:
	or	[0x00,off5], 0x000, SPR_BASE2
	or	[0x00,off4], 0x000, SPR_BASE3
	ret	lr1, lr1

// ***********************************************************************************************
// FUNCTION:	find_beacon_info_elem
// PURPOSE:	Extracts TAG informations from Beacon frame.
//
// First determine the end of the received beacon
// (depends on the frame length and how much of the packet is buffered in shm)
// Then loop using SPR_BASE5 (initially it points to byte 36 after the first byte
// of the beacon payload, not plcp: that is 24(MAC) + 12(TS) = 36(beginning of
// tagged parameters)
// REG37: first time is 4, then retry with 5
// Attention: SPR_BASE5 may have bit 0x8000 as results of consecutive rr ops.
// In that case it points to an odd address (very strange!) hence
// the check before extract REG34 (type) and REG35 (length of type).
// When an element whose type is equal to the one passed in REG37
// then set R34 with the address of next element and if the next
// is within the received buffered beacon leave REG37 unchanged.
// In all other cases set REG37 = -1 (0xffff).
// NOTE: RR is rotate right, lsb re-enters on the left
//
find_beacon_info_elem:
	sub	SPR_RXE_FRAMELEN, 0x004, REG34
	or	SPR_RXE_Copy_Length, 0x000, REG36
	jl	REG34, REG36, align_offset_1
	sr	REG36, 0x001, REG36
	jext	COND_TRUE, align_offset_2
align_offset_1:
	sr	REG34, 0x001, REG36
align_offset_2:
	add	REG36, SPR_RXE_Copy_Offset, REG36
loop_inside_beacon_infos:
	// REG36 end of data
	// REG34 current pointer from SPR_BASE5, when REG34 > REG36 exit
	orx	14, 0, SPR_BASE5, 0x000, REG34
	jge	REG34, REG36, update_return_value
	jnzx	0, 15, SPR_BASE5, 0x000, extract_beacon_informations
	srx	7, 0, [0x00,off5], 0x000, REG34
	srx	7, 8, [0x00,off5], 0x000, REG35
	jext	COND_TRUE, compute_oper_on_infos
extract_beacon_informations:
	srx	7, 8, [0x00,off5], 0x000, REG34
	srx	7, 0, [0x01,off5], 0x000, REG35
compute_oper_on_infos:
	jge	REG34, REG37, finish_operations_on_beacon
	rr	REG35, 0x001, REG35
	add.	SPR_BASE5, REG35, SPR_BASE5
	addc.	SPR_BASE5, 0x001, SPR_BASE5
	jext	COND_TRUE, loop_inside_beacon_infos
finish_operations_on_beacon:
	jne	REG34, REG37, update_return_value
	// never seen an AP executing the following code
	rr	REG35, 0x001, REG35
	add.	SPR_BASE5, REG35, REG34
	addc.	REG34, 0x001, REG34
	orx	14, 0, REG34, 0x000, REG34
	// it seems to always jump, however we left conditional jump
	jle	REG34, REG36, end_find_beacon_info_elem
update_return_value:
	mov	0xFFFF, REG37
end_find_beacon_info_elem:
	ret	lr0, lr0

// ***********************************************************************************************
// FUNCTION:	prep_phy_txctl_with_encoding	
// PURPOSE:	Sets PHY parameters correctly according to the transmission needs.
//
// No POWER CONTROL here. We should add
//	1) check if power control is in use, bit 0x0200 of SPR_TXE0_PHY_CTL
//	2) refresh SHM_LAST_RX_ANTENNA in bit 0x0300 of SPR_TXE0_PHY_CTL
//	3) check if power control is requested by user, bit 0x0080 of SHM_HF_MI
//	4) refresh bits 0xFC00 of SPR_TXE0_PHY_CTL with (values in SHM_TXPWRCUR summed with [0x07,off5]) shifted left 10 times
//
// NOTE the second code entry is useless since we do not handle power control but we leave it here as future entry
prep_phy_txctl_with_encoding:
	orx	1, 0, REG1, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
prep_phy_txctl_encoding_already_set:
	ret	lr1, lr1

// ***********************************************************************************************
// FUNCTION:	get_rate_table_duration
// PURPOSE:	Provides duration parameter.
//		If short preamble is requested, then subracts half of the preamble duration
//		to overall duration
//
get_rate_table_duration:
	or	[0x04,off2], 0x000, REG34
	jzx	0, 4, REG1, 0x000, end_get_rate_table_duration

	// not executed on linksys in AP mode
	jnzx	0, 0, REG1, 0x000, end_get_rate_table_duration

	// not executed on linksys in AP mode
	sr	[SHM_PREAMBLE_DURATION], 0x001, REG35
	sub	[0x04,off2], REG35, REG34
end_get_rate_table_duration:
	ret	lr0, lr0

// ***********************************************************************************************
// FUNCTION:	antenna_diversity_helper
// PURPOSE:	Manages antenna diversity operations.
//
// Bit 0x0001 of GLOBAL_FLAGS_REG1 is used (copy the G mode of SPR_MAC_CTLHI, msb)
antenna_diversity_helper:
	jzx	0, 0, [SHM_HF_LO], 0x000, end_antenna_diversity_helper
	add	ANTENNA_DIVERSITY_CTR, 0x001, ANTENNA_DIVERSITY_CTR
	jl	ANTENNA_DIVERSITY_CTR, [SHM_ANTSWAP], end_antenna_diversity_helper
	orx	7, 8, 0x000, 0x001, REG34
	je	[SHM_PHYTYPE], 0x001, B_phy
	orx	0, 10, GLOBAL_FLAGS_REG1, 0x02B, REG34
B_phy:
	call	lr0, sel_phy_reg
	jne	ANTENNA_DIVERSITY_CTR, 0xFFFF, no_antenna_update
	orx	0, 7, [SHM_LAST_RX_ANTENNA], SPR_Ext_IHR_Data, REG35
	je	[SHM_PHYTYPE], 0x001, B_phy_2
	orx	0, 8, [SHM_LAST_RX_ANTENNA], SPR_Ext_IHR_Data, REG35
	jext	COND_TRUE, B_phy_2

	// not executed on pccard in STA mode
no_antenna_update:
	xor	SPR_Ext_IHR_Data, 0x080, REG35
	je	[SHM_PHYTYPE], 0x001, B_phy_2

	// not executed on pccard in STA mode
	xor	SPR_Ext_IHR_Data, 0x100, REG35
B_phy_2:
	call	lr0, write_phy_reg
	orx	7, 8, 0x000, 0x000, ANTENNA_DIVERSITY_CTR
end_antenna_diversity_helper:
	ret	lr1, lr1

// ***********************************************************************************************
// FUNCTION:	gphy_classify_control_with_arg
// PURPOSE:	Manages classify control for G PHY devices.
//
gphy_classify_control_with_arg:
	jne	[SHM_PHYTYPE], 0x002, end_gphy_classify_control_with_arg
	orx	7, 8, 0x008, 0x002, REG34
	call	lr0, write_phy_reg
end_gphy_classify_control_with_arg:
	ret	lr1, lr1

// ***********************************************************************************************
// FUNCTION:	check_gphy_sym_war	
// PURPOSE:	Checks for workaround.
//
check_gphy_sym_war:
	jzx	0, 1, [SHM_HF_LO], 0x000, end_check_gphy_sym_war
	je	[SHM_PHYTYPE], 0x000, end_check_gphy_sym_war
	jnzx	1, 0, REG23, 0x000, end_check_gphy_sym_war
	jne	REG43, 0x001, end_check_gphy_sym_war
	srx	7, 0, [RX_FRAME_PLCP_0,off1], 0x000, REG34
	jle	REG34, 0x014, end_check_gphy_sym_war
	jne	[RX_FRAME_PLCP_1,off1], 0x050, end_check_gphy_sym_war
	// only on old debian STA (same kernel as others) and only when STA
	// maybe the board?
	orx	7, 8, 0x000, 0x001, GPHY_SYM_WAR_FLAG
	orx	0, 4, 0x001, SPR_IFS_CTL, SPR_IFS_CTL
end_check_gphy_sym_war:
	ret	lr1, lr1

// ***********************************************************************************************
// FUNCTION:	bg_noise_sample	
// PURPOSE:	Performs a noise measurement on the channel.
//
// NOTE: use SPR_BASE5 to read from SHM(0x0088)
//
// Bit 0x0008 of GLOBAL_FLAGS_REG3 => 0 no measurement was started, start and set it to 1 (0x0008)
// When done, reset it back to zero.
// No one else changes this bit.
// Bit 0x0001 of GLOBAL_FLAGS_REG1 is used (copy the G mode of SPR_MAC_CTLHI, msb)
bg_noise_sample:
	jzx	0, 4, SPR_MAC_CMD, 0x000, stop_bg_noise_sample
	jnzx	0, 3, GLOBAL_FLAGS_REG3, 0x000, bg_noise_inprogress
	orx	0, 3, 0x001, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
	or	SPR_TSF_WORD0, 0x000, 0x000
	or	SPR_TSF_WORD1, 0x000, [SHM_BGN_START_TSF1]
bg_noise_inprogress:
	or	SPR_TSF_WORD0, 0x000, 0x000
	sub	SPR_TSF_WORD1, [SHM_BGN_START_TSF1], REG37
	orx	7, 8, 0x000, 0x008, REG34
	call	lr0, sel_phy_reg
	srx	7, 0, SPR_Ext_IHR_Data, 0x000, [SHM_JSSIAUX]
	orx	0, 10, GLOBAL_FLAGS_REG1, 0x05F, REG34
	call	lr0, sel_phy_reg
	orx	7, 8, SPR_Ext_IHR_Data, [SHM_JSSIAUX], [SHM_JSSIAUX]
	orx	7, 8, 0x000, 0x027, REG34
	mov	SHM_JSSI0, SPR_BASE5
	orx	7, 8, 0x000, 0x000, REG35
loop_on_JSSI:
	add	REG35, 0x001, REG35
	add	SPR_TSF_WORD0, 0x002, REG36
wait_for_time_to_be_elapsed_2us:
	jext	COND_TX_NOW, stop_bg_noise_sample
	jzx	0, 11, SPR_IFS_STAT, 0x000, no_frame_to_transmit
	jl	REG37, 0x002, stop_bg_noise_sample
no_frame_to_transmit:
	jne	REG36, SPR_TSF_WORD0, wait_for_time_to_be_elapsed_2us
	call	lr0, sel_phy_reg
	orx	8, 0, SPR_Ext_IHR_Data, [0x00,off5], [0x00,off5]
	jne	[SHM_PHYTYPE], 0x000, not_A_phy
	jnzx	0, 8, SPR_Ext_IHR_Data, 0x000, rise_bg_noise_complete_irq
	jext	COND_TRUE, A_phy
not_A_phy:
	rr	[0x00,off5], 0x008, [0x00,off5]
	xor	SPR_BASE5, 0x001, SPR_BASE5
A_phy:
	jl	REG35, 0x004, loop_on_JSSI
	jge	REG37, 0x002, rise_bg_noise_complete_irq
	add	SPR_TSF_WORD0, 0x018, REG36
wait_for_time_to_be_elapsed_24us:
	jext	COND_TX_NOW, stop_bg_noise_sample
	jnzx	0, 11, SPR_IFS_STAT, 0x000, stop_bg_noise_sample
	jne	REG36, SPR_TSF_WORD0, wait_for_time_to_be_elapsed_24us
rise_bg_noise_complete_irq:
	orx	7, 8, 0x000, 0x010, SPR_MAC_CMD
	orx	7, 8, 0x000, 0x004, SPR_MAC_IRQHI
	orx	0, 3, 0x000, GLOBAL_FLAGS_REG3, GLOBAL_FLAGS_REG3
stop_bg_noise_sample:
	ret	lr3, lr2

// ***********************************************************************************************
// FUNCTION:	set_backoff_time
// PURPOSE:	Updates backoff time for contention operation.
//
set_backoff_time:
	and	SPR_TSF_Random, CUR_CONTENTION_WIN, SPR_IFS_BKOFFDELAY
	ret	lr1, lr1

// ***********************************************************************************************
// FUNCTION:	???
// PURPOSE:	???
//
// XXX
LABEL559:
	jnzx	0, 8, SPR_IFS_STAT, 0x000, skip_on_ap
	jzx	0, 7, [SHM_HF_LO], 0x000, skip_on_ap
	// execute on STA (not AP)
	call	lr2, LABEL588
skip_on_ap:
	or	REG34, 0x000, REG34
	ret	lr3, lr3

// ***********************************************************************************************
// FUNCTION:	???
// PURPOSE:	???
//
// XXX
// DOC aspirino federer larrybird linksys03 panatta pescosolido
LABEL588:
	jzx	0, 9, SPR_IFS_STAT, 0x000, LABEL589
	orx	0, 6, 0x001, GLOBAL_FLAGS_REG2, GLOBAL_FLAGS_REG2
	jext	COND_TRUE, LABEL592
LABEL589:
	orx	0, 6, 0x000, GLOBAL_FLAGS_REG2, GLOBAL_FLAGS_REG2
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x000, LABEL590
	orx	7, 8, 0x000, 0x000, REG1
	jext	COND_TRUE, LABEL591
LABEL590:
	orx	7, 8, 0x000, 0x004, REG1
LABEL591:
	orx	7, 8, 0x000, 0x051, REG0
	jnzx	0, 3, SPR_MAC_CTLHI, 0x000, LABEL592
	orx	7, 8, 0x000, 0x00B, REG34
	orx	0, 3, 0x001, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
	and	REG0, 0x0FF, REG35
	call	lr0, write_phy_reg
	orx	7, 8, 0x000, 0x00D, REG34
	or	REG1, 0x000, REG35
	call	lr0, write_phy_reg
	orx	0, 3, 0x000, GLOBAL_FLAGS_REG1, GLOBAL_FLAGS_REG1
LABEL592:
	ret	lr2, lr2

#include "initvals.asm"

