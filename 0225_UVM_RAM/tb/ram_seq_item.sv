class ram_seq_item extends uvm_sequence_item;

    rand bit        we;
    rand bit [ 9:0] addr;
    rand bit [31:0] wdata;
    bit      [31:0] rdata;

    constraint addr_c {addr[1:0] == 2'b00;}

    function new(string name);
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "we = %0b, addr = 0x%03h, wdata = 0x%08h, rdata = 0x%08h",
            we,
            addr,
            wdata,
            rdata
        );
    endfunction

    `uvm_object_utils_begin(ram_seq_item)
        `uvm_field_int(we, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

endclass
