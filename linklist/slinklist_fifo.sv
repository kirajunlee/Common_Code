// ============================================================
// File Name: slinklist_fifo
// VERSION  : V1.0
// DATA     : 2025/02/17
// Author   : lijun
// ============================================================
// 功能：
// ============================================================
module slinklist_fifo
#(
    parameter       CONT_POP_EN         = 1'b0                , //连续POP操作使能;
    parameter       PTR_WIDTH           = 8                     //链表节点位宽;
)
(
    input                               clk                   ,
    input                               rst_n                 ,
    //链表操作接口
    input                               llist_init            , //链表初始化操作,外部保证初始化时没有push和pop操作;
    input                               llist_push_en         , //链表压入指针操作;
    input          [PTR_WIDTH-1: 0]     llist_push_ptr        , //链表压入指针地址,对齐llist_push_en;
    input                               llist_pop_en          , //链表弹出指针操作;
    output  logic  [PTR_WIDTH-1: 0]     llist_pop_ptr         , //链表弹出指针地址,delay llist_pop_en 1 cycle;
    //链表状态接口
    output  logic  [PTR_WIDTH-1: 0]     llist_head            , //链表头指针;
    output  logic  [PTR_WIDTH-1: 0]     llist_tail            , //链表尾指针;
    output  logic  [PTR_WIDTH  : 0]     llist_depth           , //链表深度;
    output  logic                       llist_full            , //链表满;
    output  logic                       llist_empty           , //链表空;
    output  logic                       llist_init_done       , //链表初始化完成;
    output  logic  [ 1: 0]              llist_err               //链表错误;
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
    logic          [PTR_WIDTH-1: 0]     llist_pop_cur_ptr     ;
    logic          [PTR_WIDTH-1: 0]     llist_pop_nxt_ptr     ;
    logic          [PTR_WIDTH-1: 0]     llist_push_cur_ptr    ;
    logic          [PTR_WIDTH-1: 0]     llist_push_nxt_ptr    ;
// ============================================================
// 逻辑处理
// ============================================================
slinklist_fifo_ctrl
#(
    .CONT_POP_EN         ( CONT_POP_EN        ),
    .PTR_WIDTH           ( PTR_WIDTH          )
) u_slinklist_fifo_ctrl
(
    .clk                 ( clk                ), //时钟;
    .rst_n               ( rst_n              ), //复位;
    .llist_init          ( llist_init         ), //链表初始化操作,外部保证初始化时没有push和pop操作;
    .llist_push_en       ( llist_push_en      ), //链表压入指针操作;
    .llist_push_ptr      ( llist_push_ptr     ), //链表压入指针地址,对齐llist_push_en;
    .llist_pop_en        ( llist_pop_en       ), //链表弹出指针操作;
    .llist_pop_ptr       ( llist_pop_ptr      ), //链表弹出指针地址,delay llist_pop_en 1cycle;
    
    .llist_pop_nxt_ptr   ( llist_pop_nxt_ptr  ),
    .llist_pop_cur_ptr   ( llist_pop_cur_ptr  ),
    .llist_push_cur_ptr  ( llist_push_cur_ptr ),
    .llist_push_nxt_ptr  ( llist_push_nxt_ptr ),

    .llist_head          ( llist_head         ), //链表头指针;
    .llist_tail          ( llist_tail         ), //链表尾指针;
    .llist_depth         ( llist_depth        ), //链表深度;
    .llist_full          ( llist_full         ), //链表满;
    .llist_empty         ( llist_empty        ), //链表空;
    .llist_err           ( llist_err[0]       ), //链表错误;
    .llist_init_done     ( llist_init_done    )  //链表初始化完成;
);

slinklist_fifo_ram
#(
    .PTR_WIDTH           ( PTR_WIDTH          )
) u_slinklist_fifo_ram
(
    .clk                 ( clk                ), //时钟;
    .rst_n               ( rst_n              ), //复位;
    .llist_init_done     ( llist_init_done    ), //链表初始化完成;
    .llist_push_en       ( llist_push_en      ), //链表压入指针操作请求;
    .llist_push_cur_ptr  ( llist_push_cur_ptr ), //链表压入当前指针;
    .llist_push_nxt_ptr  ( llist_push_nxt_ptr ), //链表压入下个指针;  
    .llist_pop_en        ( llist_pop_en       ), //链表弹出指针操作请求;
    .llist_pop_cur_ptr   ( llist_pop_cur_ptr  ), //链表弹出指针地址;
    .llist_pop_nxt_ptr   ( llist_pop_nxt_ptr  ), //链表弹出指针地址;
    .llist_op_rdy        ( llist_op_rdy       ), //链表操作允许指示;
    .llist_op_err        ( llist_err[1]       )
);

endmodule