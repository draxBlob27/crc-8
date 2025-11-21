# Serial CRC-8 Generator (Verilog)

A synthesizable Verilog module that calculates an 8-bit Cyclic Redundancy Check (CRC) from a serial data stream. The module utilizes a Finite State Machine (FSM) for robust control and supports start/stop handshaking.

## Algorithm Specifications

This module is configured with the following CRC-8 parameters:

* **Polynomial:** `0x49` ($x^8 + x^6 + x^3 + 1$)
* **Initial Value:** `0x00`
* **XOR Output Mask:** `0xFF` (The final result is inverted)
* **Architecture:** Linear Feedback Shift Register (LFSR), processing 1 bit per clock cycle.

## Port Descriptions

| Signal Name  | Direction | Width | Description |
| :---         | :---      | :---  | :--- |
| `clk`        | Input     | 1     | System clock. |
| `rst`        | Input     | 1     | Active-high synchronous reset. |
| `data_in`    | Input     | 1     | Serial data bit input. |
| `data_valid` | Input     | 1     | Assert High when `data_in` is valid. |
| `last_bit`   | Input     | 1     | Assert High coincident with the final bit of the packet. |
| `crc_out`    | Output    | 8     | Calculated CRC checksum (valid when `crc_done` is High). |
| `crc_done`   | Output    | 1     | Pulsed High when calculation is complete. |

## State Machine & Logic

The module operates using a 3-state FSM:

1.  **IDLE:** Resets CRC register to `0x00`. Waits for `data_valid`.
2.  **PROCESS:** Shifts data into the LFSR. If `data_valid` and `last_bit` are both High, transitions to DONE.
3.  **DONE:** Applies the final XOR mask (`0xFF`) and asserts `crc_done`. Returns to IDLE when `data_valid` goes low.

## Integration

### Instantiation Template

```verilog
crc8_serial_gen u_crc8 (
    .clk        (clk),
    .rst        (rst),
    .data_in    (serial_data),
    .data_valid (data_valid_flag),
    .last_bit   (is_last_bit),
    .crc_out    (checksum_result),
    .crc_done   (checksum_valid)
);
