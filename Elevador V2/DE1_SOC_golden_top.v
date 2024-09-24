// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Jul 11 11:26:45 2013
// ============================================================================

`define ENABLE_ADC
`define ENABLE_AUD
`define ENABLE_CLOCK2
`define ENABLE_CLOCK3
`define ENABLE_CLOCK4
`define ENABLE_CLOCK
`define ENABLE_DRAM
`define ENABLE_FAN
`define ENABLE_FPGA
`define ENABLE_GPIO
`define ENABLE_HEX
//`define ENABLE_HPS
`define ENABLE_IRDA
`define ENABLE_KEY
`define ENABLE_LEDR
`define ENABLE_PS2
`define ENABLE_SW
`define ENABLE_TD
`define ENABLE_VGA

module DE1_SOC_golden_top(

      /* Enables ADC - 3.3V */
	`ifdef ENABLE_ADC

      output             ADC_CONVST,
      output             ADC_DIN,
      input              ADC_DOUT,
      output             ADC_SCLK,

	`endif

       /* Enables AUD - 3.3V */
	`ifdef ENABLE_AUD

      input              AUD_ADCDAT,
      inout              AUD_ADCLRCK,
      inout              AUD_BCLK,
      output             AUD_DACDAT,
      inout              AUD_DACLRCK,
      output             AUD_XCK,

	`endif

      /* Enables CLOCK2  */
	`ifdef ENABLE_CLOCK2
      input              CLOCK2_50,
	`endif

      /* Enables CLOCK3 */
	`ifdef ENABLE_CLOCK3
      input              CLOCK3_50,
	`endif

      /* Enables CLOCK4 */
	`ifdef ENABLE_CLOCK4
      input              CLOCK4_50,
	`endif

      /* Enables CLOCK */
	`ifdef ENABLE_CLOCK
      input              CLOCK_50,
	`endif

       /* Enables DRAM - 3.3V */
	`ifdef ENABLE_DRAM
      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,
	`endif

      /* Enables FAN - 3.3V */
	`ifdef ENABLE_FAN
      output             FAN_CTRL,
	`endif

      /* Enables FPGA - 3.3V */
	`ifdef ENABLE_FPGA
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,
	`endif

      /* Enables GPIO - 3.3V */
	`ifdef ENABLE_GPIO
      inout     [35:0]         GPIO_0,
      inout     [35:0]         GPIO_1,
	`endif
 

      /* Enables HEX - 3.3V */
	`ifdef ENABLE_HEX
      output      [6:0]  HEX0,
      output      [6:0]  HEX1,
      output      [6:0]  HEX2,
      output      [6:0]  HEX3,
      output      [6:0]  HEX4,
      output      [6:0]  HEX5,
	`endif
	
	/* Enables HPS */
	`ifdef ENABLE_HPS
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N, //1.5V
      output             HPS_DDR3_CK_P, //1.5V
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif 

      /* Enables IRDA - 3.3V */
	`ifdef ENABLE_IRDA
      input              IRDA_RXD,
      output             IRDA_TXD,
	`endif

      /* Enables KEY - 3.3V */
	`ifdef ENABLE_KEY
      input       [3:0]  KEY,
	`endif

      /* Enables LEDR - 3.3V */
	`ifdef ENABLE_LEDR
      output      [9:0]  LEDR,
	`endif

      /* Enables PS2 - 3.3V */
	`ifdef ENABLE_PS2
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,
	`endif

      /* Enables SW - 3.3V */
	`ifdef ENABLE_SW
      input       [9:0]  SW,
	`endif

      /* Enables TD - 3.3V */
	`ifdef ENABLE_TD
      input             TD_CLK27,
      input      [7:0]  TD_DATA,
      input             TD_HS,
      output            TD_RESET_N,
      input             TD_VS,
	`endif

      /* Enables VGA - 3.3V */
	`ifdef ENABLE_VGA
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      output             VGA_SYNC_N,
      output             VGA_VS
	`endif
);


