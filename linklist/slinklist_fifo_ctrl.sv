// ============================================================
// File Name: slinklist_fifo_ctrl
// VERSION  : V1.0
// DATA     : 2025/02/17
// Author   : lijun
// ============================================================
// 功能：本模块主要维护链表的push和pop操作后的头指针、尾指针、链表深度
// 以及空和满的指示;
// ============================================================
module slinklist_fifo_ctrl
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
    //Llist Ram接口
    input   logic  [PTR_WIDTH-1: 0]     llist_pop_nxt_ptr     ,
    output  logic  [PTR_WIDTH-1: 0]     llist_pop_cur_ptr     ,
    output  logic  [PTR_WIDTH-1: 0]     llist_push_cur_ptr    ,
    output  logic  [PTR_WIDTH-1: 0]     llist_push_nxt_ptr    ,
    //链表状态接口
    output  logic  [PTR_WIDTH-1: 0]     llist_head            , //链表头指针;
    output  logic  [PTR_WIDTH-1: 0]     llist_tail            , //链表尾指针;
    output  logic  [PTR_WIDTH  : 0]     llist_depth           , //链表深度;
    output  logic                       llist_full            , //链表满;
    output  logic                       llist_empty           , //链表空;
    output  logic                       llist_err             , //链表错误;
    output  logic                       llist_init_done         //链表初始化完成;
);
//=============================================================
// 本地参数
// ============================================================
    localparam      LLIST_MAX_DEPTH     = 2 ** PTR_WIDTH      ;
// ============================================================
// 结构体定义
// ============================================================
//
// ============================================================
// 信号声明
// ============================================================
    logic                               d1_push_en            ;
    logic                               d1_pop_en             ;
    logic          [PTR_WIDTH  : 0]     d1_llist_depth        ;
    logic          [PTR_WIDTH-1: 0]     llist_head_tmp        ;
// ============================================================
// 逻辑处理
// ============================================================
//push和pop操作;
assign push_en = llist_push_en & ~llist_full  ; //真实的push动作,需要链表非满;
assign pop_en  = llist_pop_en  & ~llist_empty ; //真实的pop动作,需要链表非空;
//链表状态维护
//Linklist depth状态的维护;
add_sub_cnt #(
    .CNT_WIDTH     ( PTR_WIDTH+1         ), //计数器位宽;
    .CNT_LIMIT     ( 1'b1                )  //计数器限制,即计数器上下溢不做操作;
) u_add_sub_cnt
(
    .clk           ( clk                 ),
    .rst_n         ( cnt_rst_n           ), //复位输入;
    .add           ( push_en             ), //push加1
    .sub           ( pop_en              ), //pop减1
    .cnt           ( llist_depth         ), //最大深度大于2**PTR_WIDTH
    .cnt_overflow  (                     ),
    .cnt_underflow (                     )
);

assign cnt_rst_n = llist_init? 1'b0 : rst_n ; 
//链表空满状态维护;
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        llist_empty <= 1'b1 ;
    end
    else if ((pop_en && ~push_en && llist_depth == 'd1) || llist_init)  begin //如果当前深度只剩1个指针并且在无push的情况下pop则链表为空;
        llist_empty <= 1'b1 ;
    end
    else if (push_en && llist_empty) begin //链表为空的情况下肯定无pop动作,因此push动作后链表变为非空;
        llist_empty <= 1'b0 ;
    end
end

assign llist_full = (llist_depth > LLIST_MAX_DEPTH)? 1'b1 : 1'b0 ;
//pop,push,deep delay 1 cycle,对其外面链表ram;
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        d1_push_en     <= 1'b0 ;
        d1_pop_en      <= 1'b0 ;
        d1_llist_depth <= 'd0  ;
    end
    else begin
        d1_push_en     <= push_en     ;
        d1_pop_en      <= pop_en      ;
        d1_llist_depth <= llist_depth ;
    end
end
//链表头指针维护;
always @(*) begin
    if (llist_empty) begin
        if (push_en) begin //如果链表为空,push进去的第1个指针则为头指针;
            llist_head_tmp = llist_push_ptr ;
        end
        else begin //否则保持头指针不变;
            llist_head_tmp = llist_head ;
        end
    end
    else if (d1_pop_en) begin //pop的下一个cycle,因为指针是存储在ram中,读取ram需要1个cycle;
        if (d1_llist_depth == 'd1) begin //如果pop时链表就剩1个深度,即pop的是尾指针;
            if (d1_push_en) begin //并且当前还有push操作,则头指针和尾指针相同;
                llist_head_tmp = llist_tail ;
            end
            else begin //如果无push操作,则链表为空,此时头指针无意义可保持之前值;
                llist_head_tmp = llist_head ;
            end
        end
        else begin //如果当前非1个深度的情况,读出当前pop动作的next指针作为头地址;
            llist_head_tmp = llist_pop_nxt_ptr ;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        llist_head <= 'd0 ; //初始化头指针无效;
    end
    else begin
        llist_head <= llist_head_tmp ;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        llist_tail <= 'd0 ; //初始化尾指针无效;
    end
    else if (push_en) begin
        llist_tail <= llist_push_ptr ; //每push 1个将push的指针作为链表尾;
    end
end
//To Llist RAM
assign llist_push_cur_ptr = llist_empty? llist_push_ptr : llist_tail ; //如果是首次压入即链表空时则压入的指针即为当前指针,否则上次的尾指针即尾当前指针;
assign llist_push_nxt_ptr = llist_push_ptr ; //push的指针为下一跳指针;
assign llist_pop_cur_ptr  = (CONT_POP_EN & pop_en & d1_pop_en)? llist_pop_nxt_ptr : llist_head ; //pop_en时头指针为pop的当前指针;如果上个cycle就已发起了pop的操作,当前cycle还发起的pop的操作,则需要使用llist_pop_nxt_ptr作为新的head指针;

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        llist_pop_ptr <= 'd0 ; //初始化头指针无效;
    end
    else if (pop_en) begin
        llist_pop_ptr <= llist_head ;
    end
end
//DFX
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        llist_err <= 1'b0 ;
    end
    else if (llist_depth == 'd1 && llist_head_tmp != llist_tail) begin //链表深度为1时,如果当前链表头不等于链表尾上报错误;
        llist_err <= 1'b1 ;
    end
    else begin
        llist_err <= 1'b0 ;
    end
end

endmodule