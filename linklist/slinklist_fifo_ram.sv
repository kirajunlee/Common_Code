// ============================================================
// File Name: slinklist_fifo_ram
// VERSION  : V1.0
// DATA     : 2025/02/17
// Author   : lijun
// ============================================================
// 功能：本模块主要维护链表ram的读写操作;
// ============================================================
module slinklist_fifo_ram
#(
    parameter       PTR_WIDTH           = 8                     //链表节点位宽;
)
(
    input                               clk                   ,
    input                               rst_n                 ,
    // 链表操作接口
    input                               llist_init_done       ,
    input                               llist_push_en         , //链表压入指针操作请求;
    input          [PTR_WIDTH-1: 0]     llist_push_cur_ptr    , //链表压入当前指针;
    input          [PTR_WIDTH-1: 0]     llist_push_nxt_ptr    , //链表压入下个指针;
    input                               llist_pop_en          , //链表弹出指针操作请求;
    input          [PTR_WIDTH-1: 0]     llist_pop_cur_ptr     , //链表弹出指针地址;
    output  logic  [PTR_WIDTH-1: 0]     llist_pop_nxt_ptr     , //链表弹出指针地址;
    output  logic                       llist_op_rdy          , //链表操作允许指示;
    output  logic                       llist_op_err            //链表操作错误指示;
);
//=============================================================
// 本地参数
// ============================================================
//
// ============================================================
// 结构体定义
// ============================================================
//
// ============================================================
// 信号声明
// ============================================================
    logic                               llist_push_dly        ;
    logic  [PTR_WIDTH-1: 0]             d1_llist_push_cur_ptr ;
    logic  [PTR_WIDTH-1: 0]             d1_llist_push_nxt_ptr ;
    logic                               ram_wen               ;
    logic  [PTR_WIDTH-1: 0]             ram_addr              ;
    logic  [PTR_WIDTH-1: 0]             ram_din               ;
    logic  [PTR_WIDTH-1: 0]             ram_dout              ;
// ============================================================
// 逻辑处理
// ============================================================
// Linklist Ram 采用1rw,操作优先级上pop优先级高于push,因此如果push和pop同时请求push需要等待1 cycle;
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            llist_push_dly <= 1'b0 ;
        end
        else if (llist_pop_en && llist_push_en) begin //pop的同时进行push,需要把push操作delay
            llist_push_dly <= 1'b1 ;
        end
        else begin
            llist_push_dly <= 1'b0 ;
        end
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            d1_llist_push_cur_ptr <= 'd0 ;
            d1_llist_push_nxt_ptr <= 'd0 ;
        end
        else begin
            d1_llist_push_cur_ptr <= llist_push_cur_ptr ;
            d1_llist_push_nxt_ptr <= llist_push_nxt_ptr ;
        end
    end
    
    assign llist_op_rdy      = ~llist_push_dly & llist_init_done ; //当前没有delay 1 cycle的push操作时,并且初始化已完成则禁止操作;
    assign llist_pop_nxt_ptr =  ram_dout       ;
// Linklist Ram Op
    assign ram_wen           = (llist_push_en | llist_push_dly) & ~llist_pop_en ; //pop的时候固定不进行push,如果当拍有push则delay到下拍
// push操作的写地址为当前指针;
    assign ram_addr          = llist_pop_en? llist_pop_cur_ptr : llist_push_dly? d1_llist_push_cur_ptr : llist_push_cur_ptr ;
    assign ram_din           = llist_push_dly? d1_llist_push_nxt_ptr : llist_push_nxt_ptr  ;
//Spram
    spram_logic #(
        .ADDR_WIDTH        ( PTR_WIDTH        ), //地址位宽
        .DATA_WIDTH        ( PTR_WIDTH        ), //数据位宽
        .DOUT_REG          ( "false"          )  //寄存器输出;
    ) u_spram_logic (
        .clk               ( clk              ), //时钟
        .wen               ( ram_wen          ), //写使能
        .addr              ( ram_addr         ), //写地址
        .wdata             ( ram_din          ), //写数据
        .rdata             ( ram_dout         )  //读数据
    );
//DFX
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            llist_op_err <= 1'b0 ;
        end
        else if ((llist_pop_en || llist_push_en) && llist_push_dly) begin //当前llist_push_dly时如果有pop或push则上报个错误;
            llist_op_err <= 1'b1 ;
        end
        else begin
            llist_op_err <= 1'b0 ;
        end
    end

endmodule