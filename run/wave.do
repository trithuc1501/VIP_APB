onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {SYSTEM SIGNALS}
add wave -noupdate /tb_top/PCLK
add wave -noupdate /tb_top/vif/PRESETn

add wave -noupdate -divider {MASTER DRIVEN}
add wave -noupdate -group MASTER /tb_top/vif/PSEL
add wave -noupdate -group MASTER /tb_top/vif/PENABLE
add wave -noupdate -group MASTER -radix hexadecimal /tb_top/vif/PADDR
add wave -noupdate -group MASTER /tb_top/vif/PWRITE
add wave -noupdate -group MASTER -radix hexadecimal /tb_top/vif/PWDATA
add wave -noupdate -group MASTER -radix binary /tb_top/vif/PSTRB
add wave -noupdate -group MASTER /tb_top/vif/PPROT
add wave -noupdate -group MASTER /tb_top/vif/PNSE
add wave -noupdate -group MASTER /tb_top/vif/PWAKEUP
add wave -noupdate -group MASTER /tb_top/vif/PAUSER
add wave -noupdate -group MASTER /tb_top/vif/PWUSER

add wave -noupdate -divider {SLAVE DRIVEN}
add wave -noupdate -group SLAVE /tb_top/vif/PREADY
add wave -noupdate -group SLAVE -radix hexadecimal /tb_top/vif/PRDATA
add wave -noupdate -group SLAVE /tb_top/vif/PSLVERR
add wave -noupdate -group SLAVE /tb_top/vif/PRUSER
add wave -noupdate -group SLAVE /tb_top/vif/PBUSER

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits ns
update