//=======================================================
//  REG/WIRE declarations
//=======================================================



	
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	

  wire S1A, S2A, S3A, S4A, S5A;
  wire S1B, S2B, S3B, S4B, S5B;
  wire NOSTOPOUTA, NOSTOPOUTB;
  wire ALERTAA, ALERTAB;
  wire L1A, L2A, L3A, L4A, L5A;
  wire L1B, L2B, L3B, L4B, L5B;
  wire [1:0] MOTORA, MOTORB;
  wire [1:0] SENTIDOMOTORA, SENTIDOMOTORB;
  wire CLOCK_DIV;

  // Definindo os sinais como reg e wire da controladora
  reg BE1UP, BE2UP, BE2DOWN, BE3UP, BE3DOWN, BE4UP, BE4DOWN, BE5DOWN;
  wire L1UP, L2UP, L2DOWN, L3UP, L3DOWN, L4UP, L4DOWN, L5DOWN;
  wire ALERTAOUTA, ALERTAOUTB;

  // Instancia o módulo do divisor de frequencia
  divfreq div (
    .reset(!KEY[0]),
    .clock(CLOCK2_50),
    .clk_i(CLOCK_DIV));


  // Instâncias do módulo elevador
  elevador elevadorA (
    .reset(!KEY[0]),
    .clock(CLOCK_DIV),
    .bi1(GPIO_0[0]),
    .bi2(GPIO_0[1]),
    .bi3(GPIO_0[2]),
    .bi4(GPIO_0[3]),
    .bi5(GPIO_0[4]),
    .be1(E1A),
    .be2(E2A),
    .be3(E3A),
    .be4(E4A),
    .be5(E5A),
    .s1(S1A),
    .s2(S2A),
    .s3(S3A),
    .s4(S4A),
    .s5(S5A),
    .l1(L1A),
    .l2(L2A),
    .l3(L3A),
    .l4(L4A),
    .l5(L5A),
    .port1(LEDR[0]),
    .port2(LEDR[1]),
    .port3(LEDR[2]),
    .port4(LEDR[3]),
    .port5(LEDR[4]),
    .noStopIn(SW[0]),
    .noStopOut(NOSTOPOUTA),
    .alerta(ALERTAA),
    .motor(MOTORA),
    .displayInterno(HEX0),
    .sentidoMotor(SENTIDOMOTORA)
  );

  elevador elevadorB (
    .reset(!KEY[0]),
    .clock(CLOCK_DIV),
    .bi1(GPIO_0[5]),
    .bi2(GPIO_0[6]),
    .bi3(GPIO_0[7]),
    .bi4(GPIO_0[8]),
    .bi5(GPIO_0[9]),
    .be1(E1B),
    .be2(E2B),
    .be3(E3B),
    .be4(E4B),
    .be5(E5B),
    .s1(S1B),
    .s2(S2B),
    .s3(S3B),
    .s4(S4B),
    .s5(S5B),
    .l1(L1B),
    .l2(L2B),
    .l3(L3B),
    .l4(L4B),
    .l5(L5B),
    .port1(LEDR[5]),
    .port2(LEDR[6]),
    .port3(LEDR[7]),
    .port4(LEDR[8]),
    .port5(LEDR[9]),
    .noStopIn(SW[1]),
    .noStopOut(NOSTOPOUTB),
    .alerta(ALERTAB),
    .motor(MOTORB),
    .displayInterno(HEX1),
    .sentidoMotor(SENTIDOMOTORB)
  );

  // Instância da controladora
  controladora mycontroladora (
    .reset(!KEY[0]),
    .clock(CLOCK_DIV),
    .be1Up	(GPIO_1[0]),
    .be2Up	(GPIO_1[1]),
    .be2Down(GPIO_1[2]),
    .be3Up	(GPIO_1[3]),
    .be3Down(GPIO_1[4]),
    .be4Up	(GPIO_1[5]),
    .be4Down(GPIO_1[6]),
    .be5Down(GPIO_1[7]),
    .s1A(S1A),
    .s2A(S2A),
    .s3A(S3A),
    .s4A(S4A),
    .s5A(S5A),
    .s1B(S1B),
    .s2B(S2B),
    .s3B(S3B),
    .s4B(S4B),
    .s5B(S5B),
    .sentidoMotorA(SENTIDOMOTORA),
    .sentidoMotorB(SENTIDOMOTORB),
    .alertaInA(ALERTAA),
    .alertaInB(ALERTAB),
    .l1Up	(GPIO_1[8]),
    .l2Up	(GPIO_1[9]),
    .l2Down	(GPIO_1[10]),
    .l3Up	(GPIO_1[11]),
    .l3Down	(GPIO_1[12]),
    .l4Up	(GPIO_1[13]),
    .l4Down	(GPIO_1[14]),
    .l5Down	(GPIO_1[15]),
    .displayInternoA(HEX4),
    .displayInternoB(HEX5),
    .alertaOutA(ALERTAOUTA),
    .alertaOutB(ALERTAOUTB),
    .be1A(E1A),
    .be2A(E2A),
    .be3A(E3A),
    .be4A(E4A),
    .be5A(E5A),
    .be1B(E1B),
    .be2B(E2B),
    .be3B(E3B),
    .be4B(E4B),
    .be5B(E5B),
    .noStopA(NOSTOPOUTA),
    .noStopB(NOSTOPOUTB)
  );

   // Instâncias do sequenciador de pavimentos
  seq_pavimento pavimentosA(
    .clk(CLOCK_DIV),
    .rst(!KEY[0]),
    .motor(MOTORA),
    .s1(S1A),
    .s2(S2A),
    .s3(S3A),
    .s4(S4A),
    .s5(S5A)
  );

  seq_pavimento pavimentosB(
    .clk(CLOCK_DIV),
    .rst(!KEY[0]),
    .motor(MOTORB),
    .s1(S1B),
    .s2(S2B),
    .s3(S3B),
    .s4(S4B),
    .s5(S5B)
  );



//=======================================================
//  Structural coding
//=======================================================





endmodule
