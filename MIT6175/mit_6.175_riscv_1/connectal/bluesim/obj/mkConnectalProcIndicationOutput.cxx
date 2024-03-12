/*
 * Generated by Bluespec Compiler, version 2023.01 (build 52adafa5)
 * 
 * On Thu Mar  7 15:36:37 UTC 2024
 * 
 */
#include "bluesim_primitives.h"
#include "mkConnectalProcIndicationOutput.h"


/* Constructor */
MOD_mkConnectalProcIndicationOutput::MOD_mkConnectalProcIndicationOutput(tSimStateHdl simHdl,
									 char const *name,
									 Module *parent)
  : Module(simHdl, name, parent),
    __clk_handle_0(BAD_CLOCK_HANDLE),
    INST_indicationPipes(simHdl, "indicationPipes", this),
    PORT_RST_N((tUInt8)1u)
{
  PORT_EN_portalIfc_indications_0_deq = false;
  PORT_EN_portalIfc_indications_1_deq = false;
  PORT_EN_ifc_wroteWord = false;
  PORT_EN_ifc_sendMessage = false;
  PORT_portalIfc_messageSize_size_methodNumber = 0u;
  PORT_ifc_wroteWord_data = 0u;
  PORT_ifc_sendMessage_mess = 0u;
  PORT_portalIfc_intr_channel = 0u;
  PORT_portalIfc_intr_status = false;
  PORT_portalIfc_messageSize_size = 0u;
  PORT_RDY_portalIfc_messageSize_size = false;
  PORT_RDY_portalIfc_intr_status = false;
  PORT_RDY_portalIfc_intr_channel = false;
  PORT_portalIfc_indications_0_first = 0u;
  PORT_RDY_portalIfc_indications_0_first = false;
  PORT_RDY_portalIfc_indications_0_deq = false;
  PORT_portalIfc_indications_0_notEmpty = false;
  PORT_RDY_portalIfc_indications_0_notEmpty = false;
  PORT_portalIfc_indications_1_first = 0u;
  PORT_RDY_portalIfc_indications_1_first = false;
  PORT_RDY_portalIfc_indications_1_deq = false;
  PORT_portalIfc_indications_1_notEmpty = false;
  PORT_RDY_portalIfc_indications_1_notEmpty = false;
  PORT_RDY_ifc_sendMessage = false;
  PORT_RDY_ifc_wroteWord = false;
  symbol_count = 41u;
  symbols = new tSym[symbol_count];
  init_symbols_0();
}


/* Symbol init fns */

