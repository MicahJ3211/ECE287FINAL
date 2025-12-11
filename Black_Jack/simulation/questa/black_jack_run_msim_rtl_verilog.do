transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/ECE_287/Final_Project/Black_Jack {D:/ECE_287/Final_Project/Black_Jack/vga_frame.v}
vlog -vlog01compat -work work +incdir+D:/ECE_287/Final_Project/Black_Jack {D:/ECE_287/Final_Project/Black_Jack/vga_frame_driver.v}
vlog -vlog01compat -work work +incdir+D:/ECE_287/Final_Project/Black_Jack {D:/ECE_287/Final_Project/Black_Jack/vga_driver.v}
vlog -vlog01compat -work work +incdir+D:/ECE_287/Final_Project/Black_Jack {D:/ECE_287/Final_Project/Black_Jack/debounce.v}
vlog -vlog01compat -work work +incdir+D:/ECE_287/Final_Project/Black_Jack {D:/ECE_287/Final_Project/Black_Jack/black_jack.v}
vlog -vlog01compat -work work +incdir+D:/ECE_287/Final_Project/Black_Jack {D:/ECE_287/Final_Project/Black_Jack/playing_card.v}
vlog -vlog01compat -work work +incdir+D:/ECE_287/Final_Project/Black_Jack {D:/ECE_287/Final_Project/Black_Jack/card_controller.v}

