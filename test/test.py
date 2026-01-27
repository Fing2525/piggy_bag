# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

UART_TX_BIT = 2
CLK_PERIOD_US = 1   # 100 MHz


@cocotb.test()
async def test_project(dut):
    dut._log.info("=== START TEST ===")

    # ------------------------------------------------------------
    # Clock
    # ------------------------------------------------------------
    clock = Clock(dut.clk, CLK_PERIOD_US, unit="ns")
    cocotb.start_soon(clock.start())

    # ------------------------------------------------------------
    # Reset (ACTIVE HIGH)
    # ------------------------------------------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    dut.rst_n.value = 1   # reset asserted
    await ClockCycles(dut.clk, 20)

    dut.rst_n.value = 0   # reset released
    await ClockCycles(dut.clk, 50)

    dut._log.info("Reset released")

    # ------------------------------------------------------------
    # Wait for UART idle (TX = 1)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART idle")

    while True:
        await RisingEdge(dut.clk)

        if not dut.uo_out.value.is_resolvable:
            continue

        tx_bit = (dut.uo_out.value.to_unsigned() >> UART_TX_BIT) & 1
        if tx_bit == 1:
            break

    dut._log.info("UART idle detected")

    # ------------------------------------------------------------
    # Press button (debounced input)
    # ------------------------------------------------------------
    dut.ui_in.value = 0b00000100
    await ClockCycles(dut.clk, 400000)

    # ------------------------------------------------------------
    # Wait for UART start bit (TX = 0)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART start bit")

    timeout = 20000
    for _ in range(timeout):
        await RisingEdge(dut.clk)

        if not dut.uo_out.value.is_resolvable:
            continue

        tx_bit = (dut.uo_out.value.to_unsigned() >> UART_TX_BIT) & 1
        if tx_bit == 0:
            dut._log.info("UART start bit detected")
            break
    else:
        assert False, "UART start bit not detected (timeout)"

    # ------------------------------------------------------------
    # Release button
    # ------------------------------------------------------------
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 500)

    dut._log.info("=== TEST PASSED ===")