void MOD_mkConnectalProcIndicationOutput::init_symbols_0()
{
  init_symbol(&symbols[0u], "CAN_FIRE_ifc_sendMessage", SYM_DEF, &DEF_CAN_FIRE_ifc_sendMessage, 1u);
  init_symbol(&symbols[1u], "CAN_FIRE_ifc_wroteWord", SYM_DEF, &DEF_CAN_FIRE_ifc_wroteWord, 1u);
  init_symbol(&symbols[2u],
	      "CAN_FIRE_portalIfc_indications_0_deq",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_indications_0_deq,
	      1u);
  init_symbol(&symbols[3u],
	      "CAN_FIRE_portalIfc_indications_0_first",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_indications_0_first,
	      1u);
  init_symbol(&symbols[4u],
	      "CAN_FIRE_portalIfc_indications_0_notEmpty",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_indications_0_notEmpty,
	      1u);
  init_symbol(&symbols[5u],
	      "CAN_FIRE_portalIfc_indications_1_deq",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_indications_1_deq,
	      1u);
  init_symbol(&symbols[6u],
	      "CAN_FIRE_portalIfc_indications_1_first",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_indications_1_first,
	      1u);
  init_symbol(&symbols[7u],
	      "CAN_FIRE_portalIfc_indications_1_notEmpty",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_indications_1_notEmpty,
	      1u);
  init_symbol(&symbols[8u],
	      "CAN_FIRE_portalIfc_intr_channel",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_intr_channel,
	      1u);
  init_symbol(&symbols[9u],
	      "CAN_FIRE_portalIfc_intr_status",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_intr_status,
	      1u);
  init_symbol(&symbols[10u],
	      "CAN_FIRE_portalIfc_messageSize_size",
	      SYM_DEF,
	      &DEF_CAN_FIRE_portalIfc_messageSize_size,
	      1u);
  init_symbol(&symbols[11u], "EN_ifc_sendMessage", SYM_PORT, &PORT_EN_ifc_sendMessage, 1u);
  init_symbol(&symbols[12u], "EN_ifc_wroteWord", SYM_PORT, &PORT_EN_ifc_wroteWord, 1u);
  init_symbol(&symbols[13u],
	      "EN_portalIfc_indications_0_deq",
	      SYM_PORT,
	      &PORT_EN_portalIfc_indications_0_deq,
	      1u);
  init_symbol(&symbols[14u],
	      "EN_portalIfc_indications_1_deq",
	      SYM_PORT,
	      &PORT_EN_portalIfc_indications_1_deq,
	      1u);
  init_symbol(&symbols[15u], "ifc_sendMessage_mess", SYM_PORT, &PORT_ifc_sendMessage_mess, 18u);
  init_symbol(&symbols[16u], "ifc_wroteWord_data", SYM_PORT, &PORT_ifc_wroteWord_data, 32u);
  init_symbol(&symbols[17u], "indicationPipes", SYM_MODULE, &INST_indicationPipes);
  init_symbol(&symbols[18u],
	      "portalIfc_indications_0_first",
	      SYM_PORT,
	      &PORT_portalIfc_indications_0_first,
	      32u);
  init_symbol(&symbols[19u],
	      "portalIfc_indications_0_notEmpty",
	      SYM_PORT,
	      &PORT_portalIfc_indications_0_notEmpty,
	      1u);
  init_symbol(&symbols[20u],
	      "portalIfc_indications_1_first",
	      SYM_PORT,
	      &PORT_portalIfc_indications_1_first,
	      32u);
  init_symbol(&symbols[21u],
	      "portalIfc_indications_1_notEmpty",
	      SYM_PORT,
	      &PORT_portalIfc_indications_1_notEmpty,
	      1u);
  init_symbol(&symbols[22u], "portalIfc_intr_channel", SYM_PORT, &PORT_portalIfc_intr_channel, 32u);
  init_symbol(&symbols[23u], "portalIfc_intr_status", SYM_PORT, &PORT_portalIfc_intr_status, 1u);
  init_symbol(&symbols[24u],
	      "portalIfc_messageSize_size",
	      SYM_PORT,
	      &PORT_portalIfc_messageSize_size,
	      16u);
  init_symbol(&symbols[25u],
	      "portalIfc_messageSize_size_methodNumber",
	      SYM_PORT,
	      &PORT_portalIfc_messageSize_size_methodNumber,
	      16u);
  init_symbol(&symbols[26u], "RDY_ifc_sendMessage", SYM_PORT, &PORT_RDY_ifc_sendMessage, 1u);
  init_symbol(&symbols[27u], "RDY_ifc_wroteWord", SYM_PORT, &PORT_RDY_ifc_wroteWord, 1u);
  init_symbol(&symbols[28u],
	      "RDY_portalIfc_indications_0_deq",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_indications_0_deq,
	      1u);
  init_symbol(&symbols[29u],
	      "RDY_portalIfc_indications_0_first",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_indications_0_first,
	      1u);
  init_symbol(&symbols[30u],
	      "RDY_portalIfc_indications_0_notEmpty",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_indications_0_notEmpty,
	      1u);
  init_symbol(&symbols[31u],
	      "RDY_portalIfc_indications_1_deq",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_indications_1_deq,
	      1u);
  init_symbol(&symbols[32u],
	      "RDY_portalIfc_indications_1_first",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_indications_1_first,
	      1u);
  init_symbol(&symbols[33u],
	      "RDY_portalIfc_indications_1_notEmpty",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_indications_1_notEmpty,
	      1u);
  init_symbol(&symbols[34u],
	      "RDY_portalIfc_intr_channel",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_intr_channel,
	      1u);
  init_symbol(&symbols[35u],
	      "RDY_portalIfc_intr_status",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_intr_status,
	      1u);
  init_symbol(&symbols[36u],
	      "RDY_portalIfc_messageSize_size",
	      SYM_PORT,
	      &PORT_RDY_portalIfc_messageSize_size,
	      1u);
  init_symbol(&symbols[37u],
	      "WILL_FIRE_ifc_sendMessage",
	      SYM_DEF,
	      &DEF_WILL_FIRE_ifc_sendMessage,
	      1u);
  init_symbol(&symbols[38u], "WILL_FIRE_ifc_wroteWord", SYM_DEF, &DEF_WILL_FIRE_ifc_wroteWord, 1u);
  init_symbol(&symbols[39u],
	      "WILL_FIRE_portalIfc_indications_0_deq",
	      SYM_DEF,
	      &DEF_WILL_FIRE_portalIfc_indications_0_deq,
	      1u);
  init_symbol(&symbols[40u],
	      "WILL_FIRE_portalIfc_indications_1_deq",
	      SYM_DEF,
	      &DEF_WILL_FIRE_portalIfc_indications_1_deq,
	      1u);
}


/* Rule actions */


/* Methods */

tUInt32 MOD_mkConnectalProcIndicationOutput::METH_portalIfc_messageSize_size(tUInt32 ARG_portalIfc_messageSize_size_methodNumber)
{
  PORT_portalIfc_messageSize_size_methodNumber = ARG_portalIfc_messageSize_size_methodNumber;
  PORT_portalIfc_messageSize_size = INST_indicationPipes.METH_portalIfc_messageSize_size(ARG_portalIfc_messageSize_size_methodNumber);
  return PORT_portalIfc_messageSize_size;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_messageSize_size()
{
  DEF_CAN_FIRE_portalIfc_messageSize_size = (tUInt8)1u;
  PORT_RDY_portalIfc_messageSize_size = DEF_CAN_FIRE_portalIfc_messageSize_size;
  return PORT_RDY_portalIfc_messageSize_size;
}

tUInt32 MOD_mkConnectalProcIndicationOutput::METH_portalIfc_indications_0_first()
{
  PORT_portalIfc_indications_0_first = INST_indicationPipes.METH_portalIfc_indications_0_first();
  return PORT_portalIfc_indications_0_first;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_indications_0_first()
{
  DEF_CAN_FIRE_portalIfc_indications_0_first = INST_indicationPipes.METH_RDY_portalIfc_indications_0_first();
  PORT_RDY_portalIfc_indications_0_first = DEF_CAN_FIRE_portalIfc_indications_0_first;
  return PORT_RDY_portalIfc_indications_0_first;
}

void MOD_mkConnectalProcIndicationOutput::METH_portalIfc_indications_0_deq()
{
  PORT_EN_portalIfc_indications_0_deq = (tUInt8)1u;
  DEF_WILL_FIRE_portalIfc_indications_0_deq = (tUInt8)1u;
  INST_indicationPipes.METH_portalIfc_indications_0_deq();
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_indications_0_deq()
{
  DEF_CAN_FIRE_portalIfc_indications_0_deq = INST_indicationPipes.METH_RDY_portalIfc_indications_0_deq();
  PORT_RDY_portalIfc_indications_0_deq = DEF_CAN_FIRE_portalIfc_indications_0_deq;
  return PORT_RDY_portalIfc_indications_0_deq;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_portalIfc_indications_0_notEmpty()
{
  PORT_portalIfc_indications_0_notEmpty = INST_indicationPipes.METH_portalIfc_indications_0_notEmpty();
  return PORT_portalIfc_indications_0_notEmpty;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_indications_0_notEmpty()
{
  DEF_CAN_FIRE_portalIfc_indications_0_notEmpty = (tUInt8)1u;
  PORT_RDY_portalIfc_indications_0_notEmpty = DEF_CAN_FIRE_portalIfc_indications_0_notEmpty;
  return PORT_RDY_portalIfc_indications_0_notEmpty;
}

tUInt32 MOD_mkConnectalProcIndicationOutput::METH_portalIfc_indications_1_first()
{
  PORT_portalIfc_indications_1_first = INST_indicationPipes.METH_portalIfc_indications_1_first();
  return PORT_portalIfc_indications_1_first;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_indications_1_first()
{
  DEF_CAN_FIRE_portalIfc_indications_1_first = INST_indicationPipes.METH_RDY_portalIfc_indications_1_first();
  PORT_RDY_portalIfc_indications_1_first = DEF_CAN_FIRE_portalIfc_indications_1_first;
  return PORT_RDY_portalIfc_indications_1_first;
}

void MOD_mkConnectalProcIndicationOutput::METH_portalIfc_indications_1_deq()
{
  PORT_EN_portalIfc_indications_1_deq = (tUInt8)1u;
  DEF_WILL_FIRE_portalIfc_indications_1_deq = (tUInt8)1u;
  INST_indicationPipes.METH_portalIfc_indications_1_deq();
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_indications_1_deq()
{
  DEF_CAN_FIRE_portalIfc_indications_1_deq = INST_indicationPipes.METH_RDY_portalIfc_indications_1_deq();
  PORT_RDY_portalIfc_indications_1_deq = DEF_CAN_FIRE_portalIfc_indications_1_deq;
  return PORT_RDY_portalIfc_indications_1_deq;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_portalIfc_indications_1_notEmpty()
{
  PORT_portalIfc_indications_1_notEmpty = INST_indicationPipes.METH_portalIfc_indications_1_notEmpty();
  return PORT_portalIfc_indications_1_notEmpty;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_indications_1_notEmpty()
{
  DEF_CAN_FIRE_portalIfc_indications_1_notEmpty = (tUInt8)1u;
  PORT_RDY_portalIfc_indications_1_notEmpty = DEF_CAN_FIRE_portalIfc_indications_1_notEmpty;
  return PORT_RDY_portalIfc_indications_1_notEmpty;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_portalIfc_intr_status()
{
  PORT_portalIfc_intr_status = INST_indicationPipes.METH_portalIfc_intr_status();
  return PORT_portalIfc_intr_status;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_intr_status()
{
  DEF_CAN_FIRE_portalIfc_intr_status = (tUInt8)1u;
  PORT_RDY_portalIfc_intr_status = DEF_CAN_FIRE_portalIfc_intr_status;
  return PORT_RDY_portalIfc_intr_status;
}

tUInt32 MOD_mkConnectalProcIndicationOutput::METH_portalIfc_intr_channel()
{
  PORT_portalIfc_intr_channel = INST_indicationPipes.METH_portalIfc_intr_channel();
  return PORT_portalIfc_intr_channel;
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_portalIfc_intr_channel()
{
  DEF_CAN_FIRE_portalIfc_intr_channel = (tUInt8)1u;
  PORT_RDY_portalIfc_intr_channel = DEF_CAN_FIRE_portalIfc_intr_channel;
  return PORT_RDY_portalIfc_intr_channel;
}

void MOD_mkConnectalProcIndicationOutput::METH_ifc_sendMessage(tUInt32 ARG_ifc_sendMessage_mess)
{
  PORT_EN_ifc_sendMessage = (tUInt8)1u;
  DEF_WILL_FIRE_ifc_sendMessage = (tUInt8)1u;
  PORT_ifc_sendMessage_mess = ARG_ifc_sendMessage_mess;
  INST_indicationPipes.METH_methods_sendMessage_enq(ARG_ifc_sendMessage_mess);
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_ifc_sendMessage()
{
  DEF_CAN_FIRE_ifc_sendMessage = INST_indicationPipes.METH_RDY_methods_sendMessage_enq();
  PORT_RDY_ifc_sendMessage = DEF_CAN_FIRE_ifc_sendMessage;
  return PORT_RDY_ifc_sendMessage;
}

void MOD_mkConnectalProcIndicationOutput::METH_ifc_wroteWord(tUInt32 ARG_ifc_wroteWord_data)
{
  PORT_EN_ifc_wroteWord = (tUInt8)1u;
  DEF_WILL_FIRE_ifc_wroteWord = (tUInt8)1u;
  PORT_ifc_wroteWord_data = ARG_ifc_wroteWord_data;
  INST_indicationPipes.METH_methods_wroteWord_enq(ARG_ifc_wroteWord_data);
}

tUInt8 MOD_mkConnectalProcIndicationOutput::METH_RDY_ifc_wroteWord()
{
  DEF_CAN_FIRE_ifc_wroteWord = INST_indicationPipes.METH_RDY_methods_wroteWord_enq();
  PORT_RDY_ifc_wroteWord = DEF_CAN_FIRE_ifc_wroteWord;
  return PORT_RDY_ifc_wroteWord;
}


/* Reset routines */

void MOD_mkConnectalProcIndicationOutput::reset_RST_N(tUInt8 ARG_rst_in)
{
  PORT_RST_N = ARG_rst_in;
  INST_indicationPipes.reset_RST_N(ARG_rst_in);
}


/* Static handles to reset routines */


/* Functions for the parent module to register its reset fns */


/* Functions to set the elaborated clock id */

void MOD_mkConnectalProcIndicationOutput::set_clk_0(char const *s)
{
  __clk_handle_0 = bk_get_or_define_clock(sim_hdl, s);
}


/* State dumping routine */
void MOD_mkConnectalProcIndicationOutput::dump_state(unsigned int indent)
{
  printf("%*s%s:\n", indent, "", inst_name);
  INST_indicationPipes.dump_state(indent + 2u);
}


/* VCD dumping routines */

unsigned int MOD_mkConnectalProcIndicationOutput::dump_VCD_defs(unsigned int levels)
{
  vcd_write_scope_start(sim_hdl, inst_name);
  vcd_num = vcd_reserve_ids(sim_hdl, 41u);
  unsigned int num = vcd_num;
  for (unsigned int clk = 0u; clk < bk_num_clocks(sim_hdl); ++clk)
    vcd_add_clock_def(sim_hdl, this, bk_clock_name(sim_hdl, clk), bk_clock_vcd_num(sim_hdl, clk));
  vcd_write_def(sim_hdl, bk_clock_vcd_num(sim_hdl, __clk_handle_0), "CLK", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_ifc_sendMessage", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_ifc_wroteWord", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_indications_0_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_indications_0_first", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_indications_0_notEmpty", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_indications_1_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_indications_1_first", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_indications_1_notEmpty", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_intr_channel", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_intr_status", 1u);
  vcd_write_def(sim_hdl, num++, "CAN_FIRE_portalIfc_messageSize_size", 1u);
  vcd_write_def(sim_hdl, num++, "RST_N", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "WILL_FIRE_ifc_sendMessage", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "WILL_FIRE_ifc_wroteWord", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "WILL_FIRE_portalIfc_indications_0_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "WILL_FIRE_portalIfc_indications_1_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "EN_ifc_sendMessage", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "EN_ifc_wroteWord", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "EN_portalIfc_indications_0_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "EN_portalIfc_indications_1_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_ifc_sendMessage", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_ifc_wroteWord", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_indications_0_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_indications_0_first", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_indications_0_notEmpty", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_indications_1_deq", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_indications_1_first", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_indications_1_notEmpty", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_intr_channel", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_intr_status", 1u);
  vcd_write_def(sim_hdl, num++, "RDY_portalIfc_messageSize_size", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "ifc_sendMessage_mess", 18u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "ifc_wroteWord_data", 32u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "portalIfc_indications_0_first", 32u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "portalIfc_indications_0_notEmpty", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "portalIfc_indications_1_first", 32u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "portalIfc_indications_1_notEmpty", 1u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "portalIfc_intr_channel", 32u);
  vcd_set_clock(sim_hdl, num, __clk_handle_0);
  vcd_write_def(sim_hdl, num++, "portalIfc_intr_status", 1u);
  vcd_write_def(sim_hdl, num++, "portalIfc_messageSize_size", 16u);
  vcd_write_def(sim_hdl, num++, "portalIfc_messageSize_size_methodNumber", 16u);
  if (levels != 1u)
  {
    unsigned int l = levels == 0u ? 0u : levels - 1u;
    num = INST_indicationPipes.dump_VCD_defs(l);
  }
  vcd_write_scope_end(sim_hdl);
  return num;
}

void MOD_mkConnectalProcIndicationOutput::dump_VCD(tVCDDumpType dt,
						   unsigned int levels,
						   MOD_mkConnectalProcIndicationOutput &backing)
{
  vcd_defs(dt, backing);
  if (levels != 1u)
    vcd_submodules(dt, levels - 1u, backing);
}

void MOD_mkConnectalProcIndicationOutput::vcd_defs(tVCDDumpType dt,
						   MOD_mkConnectalProcIndicationOutput &backing)
{
  unsigned int num = vcd_num;
  if (dt == VCD_DUMP_XS)
  {
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 18u);
    vcd_write_x(sim_hdl, num++, 32u);
    vcd_write_x(sim_hdl, num++, 32u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 32u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 32u);
    vcd_write_x(sim_hdl, num++, 1u);
    vcd_write_x(sim_hdl, num++, 16u);
    vcd_write_x(sim_hdl, num++, 16u);
  }
  else
    if (dt == VCD_DUMP_CHANGES)
    {
      if ((backing.DEF_CAN_FIRE_ifc_sendMessage) != DEF_CAN_FIRE_ifc_sendMessage)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_ifc_sendMessage, 1u);
	backing.DEF_CAN_FIRE_ifc_sendMessage = DEF_CAN_FIRE_ifc_sendMessage;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_ifc_wroteWord) != DEF_CAN_FIRE_ifc_wroteWord)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_ifc_wroteWord, 1u);
	backing.DEF_CAN_FIRE_ifc_wroteWord = DEF_CAN_FIRE_ifc_wroteWord;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_indications_0_deq) != DEF_CAN_FIRE_portalIfc_indications_0_deq)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_indications_0_deq, 1u);
	backing.DEF_CAN_FIRE_portalIfc_indications_0_deq = DEF_CAN_FIRE_portalIfc_indications_0_deq;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_indications_0_first) != DEF_CAN_FIRE_portalIfc_indications_0_first)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_indications_0_first, 1u);
	backing.DEF_CAN_FIRE_portalIfc_indications_0_first = DEF_CAN_FIRE_portalIfc_indications_0_first;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_indications_0_notEmpty) != DEF_CAN_FIRE_portalIfc_indications_0_notEmpty)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_indications_0_notEmpty, 1u);
	backing.DEF_CAN_FIRE_portalIfc_indications_0_notEmpty = DEF_CAN_FIRE_portalIfc_indications_0_notEmpty;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_indications_1_deq) != DEF_CAN_FIRE_portalIfc_indications_1_deq)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_indications_1_deq, 1u);
	backing.DEF_CAN_FIRE_portalIfc_indications_1_deq = DEF_CAN_FIRE_portalIfc_indications_1_deq;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_indications_1_first) != DEF_CAN_FIRE_portalIfc_indications_1_first)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_indications_1_first, 1u);
	backing.DEF_CAN_FIRE_portalIfc_indications_1_first = DEF_CAN_FIRE_portalIfc_indications_1_first;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_indications_1_notEmpty) != DEF_CAN_FIRE_portalIfc_indications_1_notEmpty)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_indications_1_notEmpty, 1u);
	backing.DEF_CAN_FIRE_portalIfc_indications_1_notEmpty = DEF_CAN_FIRE_portalIfc_indications_1_notEmpty;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_intr_channel) != DEF_CAN_FIRE_portalIfc_intr_channel)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_intr_channel, 1u);
	backing.DEF_CAN_FIRE_portalIfc_intr_channel = DEF_CAN_FIRE_portalIfc_intr_channel;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_intr_status) != DEF_CAN_FIRE_portalIfc_intr_status)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_intr_status, 1u);
	backing.DEF_CAN_FIRE_portalIfc_intr_status = DEF_CAN_FIRE_portalIfc_intr_status;
      }
      ++num;
      if ((backing.DEF_CAN_FIRE_portalIfc_messageSize_size) != DEF_CAN_FIRE_portalIfc_messageSize_size)
      {
	vcd_write_val(sim_hdl, num, DEF_CAN_FIRE_portalIfc_messageSize_size, 1u);
	backing.DEF_CAN_FIRE_portalIfc_messageSize_size = DEF_CAN_FIRE_portalIfc_messageSize_size;
      }
      ++num;
      if ((backing.PORT_RST_N) != PORT_RST_N)
      {
	vcd_write_val(sim_hdl, num, PORT_RST_N, 1u);
	backing.PORT_RST_N = PORT_RST_N;
      }
      ++num;
      if ((backing.DEF_WILL_FIRE_ifc_sendMessage) != DEF_WILL_FIRE_ifc_sendMessage)
      {
	vcd_write_val(sim_hdl, num, DEF_WILL_FIRE_ifc_sendMessage, 1u);
	backing.DEF_WILL_FIRE_ifc_sendMessage = DEF_WILL_FIRE_ifc_sendMessage;
      }
      ++num;
      if ((backing.DEF_WILL_FIRE_ifc_wroteWord) != DEF_WILL_FIRE_ifc_wroteWord)
      {
	vcd_write_val(sim_hdl, num, DEF_WILL_FIRE_ifc_wroteWord, 1u);
	backing.DEF_WILL_FIRE_ifc_wroteWord = DEF_WILL_FIRE_ifc_wroteWord;
      }
      ++num;
      if ((backing.DEF_WILL_FIRE_portalIfc_indications_0_deq) != DEF_WILL_FIRE_portalIfc_indications_0_deq)
      {
	vcd_write_val(sim_hdl, num, DEF_WILL_FIRE_portalIfc_indications_0_deq, 1u);
	backing.DEF_WILL_FIRE_portalIfc_indications_0_deq = DEF_WILL_FIRE_portalIfc_indications_0_deq;
      }
      ++num;
      if ((backing.DEF_WILL_FIRE_portalIfc_indications_1_deq) != DEF_WILL_FIRE_portalIfc_indications_1_deq)
      {
	vcd_write_val(sim_hdl, num, DEF_WILL_FIRE_portalIfc_indications_1_deq, 1u);
	backing.DEF_WILL_FIRE_portalIfc_indications_1_deq = DEF_WILL_FIRE_portalIfc_indications_1_deq;
      }
      ++num;
      if ((backing.PORT_EN_ifc_sendMessage) != PORT_EN_ifc_sendMessage)
      {
	vcd_write_val(sim_hdl, num, PORT_EN_ifc_sendMessage, 1u);
	backing.PORT_EN_ifc_sendMessage = PORT_EN_ifc_sendMessage;
      }
      ++num;
      if ((backing.PORT_EN_ifc_wroteWord) != PORT_EN_ifc_wroteWord)
      {
	vcd_write_val(sim_hdl, num, PORT_EN_ifc_wroteWord, 1u);
	backing.PORT_EN_ifc_wroteWord = PORT_EN_ifc_wroteWord;
      }
      ++num;
      if ((backing.PORT_EN_portalIfc_indications_0_deq) != PORT_EN_portalIfc_indications_0_deq)
      {
	vcd_write_val(sim_hdl, num, PORT_EN_portalIfc_indications_0_deq, 1u);
	backing.PORT_EN_portalIfc_indications_0_deq = PORT_EN_portalIfc_indications_0_deq;
      }
      ++num;
      if ((backing.PORT_EN_portalIfc_indications_1_deq) != PORT_EN_portalIfc_indications_1_deq)
      {
	vcd_write_val(sim_hdl, num, PORT_EN_portalIfc_indications_1_deq, 1u);
	backing.PORT_EN_portalIfc_indications_1_deq = PORT_EN_portalIfc_indications_1_deq;
      }
      ++num;
      if ((backing.PORT_RDY_ifc_sendMessage) != PORT_RDY_ifc_sendMessage)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_ifc_sendMessage, 1u);
	backing.PORT_RDY_ifc_sendMessage = PORT_RDY_ifc_sendMessage;
      }
      ++num;
      if ((backing.PORT_RDY_ifc_wroteWord) != PORT_RDY_ifc_wroteWord)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_ifc_wroteWord, 1u);
	backing.PORT_RDY_ifc_wroteWord = PORT_RDY_ifc_wroteWord;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_indications_0_deq) != PORT_RDY_portalIfc_indications_0_deq)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_indications_0_deq, 1u);
	backing.PORT_RDY_portalIfc_indications_0_deq = PORT_RDY_portalIfc_indications_0_deq;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_indications_0_first) != PORT_RDY_portalIfc_indications_0_first)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_indications_0_first, 1u);
	backing.PORT_RDY_portalIfc_indications_0_first = PORT_RDY_portalIfc_indications_0_first;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_indications_0_notEmpty) != PORT_RDY_portalIfc_indications_0_notEmpty)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_indications_0_notEmpty, 1u);
	backing.PORT_RDY_portalIfc_indications_0_notEmpty = PORT_RDY_portalIfc_indications_0_notEmpty;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_indications_1_deq) != PORT_RDY_portalIfc_indications_1_deq)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_indications_1_deq, 1u);
	backing.PORT_RDY_portalIfc_indications_1_deq = PORT_RDY_portalIfc_indications_1_deq;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_indications_1_first) != PORT_RDY_portalIfc_indications_1_first)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_indications_1_first, 1u);
	backing.PORT_RDY_portalIfc_indications_1_first = PORT_RDY_portalIfc_indications_1_first;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_indications_1_notEmpty) != PORT_RDY_portalIfc_indications_1_notEmpty)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_indications_1_notEmpty, 1u);
	backing.PORT_RDY_portalIfc_indications_1_notEmpty = PORT_RDY_portalIfc_indications_1_notEmpty;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_intr_channel) != PORT_RDY_portalIfc_intr_channel)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_intr_channel, 1u);
	backing.PORT_RDY_portalIfc_intr_channel = PORT_RDY_portalIfc_intr_channel;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_intr_status) != PORT_RDY_portalIfc_intr_status)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_intr_status, 1u);
	backing.PORT_RDY_portalIfc_intr_status = PORT_RDY_portalIfc_intr_status;
      }
      ++num;
      if ((backing.PORT_RDY_portalIfc_messageSize_size) != PORT_RDY_portalIfc_messageSize_size)
      {
	vcd_write_val(sim_hdl, num, PORT_RDY_portalIfc_messageSize_size, 1u);
	backing.PORT_RDY_portalIfc_messageSize_size = PORT_RDY_portalIfc_messageSize_size;
      }
      ++num;
      if ((backing.PORT_ifc_sendMessage_mess) != PORT_ifc_sendMessage_mess)
      {
	vcd_write_val(sim_hdl, num, PORT_ifc_sendMessage_mess, 18u);
	backing.PORT_ifc_sendMessage_mess = PORT_ifc_sendMessage_mess;
      }
      ++num;
      if ((backing.PORT_ifc_wroteWord_data) != PORT_ifc_wroteWord_data)
      {
	vcd_write_val(sim_hdl, num, PORT_ifc_wroteWord_data, 32u);
	backing.PORT_ifc_wroteWord_data = PORT_ifc_wroteWord_data;
      }
      ++num;
      if ((backing.PORT_portalIfc_indications_0_first) != PORT_portalIfc_indications_0_first)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_indications_0_first, 32u);
	backing.PORT_portalIfc_indications_0_first = PORT_portalIfc_indications_0_first;
      }
      ++num;
      if ((backing.PORT_portalIfc_indications_0_notEmpty) != PORT_portalIfc_indications_0_notEmpty)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_indications_0_notEmpty, 1u);
	backing.PORT_portalIfc_indications_0_notEmpty = PORT_portalIfc_indications_0_notEmpty;
      }
      ++num;
      if ((backing.PORT_portalIfc_indications_1_first) != PORT_portalIfc_indications_1_first)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_indications_1_first, 32u);
	backing.PORT_portalIfc_indications_1_first = PORT_portalIfc_indications_1_first;
      }
      ++num;
      if ((backing.PORT_portalIfc_indications_1_notEmpty) != PORT_portalIfc_indications_1_notEmpty)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_indications_1_notEmpty, 1u);
	backing.PORT_portalIfc_indications_1_notEmpty = PORT_portalIfc_indications_1_notEmpty;
      }
      ++num;
      if ((backing.PORT_portalIfc_intr_channel) != PORT_portalIfc_intr_channel)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_intr_channel, 32u);
	backing.PORT_portalIfc_intr_channel = PORT_portalIfc_intr_channel;
      }
      ++num;
      if ((backing.PORT_portalIfc_intr_status) != PORT_portalIfc_intr_status)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_intr_status, 1u);
	backing.PORT_portalIfc_intr_status = PORT_portalIfc_intr_status;
      }
      ++num;
      if ((backing.PORT_portalIfc_messageSize_size) != PORT_portalIfc_messageSize_size)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_messageSize_size, 16u);
	backing.PORT_portalIfc_messageSize_size = PORT_portalIfc_messageSize_size;
      }
      ++num;
      if ((backing.PORT_portalIfc_messageSize_size_methodNumber) != PORT_portalIfc_messageSize_size_methodNumber)
      {
	vcd_write_val(sim_hdl, num, PORT_portalIfc_messageSize_size_methodNumber, 16u);
	backing.PORT_portalIfc_messageSize_size_methodNumber = PORT_portalIfc_messageSize_size_methodNumber;
      }
      ++num;
    }
    else
    {
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_ifc_sendMessage, 1u);
      backing.DEF_CAN_FIRE_ifc_sendMessage = DEF_CAN_FIRE_ifc_sendMessage;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_ifc_wroteWord, 1u);
      backing.DEF_CAN_FIRE_ifc_wroteWord = DEF_CAN_FIRE_ifc_wroteWord;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_indications_0_deq, 1u);
      backing.DEF_CAN_FIRE_portalIfc_indications_0_deq = DEF_CAN_FIRE_portalIfc_indications_0_deq;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_indications_0_first, 1u);
      backing.DEF_CAN_FIRE_portalIfc_indications_0_first = DEF_CAN_FIRE_portalIfc_indications_0_first;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_indications_0_notEmpty, 1u);
      backing.DEF_CAN_FIRE_portalIfc_indications_0_notEmpty = DEF_CAN_FIRE_portalIfc_indications_0_notEmpty;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_indications_1_deq, 1u);
      backing.DEF_CAN_FIRE_portalIfc_indications_1_deq = DEF_CAN_FIRE_portalIfc_indications_1_deq;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_indications_1_first, 1u);
      backing.DEF_CAN_FIRE_portalIfc_indications_1_first = DEF_CAN_FIRE_portalIfc_indications_1_first;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_indications_1_notEmpty, 1u);
      backing.DEF_CAN_FIRE_portalIfc_indications_1_notEmpty = DEF_CAN_FIRE_portalIfc_indications_1_notEmpty;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_intr_channel, 1u);
      backing.DEF_CAN_FIRE_portalIfc_intr_channel = DEF_CAN_FIRE_portalIfc_intr_channel;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_intr_status, 1u);
      backing.DEF_CAN_FIRE_portalIfc_intr_status = DEF_CAN_FIRE_portalIfc_intr_status;
      vcd_write_val(sim_hdl, num++, DEF_CAN_FIRE_portalIfc_messageSize_size, 1u);
      backing.DEF_CAN_FIRE_portalIfc_messageSize_size = DEF_CAN_FIRE_portalIfc_messageSize_size;
      vcd_write_val(sim_hdl, num++, PORT_RST_N, 1u);
      backing.PORT_RST_N = PORT_RST_N;
      vcd_write_val(sim_hdl, num++, DEF_WILL_FIRE_ifc_sendMessage, 1u);
      backing.DEF_WILL_FIRE_ifc_sendMessage = DEF_WILL_FIRE_ifc_sendMessage;
      vcd_write_val(sim_hdl, num++, DEF_WILL_FIRE_ifc_wroteWord, 1u);
      backing.DEF_WILL_FIRE_ifc_wroteWord = DEF_WILL_FIRE_ifc_wroteWord;
      vcd_write_val(sim_hdl, num++, DEF_WILL_FIRE_portalIfc_indications_0_deq, 1u);
      backing.DEF_WILL_FIRE_portalIfc_indications_0_deq = DEF_WILL_FIRE_portalIfc_indications_0_deq;
      vcd_write_val(sim_hdl, num++, DEF_WILL_FIRE_portalIfc_indications_1_deq, 1u);
      backing.DEF_WILL_FIRE_portalIfc_indications_1_deq = DEF_WILL_FIRE_portalIfc_indications_1_deq;
      vcd_write_val(sim_hdl, num++, PORT_EN_ifc_sendMessage, 1u);
      backing.PORT_EN_ifc_sendMessage = PORT_EN_ifc_sendMessage;
      vcd_write_val(sim_hdl, num++, PORT_EN_ifc_wroteWord, 1u);
      backing.PORT_EN_ifc_wroteWord = PORT_EN_ifc_wroteWord;
      vcd_write_val(sim_hdl, num++, PORT_EN_portalIfc_indications_0_deq, 1u);
      backing.PORT_EN_portalIfc_indications_0_deq = PORT_EN_portalIfc_indications_0_deq;
      vcd_write_val(sim_hdl, num++, PORT_EN_portalIfc_indications_1_deq, 1u);
      backing.PORT_EN_portalIfc_indications_1_deq = PORT_EN_portalIfc_indications_1_deq;
      vcd_write_val(sim_hdl, num++, PORT_RDY_ifc_sendMessage, 1u);
      backing.PORT_RDY_ifc_sendMessage = PORT_RDY_ifc_sendMessage;
      vcd_write_val(sim_hdl, num++, PORT_RDY_ifc_wroteWord, 1u);
      backing.PORT_RDY_ifc_wroteWord = PORT_RDY_ifc_wroteWord;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_indications_0_deq, 1u);
      backing.PORT_RDY_portalIfc_indications_0_deq = PORT_RDY_portalIfc_indications_0_deq;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_indications_0_first, 1u);
      backing.PORT_RDY_portalIfc_indications_0_first = PORT_RDY_portalIfc_indications_0_first;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_indications_0_notEmpty, 1u);
      backing.PORT_RDY_portalIfc_indications_0_notEmpty = PORT_RDY_portalIfc_indications_0_notEmpty;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_indications_1_deq, 1u);
      backing.PORT_RDY_portalIfc_indications_1_deq = PORT_RDY_portalIfc_indications_1_deq;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_indications_1_first, 1u);
      backing.PORT_RDY_portalIfc_indications_1_first = PORT_RDY_portalIfc_indications_1_first;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_indications_1_notEmpty, 1u);
      backing.PORT_RDY_portalIfc_indications_1_notEmpty = PORT_RDY_portalIfc_indications_1_notEmpty;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_intr_channel, 1u);
      backing.PORT_RDY_portalIfc_intr_channel = PORT_RDY_portalIfc_intr_channel;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_intr_status, 1u);
      backing.PORT_RDY_portalIfc_intr_status = PORT_RDY_portalIfc_intr_status;
      vcd_write_val(sim_hdl, num++, PORT_RDY_portalIfc_messageSize_size, 1u);
      backing.PORT_RDY_portalIfc_messageSize_size = PORT_RDY_portalIfc_messageSize_size;
      vcd_write_val(sim_hdl, num++, PORT_ifc_sendMessage_mess, 18u);
      backing.PORT_ifc_sendMessage_mess = PORT_ifc_sendMessage_mess;
      vcd_write_val(sim_hdl, num++, PORT_ifc_wroteWord_data, 32u);
      backing.PORT_ifc_wroteWord_data = PORT_ifc_wroteWord_data;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_indications_0_first, 32u);
      backing.PORT_portalIfc_indications_0_first = PORT_portalIfc_indications_0_first;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_indications_0_notEmpty, 1u);
      backing.PORT_portalIfc_indications_0_notEmpty = PORT_portalIfc_indications_0_notEmpty;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_indications_1_first, 32u);
      backing.PORT_portalIfc_indications_1_first = PORT_portalIfc_indications_1_first;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_indications_1_notEmpty, 1u);
      backing.PORT_portalIfc_indications_1_notEmpty = PORT_portalIfc_indications_1_notEmpty;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_intr_channel, 32u);
      backing.PORT_portalIfc_intr_channel = PORT_portalIfc_intr_channel;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_intr_status, 1u);
      backing.PORT_portalIfc_intr_status = PORT_portalIfc_intr_status;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_messageSize_size, 16u);
      backing.PORT_portalIfc_messageSize_size = PORT_portalIfc_messageSize_size;
      vcd_write_val(sim_hdl, num++, PORT_portalIfc_messageSize_size_methodNumber, 16u);
      backing.PORT_portalIfc_messageSize_size_methodNumber = PORT_portalIfc_messageSize_size_methodNumber;
    }
}

void MOD_mkConnectalProcIndicationOutput::vcd_submodules(tVCDDumpType dt,
							 unsigned int levels,
							 MOD_mkConnectalProcIndicationOutput &backing)
{
  INST_indicationPipes.dump_VCD(dt, levels, backing.INST_indicationPipes);
}
