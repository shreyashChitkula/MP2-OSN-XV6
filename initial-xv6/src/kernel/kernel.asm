
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	2b013103          	ld	sp,688(sp) # 8000b2b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	0000b717          	auipc	a4,0xb
    80000054:	2c070713          	addi	a4,a4,704 # 8000b310 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	0be78793          	addi	a5,a5,190 # 80006120 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd5faf>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	addi	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	466080e7          	jalr	1126(ra) # 80002590 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	addi	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00013517          	auipc	a0,0x13
    80000190:	2c450513          	addi	a0,a0,708 # 80013450 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	2b448493          	addi	s1,s1,692 # 80013450 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	34490913          	addi	s2,s2,836 # 800134e8 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	886080e7          	jalr	-1914(ra) # 80001a42 <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	216080e7          	jalr	534(ra) # 800023da <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	f54080e7          	jalr	-172(ra) # 80002126 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	26870713          	addi	a4,a4,616 # 80013450 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	320080e7          	jalr	800(ra) # 8000253a <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	addi	s4,s4,1
    --n;
    8000022a:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00013517          	auipc	a0,0x13
    8000023a:	21a50513          	addi	a0,a0,538 # 80013450 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	addi	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00013717          	auipc	a4,0x13
    80000268:	28f72223          	sw	a5,644(a4) # 800134e8 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	1d650513          	addi	a0,a0,470 # 80013450 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	addi	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	16e50513          	addi	a0,a0,366 # 80013450 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	2de080e7          	jalr	734(ra) # 800025e6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	14050513          	addi	a0,a0,320 # 80013450 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	addi	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00013717          	auipc	a4,0x13
    80000336:	11e70713          	addi	a4,a4,286 # 80013450 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00013797          	auipc	a5,0x13
    80000360:	0f478793          	addi	a5,a5,244 # 80013450 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addiw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	andi	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00013797          	auipc	a5,0x13
    8000038e:	15e7a783          	lw	a5,350(a5) # 800134e8 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	0b070713          	addi	a4,a4,176 # 80013450 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	0a048493          	addi	s1,s1,160 # 80013450 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00013717          	auipc	a4,0x13
    800003fa:	05a70713          	addi	a4,a4,90 # 80013450 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	0ef72223          	sw	a5,228(a4) # 800134f0 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00013797          	auipc	a5,0x13
    80000436:	01e78793          	addi	a5,a5,30 # 80013450 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addiw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	andi	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	08c7ab23          	sw	a2,150(a5) # 800134ec <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	08a50513          	addi	a0,a0,138 # 800134e8 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	d24080e7          	jalr	-732(ra) # 8000218a <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	addi	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	addi	a1,a1,-1144 # 80008000 <etext>
    80000480:	00013517          	auipc	a0,0x13
    80000484:	fd050513          	addi	a0,a0,-48 # 80013450 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00027797          	auipc	a5,0x27
    8000049c:	22078793          	addi	a5,a5,544 # 800276b8 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	addi	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	addi	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	addi	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	26a60613          	addi	a2,a2,618 # 80008740 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	addi	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addiw	a4,a4,-1
    80000532:	1702                	slli	a4,a4,0x20
    80000534:	9301                	srli	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	addi	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00013797          	auipc	a5,0x13
    80000570:	fa07a223          	sw	zero,-92(a5) # 80013510 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	addi	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	addi	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	0000b717          	auipc	a4,0xb
    800005a4:	d2f72823          	sw	a5,-720(a4) # 8000b2d0 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	addi	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00013d17          	auipc	s10,0x13
    800005ce:	f46d2d03          	lw	s10,-186(s10) # 80013510 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	138a8a93          	addi	s5,s5,312 # 80008740 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00013517          	auipc	a0,0x13
    8000061e:	ede50513          	addi	a0,a0,-290 # 800134f8 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	addi	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addiw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addiw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srli	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	slli	s2,s2,0x4
    8000070c:	34fd                	addiw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	addi	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	addi	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	addi	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	addi	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00013517          	auipc	a0,0x13
    800007a4:	d5850513          	addi	a0,a0,-680 # 800134f8 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	addi	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00013497          	auipc	s1,0x13
    800007c0:	d3c48493          	addi	s1,s1,-708 # 800134f8 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86c58593          	addi	a1,a1,-1940 # 80008030 <etext+0x30>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	addi	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	addi	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	addi	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00013517          	auipc	a0,0x13
    8000082c:	cf050513          	addi	a0,a0,-784 # 80013518 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	addi	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	addi	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	0000b797          	auipc	a5,0xb
    80000858:	a7c7a783          	lw	a5,-1412(a5) # 8000b2d0 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	andi	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	addi	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	0000b797          	auipc	a5,0xb
    80000892:	a4a7b783          	ld	a5,-1462(a5) # 8000b2d8 <uart_tx_r>
    80000896:	0000b717          	auipc	a4,0xb
    8000089a:	a4a73703          	ld	a4,-1462(a4) # 8000b2e0 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	addi	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00013a97          	auipc	s5,0x13
    800008c0:	c5ca8a93          	addi	s5,s5,-932 # 80013518 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	0000b497          	auipc	s1,0xb
    800008c8:	a1448493          	addi	s1,s1,-1516 # 8000b2d8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	0000b997          	auipc	s3,0xb
    800008d4:	a1098993          	addi	s3,s3,-1520 # 8000b2e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	andi	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	andi	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	addi	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	898080e7          	jalr	-1896(ra) # 8000218a <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	addi	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	addi	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	addi	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00013517          	auipc	a0,0x13
    80000934:	be850513          	addi	a0,a0,-1048 # 80013518 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	0000b797          	auipc	a5,0xb
    80000944:	9907a783          	lw	a5,-1648(a5) # 8000b2d0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	0000b717          	auipc	a4,0xb
    8000094e:	99673703          	ld	a4,-1642(a4) # 8000b2e0 <uart_tx_w>
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	9867b783          	ld	a5,-1658(a5) # 8000b2d8 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00013997          	auipc	s3,0x13
    80000962:	bba98993          	addi	s3,s3,-1094 # 80013518 <uart_tx_lock>
    80000966:	0000b497          	auipc	s1,0xb
    8000096a:	97248493          	addi	s1,s1,-1678 # 8000b2d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	0000b917          	auipc	s2,0xb
    80000972:	97290913          	addi	s2,s2,-1678 # 8000b2e0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00001097          	auipc	ra,0x1
    80000982:	7a8080e7          	jalr	1960(ra) # 80002126 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00013497          	auipc	s1,0x13
    80000998:	b8448493          	addi	s1,s1,-1148 # 80013518 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	0000b797          	auipc	a5,0xb
    800009ac:	92e7bc23          	sd	a4,-1736(a5) # 8000b2e0 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	addi	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	addi	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	andi	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	addi	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00013497          	auipc	s1,0x13
    80000a20:	afc48493          	addi	s1,s1,-1284 # 80013518 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	addi	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	slli	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	00028797          	auipc	a5,0x28
    80000a62:	df278793          	addi	a5,a5,-526 # 80028850 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	slli	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00013917          	auipc	s2,0x13
    80000a82:	ad290913          	addi	s2,s2,-1326 # 80013550 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	addi	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	59050513          	addi	a0,a0,1424 # 80008040 <etext+0x40>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	addi	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	addi	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	addi	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	53458593          	addi	a1,a1,1332 # 80008048 <etext+0x48>
    80000b1c:	00013517          	auipc	a0,0x13
    80000b20:	a3450513          	addi	a0,a0,-1484 # 80013550 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00028517          	auipc	a0,0x28
    80000b34:	d2050513          	addi	a0,a0,-736 # 80028850 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	addi	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00013497          	auipc	s1,0x13
    80000b56:	9fe48493          	addi	s1,s1,-1538 # 80013550 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00013517          	auipc	a0,0x13
    80000b6e:	9e650513          	addi	a0,a0,-1562 # 80013550 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	addi	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00013517          	auipc	a0,0x13
    80000b9a:	9ba50513          	addi	a0,a0,-1606 # 80013550 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	addi	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	addi	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	addi	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	e54080e7          	jalr	-428(ra) # 80001a26 <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	addi	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	addi	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e22080e7          	jalr	-478(ra) # 80001a26 <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e16080e7          	jalr	-490(ra) # 80001a26 <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addiw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	dfe080e7          	jalr	-514(ra) # 80001a26 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srli	s1,s1,0x1
    80000c32:	8885                	andi	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	addi	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	addi	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dbe080e7          	jalr	-578(ra) # 80001a26 <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	addi	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3d450513          	addi	a0,a0,980 # 80008050 <etext+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	addi	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	d92080e7          	jalr	-622(ra) # 80001a26 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addiw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	addi	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	38c50513          	addi	a0,a0,908 # 80008058 <etext+0x58>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	addi	a0,a0,916 # 80008070 <etext+0x70>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	addi	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	addi	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d0a:	0310000f          	fence	rw,w
    80000d0e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	addi	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	35450513          	addi	a0,a0,852 # 80008078 <etext+0x78>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	addi	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	slli	a2,a2,0x20
    80000d40:	9201                	srli	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	addi	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	slli	a3,a3,0x20
    80000d64:	9281                	srli	a3,a3,0x20
    80000d66:	0685                	addi	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	addi	a0,a0,1
    80000d78:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	addi	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	slli	a2,a2,0x20
    80000d9e:	9201                	srli	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	addi	a1,a1,1
    80000da8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd67b1>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	slli	a3,a2,0x20
    80000dc0:	9281                	srli	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addiw	a5,a2,-1
    80000dd0:	1782                	slli	a5,a5,0x20
    80000dd2:	9381                	srli	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	addi	a4,a4,-1
    80000ddc:	16fd                	addi	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	addi	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addiw	a2,a2,-1
    80000e1c:	0505                	addi	a0,a0,1
    80000e1e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	addi	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addiw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	addi	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addiw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	addi	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	addi	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	addi	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addiw	a3,a2,-1
    80000e84:	1682                	slli	a3,a3,0x20
    80000e86:	9281                	srli	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	addi	a1,a1,1
    80000e92:	0785                	addi	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	addi	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	addi	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	addi	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	addi	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b3c080e7          	jalr	-1220(ra) # 80001a16 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	0000a717          	auipc	a4,0xa
    80000ee6:	40670713          	addi	a4,a4,1030 # 8000b2e8 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b20080e7          	jalr	-1248(ra) # 80001a16 <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	addi	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00002097          	auipc	ra,0x2
    80000f1c:	9ba080e7          	jalr	-1606(ra) # 800028d2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	244080e7          	jalr	580(ra) # 80006164 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	04c080e7          	jalr	76(ra) # 80001f74 <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	0d050513          	addi	a0,a0,208 # 80008010 <etext+0x10>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	13050513          	addi	a0,a0,304 # 80008080 <etext+0x80>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	0b050513          	addi	a0,a0,176 # 80008010 <etext+0x10>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	9d0080e7          	jalr	-1584(ra) # 80001958 <procinit>
    trapinit();      // trap vectors
    80000f90:	00002097          	auipc	ra,0x2
    80000f94:	91a080e7          	jalr	-1766(ra) # 800028aa <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	93a080e7          	jalr	-1734(ra) # 800028d2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	1aa080e7          	jalr	426(ra) # 8000614a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	1bc080e7          	jalr	444(ra) # 80006164 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	282080e7          	jalr	642(ra) # 80003232 <binit>
    iinit();         // inode table
    80000fb8:	00003097          	auipc	ra,0x3
    80000fbc:	938080e7          	jalr	-1736(ra) # 800038f0 <iinit>
    fileinit();      // file table
    80000fc0:	00004097          	auipc	ra,0x4
    80000fc4:	8e8080e7          	jalr	-1816(ra) # 800048a8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	2a4080e7          	jalr	676(ra) # 8000626c <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	d70080e7          	jalr	-656(ra) # 80001d40 <userinit>
    __sync_synchronize();
    80000fd8:	0330000f          	fence	rw,rw
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	0000a717          	auipc	a4,0xa
    80000fe2:	30f72523          	sw	a5,778(a4) # 8000b2e8 <started>
    80000fe6:	b789                	j	80000f28 <main+0x56>

0000000080000fe8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	0000a797          	auipc	a5,0xa
    80000ff6:	2fe7b783          	ld	a5,766(a5) # 8000b2f0 <kernel_pagetable>
    80000ffa:	83b1                	srli	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	slli	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	addi	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	addi	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	addi	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srli	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	04b7f263          	bgeu	a5,a1,80001076 <walk+0x66>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	07a50513          	addi	a0,a0,122 # 800080b0 <etext+0xb0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	522080e7          	jalr	1314(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001046:	060a8663          	beqz	s5,800010b2 <walk+0xa2>
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80001052:	84aa                	mv	s1,a0
    80001054:	c529                	beqz	a0,8000109e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001056:	6605                	lui	a2,0x1
    80001058:	4581                	li	a1,0
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	cda080e7          	jalr	-806(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001062:	00c4d793          	srli	a5,s1,0xc
    80001066:	07aa                	slli	a5,a5,0xa
    80001068:	0017e793          	ori	a5,a5,1
    8000106c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001070:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd67a7>
    80001072:	036a0063          	beq	s4,s6,80001092 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	andi	s2,s2,511
    8000107e:	090e                	slli	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	andi	a5,s1,1
    8000108a:	dfd5                	beqz	a5,80001046 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srli	s1,s1,0xa
    8000108e:	04b2                	slli	s1,s1,0xc
    80001090:	b7c5                	j	80001070 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001092:	00c9d513          	srli	a0,s3,0xc
    80001096:	1ff57513          	andi	a0,a0,511
    8000109a:	050e                	slli	a0,a0,0x3
    8000109c:	9526                	add	a0,a0,s1
}
    8000109e:	70e2                	ld	ra,56(sp)
    800010a0:	7442                	ld	s0,48(sp)
    800010a2:	74a2                	ld	s1,40(sp)
    800010a4:	7902                	ld	s2,32(sp)
    800010a6:	69e2                	ld	s3,24(sp)
    800010a8:	6a42                	ld	s4,16(sp)
    800010aa:	6aa2                	ld	s5,8(sp)
    800010ac:	6b02                	ld	s6,0(sp)
    800010ae:	6121                	addi	sp,sp,64
    800010b0:	8082                	ret
        return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7ed                	j	8000109e <walk+0x8e>

00000000800010b6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b6:	57fd                	li	a5,-1
    800010b8:	83e9                	srli	a5,a5,0x1a
    800010ba:	00b7f463          	bgeu	a5,a1,800010c2 <walkaddr+0xc>
    return 0;
    800010be:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c0:	8082                	ret
{
    800010c2:	1141                	addi	sp,sp,-16
    800010c4:	e406                	sd	ra,8(sp)
    800010c6:	e022                	sd	s0,0(sp)
    800010c8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ca:	4601                	li	a2,0
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f44080e7          	jalr	-188(ra) # 80001010 <walk>
  if(pte == 0)
    800010d4:	c105                	beqz	a0,800010f4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d8:	0117f693          	andi	a3,a5,17
    800010dc:	4745                	li	a4,17
    return 0;
    800010de:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e0:	00e68663          	beq	a3,a4,800010ec <walkaddr+0x36>
}
    800010e4:	60a2                	ld	ra,8(sp)
    800010e6:	6402                	ld	s0,0(sp)
    800010e8:	0141                	addi	sp,sp,16
    800010ea:	8082                	ret
  pa = PTE2PA(*pte);
    800010ec:	83a9                	srli	a5,a5,0xa
    800010ee:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010f2:	bfcd                	j	800010e4 <walkaddr+0x2e>
    return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7fd                	j	800010e4 <walkaddr+0x2e>

00000000800010f8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f8:	715d                	addi	sp,sp,-80
    800010fa:	e486                	sd	ra,72(sp)
    800010fc:	e0a2                	sd	s0,64(sp)
    800010fe:	fc26                	sd	s1,56(sp)
    80001100:	f84a                	sd	s2,48(sp)
    80001102:	f44e                	sd	s3,40(sp)
    80001104:	f052                	sd	s4,32(sp)
    80001106:	ec56                	sd	s5,24(sp)
    80001108:	e85a                	sd	s6,16(sp)
    8000110a:	e45e                	sd	s7,8(sp)
    8000110c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110e:	c639                	beqz	a2,8000115c <mappages+0x64>
    80001110:	8aaa                	mv	s5,a0
    80001112:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001114:	777d                	lui	a4,0xfffff
    80001116:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111a:	fff58993          	addi	s3,a1,-1
    8000111e:	99b2                	add	s3,s3,a2
    80001120:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001124:	893e                	mv	s2,a5
    80001126:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112a:	6b85                	lui	s7,0x1
    8000112c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eda080e7          	jalr	-294(ra) # 80001010 <walk>
    8000113e:	cd1d                	beqz	a0,8000117c <mappages+0x84>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	andi	a5,a5,1
    80001144:	e785                	bnez	a5,8000116c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srli	s1,s1,0xc
    80001148:	04aa                	slli	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	ori	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	05390063          	beq	s2,s3,80001194 <mappages+0x9c>
    a += PGSIZE;
    80001158:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115a:	bfc9                	j	8000112c <mappages+0x34>
    panic("mappages: size");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f5c50513          	addi	a0,a0,-164 # 800080b8 <etext+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	f5c50513          	addi	a0,a0,-164 # 800080c8 <etext+0xc8>
    80001174:	fffff097          	auipc	ra,0xfffff
    80001178:	3ec080e7          	jalr	1004(ra) # 80000560 <panic>
      return -1;
    8000117c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117e:	60a6                	ld	ra,72(sp)
    80001180:	6406                	ld	s0,64(sp)
    80001182:	74e2                	ld	s1,56(sp)
    80001184:	7942                	ld	s2,48(sp)
    80001186:	79a2                	ld	s3,40(sp)
    80001188:	7a02                	ld	s4,32(sp)
    8000118a:	6ae2                	ld	s5,24(sp)
    8000118c:	6b42                	ld	s6,16(sp)
    8000118e:	6ba2                	ld	s7,8(sp)
    80001190:	6161                	addi	sp,sp,80
    80001192:	8082                	ret
  return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7e5                	j	8000117e <mappages+0x86>

0000000080001198 <kvmmap>:
{
    80001198:	1141                	addi	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	addi	s0,sp,16
    800011a0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a2:	86b2                	mv	a3,a2
    800011a4:	863e                	mv	a2,a5
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f52080e7          	jalr	-174(ra) # 800010f8 <mappages>
    800011ae:	e509                	bnez	a0,800011b8 <kvmmap+0x20>
}
    800011b0:	60a2                	ld	ra,8(sp)
    800011b2:	6402                	ld	s0,0(sp)
    800011b4:	0141                	addi	sp,sp,16
    800011b6:	8082                	ret
    panic("kvmmap");
    800011b8:	00007517          	auipc	a0,0x7
    800011bc:	f2050513          	addi	a0,a0,-224 # 800080d8 <etext+0xd8>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	3a0080e7          	jalr	928(ra) # 80000560 <panic>

00000000800011c8 <kvmmake>:
{
    800011c8:	1101                	addi	sp,sp,-32
    800011ca:	ec06                	sd	ra,24(sp)
    800011cc:	e822                	sd	s0,16(sp)
    800011ce:	e426                	sd	s1,8(sp)
    800011d0:	e04a                	sd	s2,0(sp)
    800011d2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	974080e7          	jalr	-1676(ra) # 80000b48 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011de:	6605                	lui	a2,0x1
    800011e0:	4581                	li	a1,0
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	b52080e7          	jalr	-1198(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	6685                	lui	a3,0x1
    800011ee:	10000637          	lui	a2,0x10000
    800011f2:	100005b7          	lui	a1,0x10000
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	fa0080e7          	jalr	-96(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10001637          	lui	a2,0x10001
    80001208:	100015b7          	lui	a1,0x10001
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f8a080e7          	jalr	-118(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	004006b7          	lui	a3,0x400
    8000121c:	0c000637          	lui	a2,0xc000
    80001220:	0c0005b7          	lui	a1,0xc000
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f72080e7          	jalr	-142(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122e:	00007917          	auipc	s2,0x7
    80001232:	dd290913          	addi	s2,s2,-558 # 80008000 <etext>
    80001236:	4729                	li	a4,10
    80001238:	80007697          	auipc	a3,0x80007
    8000123c:	dc868693          	addi	a3,a3,-568 # 8000 <_entry-0x7fff8000>
    80001240:	4605                	li	a2,1
    80001242:	067e                	slli	a2,a2,0x1f
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f50080e7          	jalr	-176(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001250:	46c5                	li	a3,17
    80001252:	06ee                	slli	a3,a3,0x1b
    80001254:	4719                	li	a4,6
    80001256:	412686b3          	sub	a3,a3,s2
    8000125a:	864a                	mv	a2,s2
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f38080e7          	jalr	-200(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001268:	4729                	li	a4,10
    8000126a:	6685                	lui	a3,0x1
    8000126c:	00006617          	auipc	a2,0x6
    80001270:	d9460613          	addi	a2,a2,-620 # 80007000 <_trampoline>
    80001274:	040005b7          	lui	a1,0x4000
    80001278:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000127a:	05b2                	slli	a1,a1,0xc
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f1a080e7          	jalr	-230(ra) # 80001198 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001286:	8526                	mv	a0,s1
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	630080e7          	jalr	1584(ra) # 800018b8 <proc_mapstacks>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	addi	sp,sp,32
    8000129c:	8082                	ret

000000008000129e <kvminit>:
{
    8000129e:	1141                	addi	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f22080e7          	jalr	-222(ra) # 800011c8 <kvmmake>
    800012ae:	0000a797          	auipc	a5,0xa
    800012b2:	04a7b123          	sd	a0,66(a5) # 8000b2f0 <kernel_pagetable>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	addi	sp,sp,16
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	715d                	addi	sp,sp,-80
    800012c0:	e486                	sd	ra,72(sp)
    800012c2:	e0a2                	sd	s0,64(sp)
    800012c4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c6:	03459793          	slli	a5,a1,0x34
    800012ca:	e39d                	bnez	a5,800012f0 <uvmunmap+0x32>
    800012cc:	f84a                	sd	s2,48(sp)
    800012ce:	f44e                	sd	s3,40(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e85a                	sd	s6,16(sp)
    800012d6:	e45e                	sd	s7,8(sp)
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	slli	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	6b05                	lui	s6,0x1
    800012e8:	0935fb63          	bgeu	a1,s3,8000137e <uvmunmap+0xc0>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	a8a9                	j	80001348 <uvmunmap+0x8a>
    800012f0:	fc26                	sd	s1,56(sp)
    800012f2:	f84a                	sd	s2,48(sp)
    800012f4:	f44e                	sd	s3,40(sp)
    800012f6:	f052                	sd	s4,32(sp)
    800012f8:	ec56                	sd	s5,24(sp)
    800012fa:	e85a                	sd	s6,16(sp)
    800012fc:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	de250513          	addi	a0,a0,-542 # 800080e0 <etext+0xe0>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	25a080e7          	jalr	602(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000130e:	00007517          	auipc	a0,0x7
    80001312:	dea50513          	addi	a0,a0,-534 # 800080f8 <etext+0xf8>
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	dea50513          	addi	a0,a0,-534 # 80008108 <etext+0x108>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	df250513          	addi	a0,a0,-526 # 80008120 <etext+0x120>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	995a                	add	s2,s2,s6
    80001344:	03397c63          	bgeu	s2,s3,8000137c <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001348:	4601                	li	a2,0
    8000134a:	85ca                	mv	a1,s2
    8000134c:	8552                	mv	a0,s4
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	cc2080e7          	jalr	-830(ra) # 80001010 <walk>
    80001356:	84aa                	mv	s1,a0
    80001358:	d95d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000135a:	6108                	ld	a0,0(a0)
    8000135c:	00157793          	andi	a5,a0,1
    80001360:	dfdd                	beqz	a5,8000131e <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	3ff57793          	andi	a5,a0,1023
    80001366:	fd7784e3          	beq	a5,s7,8000132e <uvmunmap+0x70>
    if(do_free){
    8000136a:	fc0a8ae3          	beqz	s5,8000133e <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001370:	0532                	slli	a0,a0,0xc
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	6d8080e7          	jalr	1752(ra) # 80000a4a <kfree>
    8000137a:	b7d1                	j	8000133e <uvmunmap+0x80>
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
  }
}
    8000138a:	60a6                	ld	ra,72(sp)
    8000138c:	6406                	ld	s0,64(sp)
    8000138e:	6161                	addi	sp,sp,80
    80001390:	8082                	ret

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	addi	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	7ac080e7          	jalr	1964(ra) # 80000b48 <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	988080e7          	jalr	-1656(ra) # 80000d34 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	addi	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	addi	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvmfirst+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	76c080e7          	jalr	1900(ra) # 80000b48 <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	94a080e7          	jalr	-1718(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	cfc080e7          	jalr	-772(ra) # 800010f8 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	986080e7          	jalr	-1658(ra) # 80000d90 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	addi	sp,sp,48
    80001420:	8082                	ret
    panic("uvmfirst: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d1650513          	addi	a0,a0,-746 # 80008138 <etext+0x138>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	136080e7          	jalr	310(ra) # 80000560 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	addi	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	76fd                	lui	a3,0xfffff
    8000144e:	8f75                	and	a4,a4,a3
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff5                	and	a5,a5,a3
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	addi	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e4e080e7          	jalr	-434(ra) # 800012be <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66b63          	bltu	a2,a1,80001530 <uvmalloc+0xb6>
{
    8000147e:	7139                	addi	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	addi	s0,sp,64
    8000148c:	8aaa                	mv	s5,a0
    8000148e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	77fd                	lui	a5,0xfffff
    80001498:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149c:	08c9fc63          	bgeu	s3,a2,80001534 <uvmalloc+0xba>
    800014a0:	f426                	sd	s1,40(sp)
    800014a2:	f04a                	sd	s2,32(sp)
    800014a4:	e05a                	sd	s6,0(sp)
    800014a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a8:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	69c080e7          	jalr	1692(ra) # 80000b48 <kalloc>
    800014b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b6:	c915                	beqz	a0,800014ea <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b8:	6605                	lui	a2,0x1
    800014ba:	4581                	li	a1,0
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	878080e7          	jalr	-1928(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c4:	875a                	mv	a4,s6
    800014c6:	86a6                	mv	a3,s1
    800014c8:	6605                	lui	a2,0x1
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	c2a080e7          	jalr	-982(ra) # 800010f8 <mappages>
    800014d6:	ed05                	bnez	a0,8000150e <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d8:	6785                	lui	a5,0x1
    800014da:	993e                	add	s2,s2,a5
    800014dc:	fd4968e3          	bltu	s2,s4,800014ac <uvmalloc+0x32>
  return newsz;
    800014e0:	8552                	mv	a0,s4
    800014e2:	74a2                	ld	s1,40(sp)
    800014e4:	7902                	ld	s2,32(sp)
    800014e6:	6b02                	ld	s6,0(sp)
    800014e8:	a821                	j	80001500 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014ea:	864e                	mv	a2,s3
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f42080e7          	jalr	-190(ra) # 80001432 <uvmdealloc>
      return 0;
    800014f8:	4501                	li	a0,0
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	6b02                	ld	s6,0(sp)
}
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	69e2                	ld	s3,24(sp)
    80001506:	6a42                	ld	s4,16(sp)
    80001508:	6aa2                	ld	s5,8(sp)
    8000150a:	6121                	addi	sp,sp,64
    8000150c:	8082                	ret
      kfree(mem);
    8000150e:	8526                	mv	a0,s1
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	53a080e7          	jalr	1338(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	864e                	mv	a2,s3
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f14080e7          	jalr	-236(ra) # 80001432 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74a2                	ld	s1,40(sp)
    8000152a:	7902                	ld	s2,32(sp)
    8000152c:	6b02                	ld	s6,0(sp)
    8000152e:	bfc9                	j	80001500 <uvmalloc+0x86>
    return oldsz;
    80001530:	852e                	mv	a0,a1
}
    80001532:	8082                	ret
  return newsz;
    80001534:	8532                	mv	a0,a2
    80001536:	b7e9                	j	80001500 <uvmalloc+0x86>

0000000080001538 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001538:	7179                	addi	sp,sp,-48
    8000153a:	f406                	sd	ra,40(sp)
    8000153c:	f022                	sd	s0,32(sp)
    8000153e:	ec26                	sd	s1,24(sp)
    80001540:	e84a                	sd	s2,16(sp)
    80001542:	e44e                	sd	s3,8(sp)
    80001544:	e052                	sd	s4,0(sp)
    80001546:	1800                	addi	s0,sp,48
    80001548:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154a:	84aa                	mv	s1,a0
    8000154c:	6905                	lui	s2,0x1
    8000154e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001550:	4985                	li	s3,1
    80001552:	a829                	j	8000156c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001554:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001556:	00c79513          	slli	a0,a5,0xc
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	fde080e7          	jalr	-34(ra) # 80001538 <freewalk>
      pagetable[i] = 0;
    80001562:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001566:	04a1                	addi	s1,s1,8
    80001568:	03248163          	beq	s1,s2,8000158a <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156e:	00f7f713          	andi	a4,a5,15
    80001572:	ff3701e3          	beq	a4,s3,80001554 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001576:	8b85                	andi	a5,a5,1
    80001578:	d7fd                	beqz	a5,80001566 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bde50513          	addi	a0,a0,-1058 # 80008158 <etext+0x158>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fde080e7          	jalr	-34(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158a:	8552                	mv	a0,s4
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4be080e7          	jalr	1214(ra) # 80000a4a <kfree>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	addi	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a4:	1101                	addi	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	addi	s0,sp,32
    800015ae:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b0:	e999                	bnez	a1,800015c6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	f84080e7          	jalr	-124(ra) # 80001538 <freewalk>
}
    800015bc:	60e2                	ld	ra,24(sp)
    800015be:	6442                	ld	s0,16(sp)
    800015c0:	64a2                	ld	s1,8(sp)
    800015c2:	6105                	addi	sp,sp,32
    800015c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c6:	6785                	lui	a5,0x1
    800015c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015ca:	95be                	add	a1,a1,a5
    800015cc:	4685                	li	a3,1
    800015ce:	00c5d613          	srli	a2,a1,0xc
    800015d2:	4581                	li	a1,0
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	cea080e7          	jalr	-790(ra) # 800012be <uvmunmap>
    800015dc:	bfd9                	j	800015b2 <uvmfree+0xe>

00000000800015de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015de:	c679                	beqz	a2,800016ac <uvmcopy+0xce>
{
    800015e0:	715d                	addi	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	0880                	addi	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85ce                	mv	a1,s3
    80001602:	855a                	mv	a0,s6
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a0c080e7          	jalr	-1524(ra) # 80001010 <walk>
    8000160c:	c531                	beqz	a0,80001658 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	andi	a5,a4,1
    80001614:	cbb1                	beqz	a5,80001668 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75593          	srli	a1,a4,0xa
    8000161a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	526080e7          	jalr	1318(ra) # 80000b48 <kalloc>
    8000162a:	892a                	mv	s2,a0
    8000162c:	c939                	beqz	a0,80001682 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	75e080e7          	jalr	1886(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	8726                	mv	a4,s1
    8000163c:	86ca                	mv	a3,s2
    8000163e:	6605                	lui	a2,0x1
    80001640:	85ce                	mv	a1,s3
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	ab4080e7          	jalr	-1356(ra) # 800010f8 <mappages>
    8000164c:	e515                	bnez	a0,80001678 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	6785                	lui	a5,0x1
    80001650:	99be                	add	s3,s3,a5
    80001652:	fb49e6e3          	bltu	s3,s4,800015fe <uvmcopy+0x20>
    80001656:	a081                	j	80001696 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b1050513          	addi	a0,a0,-1264 # 80008168 <etext+0x168>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b2050513          	addi	a0,a0,-1248 # 80008188 <etext+0x188>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>
      kfree(mem);
    80001678:	854a                	mv	a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	3d0080e7          	jalr	976(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001682:	4685                	li	a3,1
    80001684:	00c9d613          	srli	a2,s3,0xc
    80001688:	4581                	li	a1,0
    8000168a:	8556                	mv	a0,s5
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	c32080e7          	jalr	-974(ra) # 800012be <uvmunmap>
  return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6161                	addi	sp,sp,80
    800016aa:	8082                	ret
  return 0;
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret

00000000800016b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b0:	1141                	addi	sp,sp,-16
    800016b2:	e406                	sd	ra,8(sp)
    800016b4:	e022                	sd	s0,0(sp)
    800016b6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b8:	4601                	li	a2,0
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	956080e7          	jalr	-1706(ra) # 80001010 <walk>
  if(pte == 0)
    800016c2:	c901                	beqz	a0,800016d2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c4:	611c                	ld	a5,0(a0)
    800016c6:	9bbd                	andi	a5,a5,-17
    800016c8:	e11c                	sd	a5,0(a0)
}
    800016ca:	60a2                	ld	ra,8(sp)
    800016cc:	6402                	ld	s0,0(sp)
    800016ce:	0141                	addi	sp,sp,16
    800016d0:	8082                	ret
    panic("uvmclear");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	ad650513          	addi	a0,a0,-1322 # 800081a8 <etext+0x1a8>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e86080e7          	jalr	-378(ra) # 80000560 <panic>

00000000800016e2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyout+0x6e>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	addi	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8c2e                	mv	s8,a1
    80001700:	8a32                	mv	s4,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	85d2                	mv	a1,s4
    80001712:	41250533          	sub	a0,a0,s2
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	67a080e7          	jalr	1658(ra) # 80000d90 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001722:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	982080e7          	jalr	-1662(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyout+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyout+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyout+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	addi	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176e:	caa5                	beqz	a3,800017de <copyin+0x70>
{
    80001770:	715d                	addi	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	e062                	sd	s8,0(sp)
    80001786:	0880                	addi	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8a2e                	mv	s4,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6a85                	lui	s5,0x1
    80001794:	a01d                	j	800017ba <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001796:	018505b3          	add	a1,a0,s8
    8000179a:	0004861b          	sext.w	a2,s1
    8000179e:	412585b3          	sub	a1,a1,s2
    800017a2:	8552                	mv	a0,s4
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	5ec080e7          	jalr	1516(ra) # 80000d90 <memmove>

    len -= n;
    800017ac:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b6:	02098263          	beqz	s3,800017da <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	855a                	mv	a0,s6
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	8f4080e7          	jalr	-1804(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    800017ca:	cd01                	beqz	a0,800017e2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017cc:	418904b3          	sub	s1,s2,s8
    800017d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d2:	fc99f2e3          	bgeu	s3,s1,80001796 <copyin+0x28>
    800017d6:	84ce                	mv	s1,s3
    800017d8:	bf7d                	j	80001796 <copyin+0x28>
  }
  return 0;
    800017da:	4501                	li	a0,0
    800017dc:	a021                	j	800017e4 <copyin+0x76>
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret
      return -1;
    800017e2:	557d                	li	a0,-1
}
    800017e4:	60a6                	ld	ra,72(sp)
    800017e6:	6406                	ld	s0,64(sp)
    800017e8:	74e2                	ld	s1,56(sp)
    800017ea:	7942                	ld	s2,48(sp)
    800017ec:	79a2                	ld	s3,40(sp)
    800017ee:	7a02                	ld	s4,32(sp)
    800017f0:	6ae2                	ld	s5,24(sp)
    800017f2:	6b42                	ld	s6,16(sp)
    800017f4:	6ba2                	ld	s7,8(sp)
    800017f6:	6c02                	ld	s8,0(sp)
    800017f8:	6161                	addi	sp,sp,80
    800017fa:	8082                	ret

00000000800017fc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fc:	cacd                	beqz	a3,800018ae <copyinstr+0xb2>
{
    800017fe:	715d                	addi	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	addi	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
    80001816:	8b2e                	mv	s6,a1
    80001818:	8bb2                	mv	s7,a2
    8000181a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181e:	6985                	lui	s3,0x1
    80001820:	a825                	j	80001858 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001822:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001826:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182e:	60a6                	ld	ra,72(sp)
    80001830:	6406                	ld	s0,64(sp)
    80001832:	74e2                	ld	s1,56(sp)
    80001834:	7942                	ld	s2,48(sp)
    80001836:	79a2                	ld	s3,40(sp)
    80001838:	7a02                	ld	s4,32(sp)
    8000183a:	6ae2                	ld	s5,24(sp)
    8000183c:	6b42                	ld	s6,16(sp)
    8000183e:	6ba2                	ld	s7,8(sp)
    80001840:	6161                	addi	sp,sp,80
    80001842:	8082                	ret
    80001844:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001848:	9742                	add	a4,a4,a6
      --max;
    8000184a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001852:	04e58663          	beq	a1,a4,8000189e <copyinstr+0xa2>
{
    80001856:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85a6                	mv	a1,s1
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	856080e7          	jalr	-1962(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    80001868:	cd0d                	beqz	a0,800018a2 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000186a:	417486b3          	sub	a3,s1,s7
    8000186e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001870:	00d97363          	bgeu	s2,a3,80001876 <copyinstr+0x7a>
    80001874:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000187a:	c695                	beqz	a3,800018a6 <copyinstr+0xaa>
    8000187c:	87da                	mv	a5,s6
    8000187e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001880:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001884:	96da                	add	a3,a3,s6
    80001886:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001888:	00f60733          	add	a4,a2,a5
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd67b0>
    80001890:	db49                	beqz	a4,80001822 <copyinstr+0x26>
        *dst = *p;
    80001892:	00e78023          	sb	a4,0(a5)
      dst++;
    80001896:	0785                	addi	a5,a5,1
    while(n > 0){
    80001898:	fed797e3          	bne	a5,a3,80001886 <copyinstr+0x8a>
    8000189c:	b765                	j	80001844 <copyinstr+0x48>
    8000189e:	4781                	li	a5,0
    800018a0:	b761                	j	80001828 <copyinstr+0x2c>
      return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	b769                	j	8000182e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a6:	6b85                	lui	s7,0x1
    800018a8:	9ba6                	add	s7,s7,s1
    800018aa:	87da                	mv	a5,s6
    800018ac:	b76d                	j	80001856 <copyinstr+0x5a>
  int got_null = 0;
    800018ae:	4781                	li	a5,0
  if(got_null){
    800018b0:	37fd                	addiw	a5,a5,-1
    800018b2:	0007851b          	sext.w	a0,a5
}
    800018b6:	8082                	ret

00000000800018b8 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800018b8:	7139                	addi	sp,sp,-64
    800018ba:	fc06                	sd	ra,56(sp)
    800018bc:	f822                	sd	s0,48(sp)
    800018be:	f426                	sd	s1,40(sp)
    800018c0:	f04a                	sd	s2,32(sp)
    800018c2:	ec4e                	sd	s3,24(sp)
    800018c4:	e852                	sd	s4,16(sp)
    800018c6:	e456                	sd	s5,8(sp)
    800018c8:	e05a                	sd	s6,0(sp)
    800018ca:	0080                	addi	s0,sp,64
    800018cc:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800018ce:	00012497          	auipc	s1,0x12
    800018d2:	0d248493          	addi	s1,s1,210 # 800139a0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018d6:	8b26                	mv	s6,s1
    800018d8:	4fcad937          	lui	s2,0x4fcad
    800018dc:	090a                	slli	s2,s2,0x2
    800018de:	88590913          	addi	s2,s2,-1915 # 4fcac885 <_entry-0x3035377b>
    800018e2:	0942                	slli	s2,s2,0x10
    800018e4:	cad90913          	addi	s2,s2,-851
    800018e8:	093a                	slli	s2,s2,0xe
    800018ea:	88590913          	addi	s2,s2,-1915
    800018ee:	040009b7          	lui	s3,0x4000
    800018f2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f4:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800018f6:	0001ca97          	auipc	s5,0x1c
    800018fa:	aaaa8a93          	addi	s5,s5,-1366 # 8001d3a0 <tickslock>
    char *pa = kalloc();
    800018fe:	fffff097          	auipc	ra,0xfffff
    80001902:	24a080e7          	jalr	586(ra) # 80000b48 <kalloc>
    80001906:	862a                	mv	a2,a0
    if (pa == 0)
    80001908:	c121                	beqz	a0,80001948 <proc_mapstacks+0x90>
    uint64 va = KSTACK((int)(p - proc));
    8000190a:	416485b3          	sub	a1,s1,s6
    8000190e:	858d                	srai	a1,a1,0x3
    80001910:	032585b3          	mul	a1,a1,s2
    80001914:	2585                	addiw	a1,a1,1
    80001916:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191a:	4719                	li	a4,6
    8000191c:	6685                	lui	a3,0x1
    8000191e:	40b985b3          	sub	a1,s3,a1
    80001922:	8552                	mv	a0,s4
    80001924:	00000097          	auipc	ra,0x0
    80001928:	874080e7          	jalr	-1932(ra) # 80001198 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    8000192c:	26848493          	addi	s1,s1,616
    80001930:	fd5497e3          	bne	s1,s5,800018fe <proc_mapstacks+0x46>
  }
}
    80001934:	70e2                	ld	ra,56(sp)
    80001936:	7442                	ld	s0,48(sp)
    80001938:	74a2                	ld	s1,40(sp)
    8000193a:	7902                	ld	s2,32(sp)
    8000193c:	69e2                	ld	s3,24(sp)
    8000193e:	6a42                	ld	s4,16(sp)
    80001940:	6aa2                	ld	s5,8(sp)
    80001942:	6b02                	ld	s6,0(sp)
    80001944:	6121                	addi	sp,sp,64
    80001946:	8082                	ret
      panic("kalloc");
    80001948:	00007517          	auipc	a0,0x7
    8000194c:	87050513          	addi	a0,a0,-1936 # 800081b8 <etext+0x1b8>
    80001950:	fffff097          	auipc	ra,0xfffff
    80001954:	c10080e7          	jalr	-1008(ra) # 80000560 <panic>

0000000080001958 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001958:	7139                	addi	sp,sp,-64
    8000195a:	fc06                	sd	ra,56(sp)
    8000195c:	f822                	sd	s0,48(sp)
    8000195e:	f426                	sd	s1,40(sp)
    80001960:	f04a                	sd	s2,32(sp)
    80001962:	ec4e                	sd	s3,24(sp)
    80001964:	e852                	sd	s4,16(sp)
    80001966:	e456                	sd	s5,8(sp)
    80001968:	e05a                	sd	s6,0(sp)
    8000196a:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    8000196c:	00007597          	auipc	a1,0x7
    80001970:	85458593          	addi	a1,a1,-1964 # 800081c0 <etext+0x1c0>
    80001974:	00012517          	auipc	a0,0x12
    80001978:	bfc50513          	addi	a0,a0,-1028 # 80013570 <pid_lock>
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	22c080e7          	jalr	556(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001984:	00007597          	auipc	a1,0x7
    80001988:	84458593          	addi	a1,a1,-1980 # 800081c8 <etext+0x1c8>
    8000198c:	00012517          	auipc	a0,0x12
    80001990:	bfc50513          	addi	a0,a0,-1028 # 80013588 <wait_lock>
    80001994:	fffff097          	auipc	ra,0xfffff
    80001998:	214080e7          	jalr	532(ra) # 80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000199c:	00012497          	auipc	s1,0x12
    800019a0:	00448493          	addi	s1,s1,4 # 800139a0 <proc>
  {
    initlock(&p->lock, "proc");
    800019a4:	00007b17          	auipc	s6,0x7
    800019a8:	834b0b13          	addi	s6,s6,-1996 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800019ac:	8aa6                	mv	s5,s1
    800019ae:	4fcad937          	lui	s2,0x4fcad
    800019b2:	090a                	slli	s2,s2,0x2
    800019b4:	88590913          	addi	s2,s2,-1915 # 4fcac885 <_entry-0x3035377b>
    800019b8:	0942                	slli	s2,s2,0x10
    800019ba:	cad90913          	addi	s2,s2,-851
    800019be:	093a                	slli	s2,s2,0xe
    800019c0:	88590913          	addi	s2,s2,-1915
    800019c4:	040009b7          	lui	s3,0x4000
    800019c8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019ca:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019cc:	0001ca17          	auipc	s4,0x1c
    800019d0:	9d4a0a13          	addi	s4,s4,-1580 # 8001d3a0 <tickslock>
    initlock(&p->lock, "proc");
    800019d4:	85da                	mv	a1,s6
    800019d6:	8526                	mv	a0,s1
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	1d0080e7          	jalr	464(ra) # 80000ba8 <initlock>
    p->state = UNUSED;
    800019e0:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800019e4:	415487b3          	sub	a5,s1,s5
    800019e8:	878d                	srai	a5,a5,0x3
    800019ea:	032787b3          	mul	a5,a5,s2
    800019ee:	2785                	addiw	a5,a5,1
    800019f0:	00d7979b          	slliw	a5,a5,0xd
    800019f4:	40f987b3          	sub	a5,s3,a5
    800019f8:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    800019fa:	26848493          	addi	s1,s1,616
    800019fe:	fd449be3          	bne	s1,s4,800019d4 <procinit+0x7c>
  }
}
    80001a02:	70e2                	ld	ra,56(sp)
    80001a04:	7442                	ld	s0,48(sp)
    80001a06:	74a2                	ld	s1,40(sp)
    80001a08:	7902                	ld	s2,32(sp)
    80001a0a:	69e2                	ld	s3,24(sp)
    80001a0c:	6a42                	ld	s4,16(sp)
    80001a0e:	6aa2                	ld	s5,8(sp)
    80001a10:	6b02                	ld	s6,0(sp)
    80001a12:	6121                	addi	sp,sp,64
    80001a14:	8082                	ret

0000000080001a16 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001a16:	1141                	addi	sp,sp,-16
    80001a18:	e422                	sd	s0,8(sp)
    80001a1a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a1c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a1e:	2501                	sext.w	a0,a0
    80001a20:	6422                	ld	s0,8(sp)
    80001a22:	0141                	addi	sp,sp,16
    80001a24:	8082                	ret

0000000080001a26 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001a26:	1141                	addi	sp,sp,-16
    80001a28:	e422                	sd	s0,8(sp)
    80001a2a:	0800                	addi	s0,sp,16
    80001a2c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a2e:	2781                	sext.w	a5,a5
    80001a30:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a32:	00012517          	auipc	a0,0x12
    80001a36:	b6e50513          	addi	a0,a0,-1170 # 800135a0 <cpus>
    80001a3a:	953e                	add	a0,a0,a5
    80001a3c:	6422                	ld	s0,8(sp)
    80001a3e:	0141                	addi	sp,sp,16
    80001a40:	8082                	ret

0000000080001a42 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	1000                	addi	s0,sp,32
  push_off();
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	1a0080e7          	jalr	416(ra) # 80000bec <push_off>
    80001a54:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a56:	2781                	sext.w	a5,a5
    80001a58:	079e                	slli	a5,a5,0x7
    80001a5a:	00012717          	auipc	a4,0x12
    80001a5e:	b1670713          	addi	a4,a4,-1258 # 80013570 <pid_lock>
    80001a62:	97ba                	add	a5,a5,a4
    80001a64:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	226080e7          	jalr	550(ra) # 80000c8c <pop_off>
  return p;
}
    80001a6e:	8526                	mv	a0,s1
    80001a70:	60e2                	ld	ra,24(sp)
    80001a72:	6442                	ld	s0,16(sp)
    80001a74:	64a2                	ld	s1,8(sp)
    80001a76:	6105                	addi	sp,sp,32
    80001a78:	8082                	ret

0000000080001a7a <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001a7a:	1141                	addi	sp,sp,-16
    80001a7c:	e406                	sd	ra,8(sp)
    80001a7e:	e022                	sd	s0,0(sp)
    80001a80:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a82:	00000097          	auipc	ra,0x0
    80001a86:	fc0080e7          	jalr	-64(ra) # 80001a42 <myproc>
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	262080e7          	jalr	610(ra) # 80000cec <release>

  if (first)
    80001a92:	00009797          	auipc	a5,0x9
    80001a96:	7ce7a783          	lw	a5,1998(a5) # 8000b260 <first.1>
    80001a9a:	eb89                	bnez	a5,80001aac <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a9c:	00001097          	auipc	ra,0x1
    80001aa0:	e4e080e7          	jalr	-434(ra) # 800028ea <usertrapret>
}
    80001aa4:	60a2                	ld	ra,8(sp)
    80001aa6:	6402                	ld	s0,0(sp)
    80001aa8:	0141                	addi	sp,sp,16
    80001aaa:	8082                	ret
    first = 0;
    80001aac:	00009797          	auipc	a5,0x9
    80001ab0:	7a07aa23          	sw	zero,1972(a5) # 8000b260 <first.1>
    fsinit(ROOTDEV);
    80001ab4:	4505                	li	a0,1
    80001ab6:	00002097          	auipc	ra,0x2
    80001aba:	dba080e7          	jalr	-582(ra) # 80003870 <fsinit>
    80001abe:	bff9                	j	80001a9c <forkret+0x22>

0000000080001ac0 <allocpid>:
{
    80001ac0:	1101                	addi	sp,sp,-32
    80001ac2:	ec06                	sd	ra,24(sp)
    80001ac4:	e822                	sd	s0,16(sp)
    80001ac6:	e426                	sd	s1,8(sp)
    80001ac8:	e04a                	sd	s2,0(sp)
    80001aca:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001acc:	00012917          	auipc	s2,0x12
    80001ad0:	aa490913          	addi	s2,s2,-1372 # 80013570 <pid_lock>
    80001ad4:	854a                	mv	a0,s2
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	162080e7          	jalr	354(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001ade:	00009797          	auipc	a5,0x9
    80001ae2:	78678793          	addi	a5,a5,1926 # 8000b264 <nextpid>
    80001ae6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ae8:	0014871b          	addiw	a4,s1,1
    80001aec:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aee:	854a                	mv	a0,s2
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	1fc080e7          	jalr	508(ra) # 80000cec <release>
}
    80001af8:	8526                	mv	a0,s1
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6902                	ld	s2,0(sp)
    80001b02:	6105                	addi	sp,sp,32
    80001b04:	8082                	ret

0000000080001b06 <proc_pagetable>:
{
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b14:	00000097          	auipc	ra,0x0
    80001b18:	87e080e7          	jalr	-1922(ra) # 80001392 <uvmcreate>
    80001b1c:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b1e:	c121                	beqz	a0,80001b5e <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b20:	4729                	li	a4,10
    80001b22:	00005697          	auipc	a3,0x5
    80001b26:	4de68693          	addi	a3,a3,1246 # 80007000 <_trampoline>
    80001b2a:	6605                	lui	a2,0x1
    80001b2c:	040005b7          	lui	a1,0x4000
    80001b30:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b32:	05b2                	slli	a1,a1,0xc
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	5c4080e7          	jalr	1476(ra) # 800010f8 <mappages>
    80001b3c:	02054863          	bltz	a0,80001b6c <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b40:	4719                	li	a4,6
    80001b42:	05893683          	ld	a3,88(s2)
    80001b46:	6605                	lui	a2,0x1
    80001b48:	020005b7          	lui	a1,0x2000
    80001b4c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b4e:	05b6                	slli	a1,a1,0xd
    80001b50:	8526                	mv	a0,s1
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	5a6080e7          	jalr	1446(ra) # 800010f8 <mappages>
    80001b5a:	02054163          	bltz	a0,80001b7c <proc_pagetable+0x76>
}
    80001b5e:	8526                	mv	a0,s1
    80001b60:	60e2                	ld	ra,24(sp)
    80001b62:	6442                	ld	s0,16(sp)
    80001b64:	64a2                	ld	s1,8(sp)
    80001b66:	6902                	ld	s2,0(sp)
    80001b68:	6105                	addi	sp,sp,32
    80001b6a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b6c:	4581                	li	a1,0
    80001b6e:	8526                	mv	a0,s1
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	a34080e7          	jalr	-1484(ra) # 800015a4 <uvmfree>
    return 0;
    80001b78:	4481                	li	s1,0
    80001b7a:	b7d5                	j	80001b5e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b7c:	4681                	li	a3,0
    80001b7e:	4605                	li	a2,1
    80001b80:	040005b7          	lui	a1,0x4000
    80001b84:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b86:	05b2                	slli	a1,a1,0xc
    80001b88:	8526                	mv	a0,s1
    80001b8a:	fffff097          	auipc	ra,0xfffff
    80001b8e:	734080e7          	jalr	1844(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001b92:	4581                	li	a1,0
    80001b94:	8526                	mv	a0,s1
    80001b96:	00000097          	auipc	ra,0x0
    80001b9a:	a0e080e7          	jalr	-1522(ra) # 800015a4 <uvmfree>
    return 0;
    80001b9e:	4481                	li	s1,0
    80001ba0:	bf7d                	j	80001b5e <proc_pagetable+0x58>

0000000080001ba2 <proc_freepagetable>:
{
    80001ba2:	1101                	addi	sp,sp,-32
    80001ba4:	ec06                	sd	ra,24(sp)
    80001ba6:	e822                	sd	s0,16(sp)
    80001ba8:	e426                	sd	s1,8(sp)
    80001baa:	e04a                	sd	s2,0(sp)
    80001bac:	1000                	addi	s0,sp,32
    80001bae:	84aa                	mv	s1,a0
    80001bb0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb2:	4681                	li	a3,0
    80001bb4:	4605                	li	a2,1
    80001bb6:	040005b7          	lui	a1,0x4000
    80001bba:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bbc:	05b2                	slli	a1,a1,0xc
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	700080e7          	jalr	1792(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bc6:	4681                	li	a3,0
    80001bc8:	4605                	li	a2,1
    80001bca:	020005b7          	lui	a1,0x2000
    80001bce:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bd0:	05b6                	slli	a1,a1,0xd
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	6ea080e7          	jalr	1770(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001bdc:	85ca                	mv	a1,s2
    80001bde:	8526                	mv	a0,s1
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	9c4080e7          	jalr	-1596(ra) # 800015a4 <uvmfree>
}
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret

0000000080001bf4 <freeproc>:
{
    80001bf4:	1101                	addi	sp,sp,-32
    80001bf6:	ec06                	sd	ra,24(sp)
    80001bf8:	e822                	sd	s0,16(sp)
    80001bfa:	e426                	sd	s1,8(sp)
    80001bfc:	1000                	addi	s0,sp,32
    80001bfe:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c00:	6d28                	ld	a0,88(a0)
    80001c02:	c509                	beqz	a0,80001c0c <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	e46080e7          	jalr	-442(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c0c:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c10:	68a8                	ld	a0,80(s1)
    80001c12:	c511                	beqz	a0,80001c1e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c14:	64ac                	ld	a1,72(s1)
    80001c16:	00000097          	auipc	ra,0x0
    80001c1a:	f8c080e7          	jalr	-116(ra) # 80001ba2 <proc_freepagetable>
  p->pagetable = 0;
    80001c1e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c22:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c26:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c2a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c2e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c32:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c36:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c3a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c3e:	0004ac23          	sw	zero,24(s1)
}
    80001c42:	60e2                	ld	ra,24(sp)
    80001c44:	6442                	ld	s0,16(sp)
    80001c46:	64a2                	ld	s1,8(sp)
    80001c48:	6105                	addi	sp,sp,32
    80001c4a:	8082                	ret

0000000080001c4c <allocproc>:
{
    80001c4c:	1101                	addi	sp,sp,-32
    80001c4e:	ec06                	sd	ra,24(sp)
    80001c50:	e822                	sd	s0,16(sp)
    80001c52:	e426                	sd	s1,8(sp)
    80001c54:	e04a                	sd	s2,0(sp)
    80001c56:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001c58:	00012497          	auipc	s1,0x12
    80001c5c:	d4848493          	addi	s1,s1,-696 # 800139a0 <proc>
    80001c60:	0001b917          	auipc	s2,0x1b
    80001c64:	74090913          	addi	s2,s2,1856 # 8001d3a0 <tickslock>
    acquire(&p->lock);
    80001c68:	8526                	mv	a0,s1
    80001c6a:	fffff097          	auipc	ra,0xfffff
    80001c6e:	fce080e7          	jalr	-50(ra) # 80000c38 <acquire>
    if (p->state == UNUSED)
    80001c72:	4c9c                	lw	a5,24(s1)
    80001c74:	cf81                	beqz	a5,80001c8c <allocproc+0x40>
      release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	074080e7          	jalr	116(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c80:	26848493          	addi	s1,s1,616
    80001c84:	ff2492e3          	bne	s1,s2,80001c68 <allocproc+0x1c>
  return 0;
    80001c88:	4481                	li	s1,0
    80001c8a:	a8a5                	j	80001d02 <allocproc+0xb6>
  p->pid = allocpid();
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	e34080e7          	jalr	-460(ra) # 80001ac0 <allocpid>
    80001c94:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c96:	4785                	li	a5,1
    80001c98:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	eae080e7          	jalr	-338(ra) # 80000b48 <kalloc>
    80001ca2:	892a                	mv	s2,a0
    80001ca4:	eca8                	sd	a0,88(s1)
    80001ca6:	c52d                	beqz	a0,80001d10 <allocproc+0xc4>
  p->pagetable = proc_pagetable(p);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	e5c080e7          	jalr	-420(ra) # 80001b06 <proc_pagetable>
    80001cb2:	892a                	mv	s2,a0
    80001cb4:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001cb6:	c92d                	beqz	a0,80001d28 <allocproc+0xdc>
  memset(&p->context, 0, sizeof(p->context));
    80001cb8:	07000613          	li	a2,112
    80001cbc:	4581                	li	a1,0
    80001cbe:	06048513          	addi	a0,s1,96
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	072080e7          	jalr	114(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001cca:	00000797          	auipc	a5,0x0
    80001cce:	db078793          	addi	a5,a5,-592 # 80001a7a <forkret>
    80001cd2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cd4:	60bc                	ld	a5,64(s1)
    80001cd6:	6705                	lui	a4,0x1
    80001cd8:	97ba                	add	a5,a5,a4
    80001cda:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001cdc:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001ce0:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001ce4:	00009797          	auipc	a5,0x9
    80001ce8:	61c7a783          	lw	a5,1564(a5) # 8000b300 <ticks>
    80001cec:	16f4a623          	sw	a5,364(s1)
  memset(&p->syscall_counts, 0, sizeof(p->syscall_counts));
    80001cf0:	0d000613          	li	a2,208
    80001cf4:	4581                	li	a1,0
    80001cf6:	17848513          	addi	a0,s1,376
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	03a080e7          	jalr	58(ra) # 80000d34 <memset>
}
    80001d02:	8526                	mv	a0,s1
    80001d04:	60e2                	ld	ra,24(sp)
    80001d06:	6442                	ld	s0,16(sp)
    80001d08:	64a2                	ld	s1,8(sp)
    80001d0a:	6902                	ld	s2,0(sp)
    80001d0c:	6105                	addi	sp,sp,32
    80001d0e:	8082                	ret
    freeproc(p);
    80001d10:	8526                	mv	a0,s1
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	ee2080e7          	jalr	-286(ra) # 80001bf4 <freeproc>
    release(&p->lock);
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	fd0080e7          	jalr	-48(ra) # 80000cec <release>
    return 0;
    80001d24:	84ca                	mv	s1,s2
    80001d26:	bff1                	j	80001d02 <allocproc+0xb6>
    freeproc(p);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	00000097          	auipc	ra,0x0
    80001d2e:	eca080e7          	jalr	-310(ra) # 80001bf4 <freeproc>
    release(&p->lock);
    80001d32:	8526                	mv	a0,s1
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	fb8080e7          	jalr	-72(ra) # 80000cec <release>
    return 0;
    80001d3c:	84ca                	mv	s1,s2
    80001d3e:	b7d1                	j	80001d02 <allocproc+0xb6>

0000000080001d40 <userinit>:
{
    80001d40:	1101                	addi	sp,sp,-32
    80001d42:	ec06                	sd	ra,24(sp)
    80001d44:	e822                	sd	s0,16(sp)
    80001d46:	e426                	sd	s1,8(sp)
    80001d48:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d4a:	00000097          	auipc	ra,0x0
    80001d4e:	f02080e7          	jalr	-254(ra) # 80001c4c <allocproc>
    80001d52:	84aa                	mv	s1,a0
  initproc = p;
    80001d54:	00009797          	auipc	a5,0x9
    80001d58:	5aa7b223          	sd	a0,1444(a5) # 8000b2f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d5c:	03400613          	li	a2,52
    80001d60:	00009597          	auipc	a1,0x9
    80001d64:	51058593          	addi	a1,a1,1296 # 8000b270 <initcode>
    80001d68:	6928                	ld	a0,80(a0)
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	656080e7          	jalr	1622(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001d72:	6785                	lui	a5,0x1
    80001d74:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d76:	6cb8                	ld	a4,88(s1)
    80001d78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d7c:	6cb8                	ld	a4,88(s1)
    80001d7e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d80:	4641                	li	a2,16
    80001d82:	00006597          	auipc	a1,0x6
    80001d86:	45e58593          	addi	a1,a1,1118 # 800081e0 <etext+0x1e0>
    80001d8a:	15848513          	addi	a0,s1,344
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	0e8080e7          	jalr	232(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001d96:	00006517          	auipc	a0,0x6
    80001d9a:	45a50513          	addi	a0,a0,1114 # 800081f0 <etext+0x1f0>
    80001d9e:	00002097          	auipc	ra,0x2
    80001da2:	524080e7          	jalr	1316(ra) # 800042c2 <namei>
    80001da6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001daa:	478d                	li	a5,3
    80001dac:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dae:	8526                	mv	a0,s1
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	f3c080e7          	jalr	-196(ra) # 80000cec <release>
}
    80001db8:	60e2                	ld	ra,24(sp)
    80001dba:	6442                	ld	s0,16(sp)
    80001dbc:	64a2                	ld	s1,8(sp)
    80001dbe:	6105                	addi	sp,sp,32
    80001dc0:	8082                	ret

0000000080001dc2 <growproc>:
{
    80001dc2:	1101                	addi	sp,sp,-32
    80001dc4:	ec06                	sd	ra,24(sp)
    80001dc6:	e822                	sd	s0,16(sp)
    80001dc8:	e426                	sd	s1,8(sp)
    80001dca:	e04a                	sd	s2,0(sp)
    80001dcc:	1000                	addi	s0,sp,32
    80001dce:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001dd0:	00000097          	auipc	ra,0x0
    80001dd4:	c72080e7          	jalr	-910(ra) # 80001a42 <myproc>
    80001dd8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dda:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001ddc:	01204c63          	bgtz	s2,80001df4 <growproc+0x32>
  else if (n < 0)
    80001de0:	02094663          	bltz	s2,80001e0c <growproc+0x4a>
  p->sz = sz;
    80001de4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001de6:	4501                	li	a0,0
}
    80001de8:	60e2                	ld	ra,24(sp)
    80001dea:	6442                	ld	s0,16(sp)
    80001dec:	64a2                	ld	s1,8(sp)
    80001dee:	6902                	ld	s2,0(sp)
    80001df0:	6105                	addi	sp,sp,32
    80001df2:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001df4:	4691                	li	a3,4
    80001df6:	00b90633          	add	a2,s2,a1
    80001dfa:	6928                	ld	a0,80(a0)
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	67e080e7          	jalr	1662(ra) # 8000147a <uvmalloc>
    80001e04:	85aa                	mv	a1,a0
    80001e06:	fd79                	bnez	a0,80001de4 <growproc+0x22>
      return -1;
    80001e08:	557d                	li	a0,-1
    80001e0a:	bff9                	j	80001de8 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e0c:	00b90633          	add	a2,s2,a1
    80001e10:	6928                	ld	a0,80(a0)
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	620080e7          	jalr	1568(ra) # 80001432 <uvmdealloc>
    80001e1a:	85aa                	mv	a1,a0
    80001e1c:	b7e1                	j	80001de4 <growproc+0x22>

0000000080001e1e <fork>:
{
    80001e1e:	7139                	addi	sp,sp,-64
    80001e20:	fc06                	sd	ra,56(sp)
    80001e22:	f822                	sd	s0,48(sp)
    80001e24:	f04a                	sd	s2,32(sp)
    80001e26:	e456                	sd	s5,8(sp)
    80001e28:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e2a:	00000097          	auipc	ra,0x0
    80001e2e:	c18080e7          	jalr	-1000(ra) # 80001a42 <myproc>
    80001e32:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001e34:	00000097          	auipc	ra,0x0
    80001e38:	e18080e7          	jalr	-488(ra) # 80001c4c <allocproc>
    80001e3c:	12050a63          	beqz	a0,80001f70 <fork+0x152>
    80001e40:	ec4e                	sd	s3,24(sp)
    80001e42:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e44:	048ab603          	ld	a2,72(s5)
    80001e48:	692c                	ld	a1,80(a0)
    80001e4a:	050ab503          	ld	a0,80(s5)
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	790080e7          	jalr	1936(ra) # 800015de <uvmcopy>
    80001e56:	04054a63          	bltz	a0,80001eaa <fork+0x8c>
    80001e5a:	f426                	sd	s1,40(sp)
    80001e5c:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001e5e:	048ab783          	ld	a5,72(s5)
    80001e62:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e66:	058ab683          	ld	a3,88(s5)
    80001e6a:	87b6                	mv	a5,a3
    80001e6c:	0589b703          	ld	a4,88(s3)
    80001e70:	12068693          	addi	a3,a3,288
    80001e74:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e78:	6788                	ld	a0,8(a5)
    80001e7a:	6b8c                	ld	a1,16(a5)
    80001e7c:	6f90                	ld	a2,24(a5)
    80001e7e:	01073023          	sd	a6,0(a4)
    80001e82:	e708                	sd	a0,8(a4)
    80001e84:	eb0c                	sd	a1,16(a4)
    80001e86:	ef10                	sd	a2,24(a4)
    80001e88:	02078793          	addi	a5,a5,32
    80001e8c:	02070713          	addi	a4,a4,32
    80001e90:	fed792e3          	bne	a5,a3,80001e74 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e94:	0589b783          	ld	a5,88(s3)
    80001e98:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e9c:	0d0a8493          	addi	s1,s5,208
    80001ea0:	0d098913          	addi	s2,s3,208
    80001ea4:	150a8a13          	addi	s4,s5,336
    80001ea8:	a015                	j	80001ecc <fork+0xae>
    freeproc(np);
    80001eaa:	854e                	mv	a0,s3
    80001eac:	00000097          	auipc	ra,0x0
    80001eb0:	d48080e7          	jalr	-696(ra) # 80001bf4 <freeproc>
    release(&np->lock);
    80001eb4:	854e                	mv	a0,s3
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	e36080e7          	jalr	-458(ra) # 80000cec <release>
    return -1;
    80001ebe:	597d                	li	s2,-1
    80001ec0:	69e2                	ld	s3,24(sp)
    80001ec2:	a045                	j	80001f62 <fork+0x144>
  for (i = 0; i < NOFILE; i++)
    80001ec4:	04a1                	addi	s1,s1,8
    80001ec6:	0921                	addi	s2,s2,8
    80001ec8:	01448b63          	beq	s1,s4,80001ede <fork+0xc0>
    if (p->ofile[i])
    80001ecc:	6088                	ld	a0,0(s1)
    80001ece:	d97d                	beqz	a0,80001ec4 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ed0:	00003097          	auipc	ra,0x3
    80001ed4:	a6a080e7          	jalr	-1430(ra) # 8000493a <filedup>
    80001ed8:	00a93023          	sd	a0,0(s2)
    80001edc:	b7e5                	j	80001ec4 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ede:	150ab503          	ld	a0,336(s5)
    80001ee2:	00002097          	auipc	ra,0x2
    80001ee6:	bd4080e7          	jalr	-1068(ra) # 80003ab6 <idup>
    80001eea:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eee:	4641                	li	a2,16
    80001ef0:	158a8593          	addi	a1,s5,344
    80001ef4:	15898513          	addi	a0,s3,344
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	f7e080e7          	jalr	-130(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001f00:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f04:	854e                	mv	a0,s3
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	de6080e7          	jalr	-538(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001f0e:	00011497          	auipc	s1,0x11
    80001f12:	67a48493          	addi	s1,s1,1658 # 80013588 <wait_lock>
    80001f16:	8526                	mv	a0,s1
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	d20080e7          	jalr	-736(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f20:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	dc6080e7          	jalr	-570(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f2e:	854e                	mv	a0,s3
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	d08080e7          	jalr	-760(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001f38:	478d                	li	a5,3
    80001f3a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f3e:	854e                	mv	a0,s3
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	dac080e7          	jalr	-596(ra) # 80000cec <release>
  memmove(&np->syscall_counts, &p->syscall_counts, sizeof(p->syscall_counts));
    80001f48:	0d000613          	li	a2,208
    80001f4c:	178a8593          	addi	a1,s5,376
    80001f50:	17898513          	addi	a0,s3,376
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	e3c080e7          	jalr	-452(ra) # 80000d90 <memmove>
  return pid;
    80001f5c:	74a2                	ld	s1,40(sp)
    80001f5e:	69e2                	ld	s3,24(sp)
    80001f60:	6a42                	ld	s4,16(sp)
}
    80001f62:	854a                	mv	a0,s2
    80001f64:	70e2                	ld	ra,56(sp)
    80001f66:	7442                	ld	s0,48(sp)
    80001f68:	7902                	ld	s2,32(sp)
    80001f6a:	6aa2                	ld	s5,8(sp)
    80001f6c:	6121                	addi	sp,sp,64
    80001f6e:	8082                	ret
    return -1;
    80001f70:	597d                	li	s2,-1
    80001f72:	bfc5                	j	80001f62 <fork+0x144>

0000000080001f74 <scheduler>:
{
    80001f74:	7139                	addi	sp,sp,-64
    80001f76:	fc06                	sd	ra,56(sp)
    80001f78:	f822                	sd	s0,48(sp)
    80001f7a:	f426                	sd	s1,40(sp)
    80001f7c:	f04a                	sd	s2,32(sp)
    80001f7e:	ec4e                	sd	s3,24(sp)
    80001f80:	e852                	sd	s4,16(sp)
    80001f82:	e456                	sd	s5,8(sp)
    80001f84:	e05a                	sd	s6,0(sp)
    80001f86:	0080                	addi	s0,sp,64
    80001f88:	8792                	mv	a5,tp
  int id = r_tp();
    80001f8a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f8c:	00779a93          	slli	s5,a5,0x7
    80001f90:	00011717          	auipc	a4,0x11
    80001f94:	5e070713          	addi	a4,a4,1504 # 80013570 <pid_lock>
    80001f98:	9756                	add	a4,a4,s5
    80001f9a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f9e:	00011717          	auipc	a4,0x11
    80001fa2:	60a70713          	addi	a4,a4,1546 # 800135a8 <cpus+0x8>
    80001fa6:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001fa8:	498d                	li	s3,3
        p->state = RUNNING;
    80001faa:	4b11                	li	s6,4
        c->proc = p;
    80001fac:	079e                	slli	a5,a5,0x7
    80001fae:	00011a17          	auipc	s4,0x11
    80001fb2:	5c2a0a13          	addi	s4,s4,1474 # 80013570 <pid_lock>
    80001fb6:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001fb8:	0001b917          	auipc	s2,0x1b
    80001fbc:	3e890913          	addi	s2,s2,1000 # 8001d3a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fc4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fc8:	10079073          	csrw	sstatus,a5
    80001fcc:	00012497          	auipc	s1,0x12
    80001fd0:	9d448493          	addi	s1,s1,-1580 # 800139a0 <proc>
    80001fd4:	a811                	j	80001fe8 <scheduler+0x74>
      release(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	d14080e7          	jalr	-748(ra) # 80000cec <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001fe0:	26848493          	addi	s1,s1,616
    80001fe4:	fd248ee3          	beq	s1,s2,80001fc0 <scheduler+0x4c>
      acquire(&p->lock);
    80001fe8:	8526                	mv	a0,s1
    80001fea:	fffff097          	auipc	ra,0xfffff
    80001fee:	c4e080e7          	jalr	-946(ra) # 80000c38 <acquire>
      if (p->state == RUNNABLE)
    80001ff2:	4c9c                	lw	a5,24(s1)
    80001ff4:	ff3791e3          	bne	a5,s3,80001fd6 <scheduler+0x62>
        p->state = RUNNING;
    80001ff8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001ffc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002000:	06048593          	addi	a1,s1,96
    80002004:	8556                	mv	a0,s5
    80002006:	00001097          	auipc	ra,0x1
    8000200a:	83a080e7          	jalr	-1990(ra) # 80002840 <swtch>
        c->proc = 0;
    8000200e:	020a3823          	sd	zero,48(s4)
    80002012:	b7d1                	j	80001fd6 <scheduler+0x62>

0000000080002014 <sched>:
{
    80002014:	7179                	addi	sp,sp,-48
    80002016:	f406                	sd	ra,40(sp)
    80002018:	f022                	sd	s0,32(sp)
    8000201a:	ec26                	sd	s1,24(sp)
    8000201c:	e84a                	sd	s2,16(sp)
    8000201e:	e44e                	sd	s3,8(sp)
    80002020:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002022:	00000097          	auipc	ra,0x0
    80002026:	a20080e7          	jalr	-1504(ra) # 80001a42 <myproc>
    8000202a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	b92080e7          	jalr	-1134(ra) # 80000bbe <holding>
    80002034:	c93d                	beqz	a0,800020aa <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002036:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002038:	2781                	sext.w	a5,a5
    8000203a:	079e                	slli	a5,a5,0x7
    8000203c:	00011717          	auipc	a4,0x11
    80002040:	53470713          	addi	a4,a4,1332 # 80013570 <pid_lock>
    80002044:	97ba                	add	a5,a5,a4
    80002046:	0a87a703          	lw	a4,168(a5)
    8000204a:	4785                	li	a5,1
    8000204c:	06f71763          	bne	a4,a5,800020ba <sched+0xa6>
  if (p->state == RUNNING)
    80002050:	4c98                	lw	a4,24(s1)
    80002052:	4791                	li	a5,4
    80002054:	06f70b63          	beq	a4,a5,800020ca <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002058:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000205c:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000205e:	efb5                	bnez	a5,800020da <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002060:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002062:	00011917          	auipc	s2,0x11
    80002066:	50e90913          	addi	s2,s2,1294 # 80013570 <pid_lock>
    8000206a:	2781                	sext.w	a5,a5
    8000206c:	079e                	slli	a5,a5,0x7
    8000206e:	97ca                	add	a5,a5,s2
    80002070:	0ac7a983          	lw	s3,172(a5)
    80002074:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002076:	2781                	sext.w	a5,a5
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	00011597          	auipc	a1,0x11
    8000207e:	52e58593          	addi	a1,a1,1326 # 800135a8 <cpus+0x8>
    80002082:	95be                	add	a1,a1,a5
    80002084:	06048513          	addi	a0,s1,96
    80002088:	00000097          	auipc	ra,0x0
    8000208c:	7b8080e7          	jalr	1976(ra) # 80002840 <swtch>
    80002090:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002092:	2781                	sext.w	a5,a5
    80002094:	079e                	slli	a5,a5,0x7
    80002096:	993e                	add	s2,s2,a5
    80002098:	0b392623          	sw	s3,172(s2)
}
    8000209c:	70a2                	ld	ra,40(sp)
    8000209e:	7402                	ld	s0,32(sp)
    800020a0:	64e2                	ld	s1,24(sp)
    800020a2:	6942                	ld	s2,16(sp)
    800020a4:	69a2                	ld	s3,8(sp)
    800020a6:	6145                	addi	sp,sp,48
    800020a8:	8082                	ret
    panic("sched p->lock");
    800020aa:	00006517          	auipc	a0,0x6
    800020ae:	14e50513          	addi	a0,a0,334 # 800081f8 <etext+0x1f8>
    800020b2:	ffffe097          	auipc	ra,0xffffe
    800020b6:	4ae080e7          	jalr	1198(ra) # 80000560 <panic>
    panic("sched locks");
    800020ba:	00006517          	auipc	a0,0x6
    800020be:	14e50513          	addi	a0,a0,334 # 80008208 <etext+0x208>
    800020c2:	ffffe097          	auipc	ra,0xffffe
    800020c6:	49e080e7          	jalr	1182(ra) # 80000560 <panic>
    panic("sched running");
    800020ca:	00006517          	auipc	a0,0x6
    800020ce:	14e50513          	addi	a0,a0,334 # 80008218 <etext+0x218>
    800020d2:	ffffe097          	auipc	ra,0xffffe
    800020d6:	48e080e7          	jalr	1166(ra) # 80000560 <panic>
    panic("sched interruptible");
    800020da:	00006517          	auipc	a0,0x6
    800020de:	14e50513          	addi	a0,a0,334 # 80008228 <etext+0x228>
    800020e2:	ffffe097          	auipc	ra,0xffffe
    800020e6:	47e080e7          	jalr	1150(ra) # 80000560 <panic>

00000000800020ea <yield>:
{
    800020ea:	1101                	addi	sp,sp,-32
    800020ec:	ec06                	sd	ra,24(sp)
    800020ee:	e822                	sd	s0,16(sp)
    800020f0:	e426                	sd	s1,8(sp)
    800020f2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	94e080e7          	jalr	-1714(ra) # 80001a42 <myproc>
    800020fc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020fe:	fffff097          	auipc	ra,0xfffff
    80002102:	b3a080e7          	jalr	-1222(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    80002106:	478d                	li	a5,3
    80002108:	cc9c                	sw	a5,24(s1)
  sched();
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	f0a080e7          	jalr	-246(ra) # 80002014 <sched>
  release(&p->lock);
    80002112:	8526                	mv	a0,s1
    80002114:	fffff097          	auipc	ra,0xfffff
    80002118:	bd8080e7          	jalr	-1064(ra) # 80000cec <release>
}
    8000211c:	60e2                	ld	ra,24(sp)
    8000211e:	6442                	ld	s0,16(sp)
    80002120:	64a2                	ld	s1,8(sp)
    80002122:	6105                	addi	sp,sp,32
    80002124:	8082                	ret

0000000080002126 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002126:	7179                	addi	sp,sp,-48
    80002128:	f406                	sd	ra,40(sp)
    8000212a:	f022                	sd	s0,32(sp)
    8000212c:	ec26                	sd	s1,24(sp)
    8000212e:	e84a                	sd	s2,16(sp)
    80002130:	e44e                	sd	s3,8(sp)
    80002132:	1800                	addi	s0,sp,48
    80002134:	89aa                	mv	s3,a0
    80002136:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002138:	00000097          	auipc	ra,0x0
    8000213c:	90a080e7          	jalr	-1782(ra) # 80001a42 <myproc>
    80002140:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	af6080e7          	jalr	-1290(ra) # 80000c38 <acquire>
  release(lk);
    8000214a:	854a                	mv	a0,s2
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	ba0080e7          	jalr	-1120(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    80002154:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002158:	4789                	li	a5,2
    8000215a:	cc9c                	sw	a5,24(s1)

  sched();
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	eb8080e7          	jalr	-328(ra) # 80002014 <sched>

  // Tidy up.
  p->chan = 0;
    80002164:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	b82080e7          	jalr	-1150(ra) # 80000cec <release>
  acquire(lk);
    80002172:	854a                	mv	a0,s2
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	ac4080e7          	jalr	-1340(ra) # 80000c38 <acquire>
}
    8000217c:	70a2                	ld	ra,40(sp)
    8000217e:	7402                	ld	s0,32(sp)
    80002180:	64e2                	ld	s1,24(sp)
    80002182:	6942                	ld	s2,16(sp)
    80002184:	69a2                	ld	s3,8(sp)
    80002186:	6145                	addi	sp,sp,48
    80002188:	8082                	ret

000000008000218a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000218a:	7139                	addi	sp,sp,-64
    8000218c:	fc06                	sd	ra,56(sp)
    8000218e:	f822                	sd	s0,48(sp)
    80002190:	f426                	sd	s1,40(sp)
    80002192:	f04a                	sd	s2,32(sp)
    80002194:	ec4e                	sd	s3,24(sp)
    80002196:	e852                	sd	s4,16(sp)
    80002198:	e456                	sd	s5,8(sp)
    8000219a:	0080                	addi	s0,sp,64
    8000219c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000219e:	00012497          	auipc	s1,0x12
    800021a2:	80248493          	addi	s1,s1,-2046 # 800139a0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800021a6:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800021a8:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800021aa:	0001b917          	auipc	s2,0x1b
    800021ae:	1f690913          	addi	s2,s2,502 # 8001d3a0 <tickslock>
    800021b2:	a811                	j	800021c6 <wakeup+0x3c>
      }
      release(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	b36080e7          	jalr	-1226(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800021be:	26848493          	addi	s1,s1,616
    800021c2:	03248663          	beq	s1,s2,800021ee <wakeup+0x64>
    if (p != myproc())
    800021c6:	00000097          	auipc	ra,0x0
    800021ca:	87c080e7          	jalr	-1924(ra) # 80001a42 <myproc>
    800021ce:	fea488e3          	beq	s1,a0,800021be <wakeup+0x34>
      acquire(&p->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	a64080e7          	jalr	-1436(ra) # 80000c38 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800021dc:	4c9c                	lw	a5,24(s1)
    800021de:	fd379be3          	bne	a5,s3,800021b4 <wakeup+0x2a>
    800021e2:	709c                	ld	a5,32(s1)
    800021e4:	fd4798e3          	bne	a5,s4,800021b4 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021e8:	0154ac23          	sw	s5,24(s1)
    800021ec:	b7e1                	j	800021b4 <wakeup+0x2a>
    }
  }
}
    800021ee:	70e2                	ld	ra,56(sp)
    800021f0:	7442                	ld	s0,48(sp)
    800021f2:	74a2                	ld	s1,40(sp)
    800021f4:	7902                	ld	s2,32(sp)
    800021f6:	69e2                	ld	s3,24(sp)
    800021f8:	6a42                	ld	s4,16(sp)
    800021fa:	6aa2                	ld	s5,8(sp)
    800021fc:	6121                	addi	sp,sp,64
    800021fe:	8082                	ret

0000000080002200 <reparent>:
{
    80002200:	7179                	addi	sp,sp,-48
    80002202:	f406                	sd	ra,40(sp)
    80002204:	f022                	sd	s0,32(sp)
    80002206:	ec26                	sd	s1,24(sp)
    80002208:	e84a                	sd	s2,16(sp)
    8000220a:	e44e                	sd	s3,8(sp)
    8000220c:	e052                	sd	s4,0(sp)
    8000220e:	1800                	addi	s0,sp,48
    80002210:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002212:	00011497          	auipc	s1,0x11
    80002216:	78e48493          	addi	s1,s1,1934 # 800139a0 <proc>
      pp->parent = initproc;
    8000221a:	00009a17          	auipc	s4,0x9
    8000221e:	0dea0a13          	addi	s4,s4,222 # 8000b2f8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002222:	0001b997          	auipc	s3,0x1b
    80002226:	17e98993          	addi	s3,s3,382 # 8001d3a0 <tickslock>
    8000222a:	a029                	j	80002234 <reparent+0x34>
    8000222c:	26848493          	addi	s1,s1,616
    80002230:	01348d63          	beq	s1,s3,8000224a <reparent+0x4a>
    if (pp->parent == p)
    80002234:	7c9c                	ld	a5,56(s1)
    80002236:	ff279be3          	bne	a5,s2,8000222c <reparent+0x2c>
      pp->parent = initproc;
    8000223a:	000a3503          	ld	a0,0(s4)
    8000223e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002240:	00000097          	auipc	ra,0x0
    80002244:	f4a080e7          	jalr	-182(ra) # 8000218a <wakeup>
    80002248:	b7d5                	j	8000222c <reparent+0x2c>
}
    8000224a:	70a2                	ld	ra,40(sp)
    8000224c:	7402                	ld	s0,32(sp)
    8000224e:	64e2                	ld	s1,24(sp)
    80002250:	6942                	ld	s2,16(sp)
    80002252:	69a2                	ld	s3,8(sp)
    80002254:	6a02                	ld	s4,0(sp)
    80002256:	6145                	addi	sp,sp,48
    80002258:	8082                	ret

000000008000225a <exit>:
{
    8000225a:	7179                	addi	sp,sp,-48
    8000225c:	f406                	sd	ra,40(sp)
    8000225e:	f022                	sd	s0,32(sp)
    80002260:	ec26                	sd	s1,24(sp)
    80002262:	e84a                	sd	s2,16(sp)
    80002264:	e44e                	sd	s3,8(sp)
    80002266:	e052                	sd	s4,0(sp)
    80002268:	1800                	addi	s0,sp,48
    8000226a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	7d6080e7          	jalr	2006(ra) # 80001a42 <myproc>
    80002274:	89aa                	mv	s3,a0
  if (p == initproc)
    80002276:	00009797          	auipc	a5,0x9
    8000227a:	0827b783          	ld	a5,130(a5) # 8000b2f8 <initproc>
    8000227e:	0d050493          	addi	s1,a0,208
    80002282:	15050913          	addi	s2,a0,336
    80002286:	02a79363          	bne	a5,a0,800022ac <exit+0x52>
    panic("init exiting");
    8000228a:	00006517          	auipc	a0,0x6
    8000228e:	fb650513          	addi	a0,a0,-74 # 80008240 <etext+0x240>
    80002292:	ffffe097          	auipc	ra,0xffffe
    80002296:	2ce080e7          	jalr	718(ra) # 80000560 <panic>
      fileclose(f);
    8000229a:	00002097          	auipc	ra,0x2
    8000229e:	6f2080e7          	jalr	1778(ra) # 8000498c <fileclose>
      p->ofile[fd] = 0;
    800022a2:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800022a6:	04a1                	addi	s1,s1,8
    800022a8:	01248563          	beq	s1,s2,800022b2 <exit+0x58>
    if (p->ofile[fd])
    800022ac:	6088                	ld	a0,0(s1)
    800022ae:	f575                	bnez	a0,8000229a <exit+0x40>
    800022b0:	bfdd                	j	800022a6 <exit+0x4c>
  begin_op();
    800022b2:	00002097          	auipc	ra,0x2
    800022b6:	210080e7          	jalr	528(ra) # 800044c2 <begin_op>
  iput(p->cwd);
    800022ba:	1509b503          	ld	a0,336(s3)
    800022be:	00002097          	auipc	ra,0x2
    800022c2:	9f4080e7          	jalr	-1548(ra) # 80003cb2 <iput>
  end_op();
    800022c6:	00002097          	auipc	ra,0x2
    800022ca:	276080e7          	jalr	630(ra) # 8000453c <end_op>
  p->cwd = 0;
    800022ce:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022d2:	00011497          	auipc	s1,0x11
    800022d6:	2b648493          	addi	s1,s1,694 # 80013588 <wait_lock>
    800022da:	8526                	mv	a0,s1
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	95c080e7          	jalr	-1700(ra) # 80000c38 <acquire>
  reparent(p);
    800022e4:	854e                	mv	a0,s3
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	f1a080e7          	jalr	-230(ra) # 80002200 <reparent>
  wakeup(p->parent);
    800022ee:	0389b503          	ld	a0,56(s3)
    800022f2:	00000097          	auipc	ra,0x0
    800022f6:	e98080e7          	jalr	-360(ra) # 8000218a <wakeup>
  acquire(&p->lock);
    800022fa:	854e                	mv	a0,s3
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	93c080e7          	jalr	-1732(ra) # 80000c38 <acquire>
  p->xstate = status;
    80002304:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002308:	4795                	li	a5,5
    8000230a:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000230e:	00009797          	auipc	a5,0x9
    80002312:	ff27a783          	lw	a5,-14(a5) # 8000b300 <ticks>
    80002316:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	9d0080e7          	jalr	-1584(ra) # 80000cec <release>
  sched();
    80002324:	00000097          	auipc	ra,0x0
    80002328:	cf0080e7          	jalr	-784(ra) # 80002014 <sched>
  panic("zombie exit");
    8000232c:	00006517          	auipc	a0,0x6
    80002330:	f2450513          	addi	a0,a0,-220 # 80008250 <etext+0x250>
    80002334:	ffffe097          	auipc	ra,0xffffe
    80002338:	22c080e7          	jalr	556(ra) # 80000560 <panic>

000000008000233c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000233c:	7179                	addi	sp,sp,-48
    8000233e:	f406                	sd	ra,40(sp)
    80002340:	f022                	sd	s0,32(sp)
    80002342:	ec26                	sd	s1,24(sp)
    80002344:	e84a                	sd	s2,16(sp)
    80002346:	e44e                	sd	s3,8(sp)
    80002348:	1800                	addi	s0,sp,48
    8000234a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000234c:	00011497          	auipc	s1,0x11
    80002350:	65448493          	addi	s1,s1,1620 # 800139a0 <proc>
    80002354:	0001b997          	auipc	s3,0x1b
    80002358:	04c98993          	addi	s3,s3,76 # 8001d3a0 <tickslock>
  {
    acquire(&p->lock);
    8000235c:	8526                	mv	a0,s1
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	8da080e7          	jalr	-1830(ra) # 80000c38 <acquire>
    if (p->pid == pid)
    80002366:	589c                	lw	a5,48(s1)
    80002368:	01278d63          	beq	a5,s2,80002382 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000236c:	8526                	mv	a0,s1
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	97e080e7          	jalr	-1666(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002376:	26848493          	addi	s1,s1,616
    8000237a:	ff3491e3          	bne	s1,s3,8000235c <kill+0x20>
  }
  return -1;
    8000237e:	557d                	li	a0,-1
    80002380:	a829                	j	8000239a <kill+0x5e>
      p->killed = 1;
    80002382:	4785                	li	a5,1
    80002384:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002386:	4c98                	lw	a4,24(s1)
    80002388:	4789                	li	a5,2
    8000238a:	00f70f63          	beq	a4,a5,800023a8 <kill+0x6c>
      release(&p->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	95c080e7          	jalr	-1700(ra) # 80000cec <release>
      return 0;
    80002398:	4501                	li	a0,0
}
    8000239a:	70a2                	ld	ra,40(sp)
    8000239c:	7402                	ld	s0,32(sp)
    8000239e:	64e2                	ld	s1,24(sp)
    800023a0:	6942                	ld	s2,16(sp)
    800023a2:	69a2                	ld	s3,8(sp)
    800023a4:	6145                	addi	sp,sp,48
    800023a6:	8082                	ret
        p->state = RUNNABLE;
    800023a8:	478d                	li	a5,3
    800023aa:	cc9c                	sw	a5,24(s1)
    800023ac:	b7cd                	j	8000238e <kill+0x52>

00000000800023ae <setkilled>:

void setkilled(struct proc *p)
{
    800023ae:	1101                	addi	sp,sp,-32
    800023b0:	ec06                	sd	ra,24(sp)
    800023b2:	e822                	sd	s0,16(sp)
    800023b4:	e426                	sd	s1,8(sp)
    800023b6:	1000                	addi	s0,sp,32
    800023b8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	87e080e7          	jalr	-1922(ra) # 80000c38 <acquire>
  p->killed = 1;
    800023c2:	4785                	li	a5,1
    800023c4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023c6:	8526                	mv	a0,s1
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	924080e7          	jalr	-1756(ra) # 80000cec <release>
}
    800023d0:	60e2                	ld	ra,24(sp)
    800023d2:	6442                	ld	s0,16(sp)
    800023d4:	64a2                	ld	s1,8(sp)
    800023d6:	6105                	addi	sp,sp,32
    800023d8:	8082                	ret

00000000800023da <killed>:

int killed(struct proc *p)
{
    800023da:	1101                	addi	sp,sp,-32
    800023dc:	ec06                	sd	ra,24(sp)
    800023de:	e822                	sd	s0,16(sp)
    800023e0:	e426                	sd	s1,8(sp)
    800023e2:	e04a                	sd	s2,0(sp)
    800023e4:	1000                	addi	s0,sp,32
    800023e6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	850080e7          	jalr	-1968(ra) # 80000c38 <acquire>
  k = p->killed;
    800023f0:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023f4:	8526                	mv	a0,s1
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	8f6080e7          	jalr	-1802(ra) # 80000cec <release>
  return k;
}
    800023fe:	854a                	mv	a0,s2
    80002400:	60e2                	ld	ra,24(sp)
    80002402:	6442                	ld	s0,16(sp)
    80002404:	64a2                	ld	s1,8(sp)
    80002406:	6902                	ld	s2,0(sp)
    80002408:	6105                	addi	sp,sp,32
    8000240a:	8082                	ret

000000008000240c <wait>:
{
    8000240c:	715d                	addi	sp,sp,-80
    8000240e:	e486                	sd	ra,72(sp)
    80002410:	e0a2                	sd	s0,64(sp)
    80002412:	fc26                	sd	s1,56(sp)
    80002414:	f84a                	sd	s2,48(sp)
    80002416:	f44e                	sd	s3,40(sp)
    80002418:	f052                	sd	s4,32(sp)
    8000241a:	ec56                	sd	s5,24(sp)
    8000241c:	e85a                	sd	s6,16(sp)
    8000241e:	e45e                	sd	s7,8(sp)
    80002420:	e062                	sd	s8,0(sp)
    80002422:	0880                	addi	s0,sp,80
    80002424:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	61c080e7          	jalr	1564(ra) # 80001a42 <myproc>
    8000242e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002430:	00011517          	auipc	a0,0x11
    80002434:	15850513          	addi	a0,a0,344 # 80013588 <wait_lock>
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	800080e7          	jalr	-2048(ra) # 80000c38 <acquire>
    havekids = 0;
    80002440:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002442:	4a15                	li	s4,5
        havekids = 1;
    80002444:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002446:	0001b997          	auipc	s3,0x1b
    8000244a:	f5a98993          	addi	s3,s3,-166 # 8001d3a0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000244e:	00011c17          	auipc	s8,0x11
    80002452:	13ac0c13          	addi	s8,s8,314 # 80013588 <wait_lock>
    80002456:	a0d1                	j	8000251a <wait+0x10e>
          pid = pp->pid;
    80002458:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000245c:	000b0e63          	beqz	s6,80002478 <wait+0x6c>
    80002460:	4691                	li	a3,4
    80002462:	02c48613          	addi	a2,s1,44
    80002466:	85da                	mv	a1,s6
    80002468:	05093503          	ld	a0,80(s2)
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	276080e7          	jalr	630(ra) # 800016e2 <copyout>
    80002474:	04054163          	bltz	a0,800024b6 <wait+0xaa>
          freeproc(pp);
    80002478:	8526                	mv	a0,s1
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	77a080e7          	jalr	1914(ra) # 80001bf4 <freeproc>
          release(&pp->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	868080e7          	jalr	-1944(ra) # 80000cec <release>
          release(&wait_lock);
    8000248c:	00011517          	auipc	a0,0x11
    80002490:	0fc50513          	addi	a0,a0,252 # 80013588 <wait_lock>
    80002494:	fffff097          	auipc	ra,0xfffff
    80002498:	858080e7          	jalr	-1960(ra) # 80000cec <release>
}
    8000249c:	854e                	mv	a0,s3
    8000249e:	60a6                	ld	ra,72(sp)
    800024a0:	6406                	ld	s0,64(sp)
    800024a2:	74e2                	ld	s1,56(sp)
    800024a4:	7942                	ld	s2,48(sp)
    800024a6:	79a2                	ld	s3,40(sp)
    800024a8:	7a02                	ld	s4,32(sp)
    800024aa:	6ae2                	ld	s5,24(sp)
    800024ac:	6b42                	ld	s6,16(sp)
    800024ae:	6ba2                	ld	s7,8(sp)
    800024b0:	6c02                	ld	s8,0(sp)
    800024b2:	6161                	addi	sp,sp,80
    800024b4:	8082                	ret
            release(&pp->lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	834080e7          	jalr	-1996(ra) # 80000cec <release>
            release(&wait_lock);
    800024c0:	00011517          	auipc	a0,0x11
    800024c4:	0c850513          	addi	a0,a0,200 # 80013588 <wait_lock>
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	824080e7          	jalr	-2012(ra) # 80000cec <release>
            return -1;
    800024d0:	59fd                	li	s3,-1
    800024d2:	b7e9                	j	8000249c <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024d4:	26848493          	addi	s1,s1,616
    800024d8:	03348463          	beq	s1,s3,80002500 <wait+0xf4>
      if (pp->parent == p)
    800024dc:	7c9c                	ld	a5,56(s1)
    800024de:	ff279be3          	bne	a5,s2,800024d4 <wait+0xc8>
        acquire(&pp->lock);
    800024e2:	8526                	mv	a0,s1
    800024e4:	ffffe097          	auipc	ra,0xffffe
    800024e8:	754080e7          	jalr	1876(ra) # 80000c38 <acquire>
        if (pp->state == ZOMBIE)
    800024ec:	4c9c                	lw	a5,24(s1)
    800024ee:	f74785e3          	beq	a5,s4,80002458 <wait+0x4c>
        release(&pp->lock);
    800024f2:	8526                	mv	a0,s1
    800024f4:	ffffe097          	auipc	ra,0xffffe
    800024f8:	7f8080e7          	jalr	2040(ra) # 80000cec <release>
        havekids = 1;
    800024fc:	8756                	mv	a4,s5
    800024fe:	bfd9                	j	800024d4 <wait+0xc8>
    if (!havekids || killed(p))
    80002500:	c31d                	beqz	a4,80002526 <wait+0x11a>
    80002502:	854a                	mv	a0,s2
    80002504:	00000097          	auipc	ra,0x0
    80002508:	ed6080e7          	jalr	-298(ra) # 800023da <killed>
    8000250c:	ed09                	bnez	a0,80002526 <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000250e:	85e2                	mv	a1,s8
    80002510:	854a                	mv	a0,s2
    80002512:	00000097          	auipc	ra,0x0
    80002516:	c14080e7          	jalr	-1004(ra) # 80002126 <sleep>
    havekids = 0;
    8000251a:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000251c:	00011497          	auipc	s1,0x11
    80002520:	48448493          	addi	s1,s1,1156 # 800139a0 <proc>
    80002524:	bf65                	j	800024dc <wait+0xd0>
      release(&wait_lock);
    80002526:	00011517          	auipc	a0,0x11
    8000252a:	06250513          	addi	a0,a0,98 # 80013588 <wait_lock>
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	7be080e7          	jalr	1982(ra) # 80000cec <release>
      return -1;
    80002536:	59fd                	li	s3,-1
    80002538:	b795                	j	8000249c <wait+0x90>

000000008000253a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000253a:	7179                	addi	sp,sp,-48
    8000253c:	f406                	sd	ra,40(sp)
    8000253e:	f022                	sd	s0,32(sp)
    80002540:	ec26                	sd	s1,24(sp)
    80002542:	e84a                	sd	s2,16(sp)
    80002544:	e44e                	sd	s3,8(sp)
    80002546:	e052                	sd	s4,0(sp)
    80002548:	1800                	addi	s0,sp,48
    8000254a:	84aa                	mv	s1,a0
    8000254c:	892e                	mv	s2,a1
    8000254e:	89b2                	mv	s3,a2
    80002550:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002552:	fffff097          	auipc	ra,0xfffff
    80002556:	4f0080e7          	jalr	1264(ra) # 80001a42 <myproc>
  if (user_dst)
    8000255a:	c08d                	beqz	s1,8000257c <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000255c:	86d2                	mv	a3,s4
    8000255e:	864e                	mv	a2,s3
    80002560:	85ca                	mv	a1,s2
    80002562:	6928                	ld	a0,80(a0)
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	17e080e7          	jalr	382(ra) # 800016e2 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000256c:	70a2                	ld	ra,40(sp)
    8000256e:	7402                	ld	s0,32(sp)
    80002570:	64e2                	ld	s1,24(sp)
    80002572:	6942                	ld	s2,16(sp)
    80002574:	69a2                	ld	s3,8(sp)
    80002576:	6a02                	ld	s4,0(sp)
    80002578:	6145                	addi	sp,sp,48
    8000257a:	8082                	ret
    memmove((char *)dst, src, len);
    8000257c:	000a061b          	sext.w	a2,s4
    80002580:	85ce                	mv	a1,s3
    80002582:	854a                	mv	a0,s2
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	80c080e7          	jalr	-2036(ra) # 80000d90 <memmove>
    return 0;
    8000258c:	8526                	mv	a0,s1
    8000258e:	bff9                	j	8000256c <either_copyout+0x32>

0000000080002590 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002590:	7179                	addi	sp,sp,-48
    80002592:	f406                	sd	ra,40(sp)
    80002594:	f022                	sd	s0,32(sp)
    80002596:	ec26                	sd	s1,24(sp)
    80002598:	e84a                	sd	s2,16(sp)
    8000259a:	e44e                	sd	s3,8(sp)
    8000259c:	e052                	sd	s4,0(sp)
    8000259e:	1800                	addi	s0,sp,48
    800025a0:	892a                	mv	s2,a0
    800025a2:	84ae                	mv	s1,a1
    800025a4:	89b2                	mv	s3,a2
    800025a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025a8:	fffff097          	auipc	ra,0xfffff
    800025ac:	49a080e7          	jalr	1178(ra) # 80001a42 <myproc>
  if (user_src)
    800025b0:	c08d                	beqz	s1,800025d2 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800025b2:	86d2                	mv	a3,s4
    800025b4:	864e                	mv	a2,s3
    800025b6:	85ca                	mv	a1,s2
    800025b8:	6928                	ld	a0,80(a0)
    800025ba:	fffff097          	auipc	ra,0xfffff
    800025be:	1b4080e7          	jalr	436(ra) # 8000176e <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800025c2:	70a2                	ld	ra,40(sp)
    800025c4:	7402                	ld	s0,32(sp)
    800025c6:	64e2                	ld	s1,24(sp)
    800025c8:	6942                	ld	s2,16(sp)
    800025ca:	69a2                	ld	s3,8(sp)
    800025cc:	6a02                	ld	s4,0(sp)
    800025ce:	6145                	addi	sp,sp,48
    800025d0:	8082                	ret
    memmove(dst, (char *)src, len);
    800025d2:	000a061b          	sext.w	a2,s4
    800025d6:	85ce                	mv	a1,s3
    800025d8:	854a                	mv	a0,s2
    800025da:	ffffe097          	auipc	ra,0xffffe
    800025de:	7b6080e7          	jalr	1974(ra) # 80000d90 <memmove>
    return 0;
    800025e2:	8526                	mv	a0,s1
    800025e4:	bff9                	j	800025c2 <either_copyin+0x32>

00000000800025e6 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025e6:	715d                	addi	sp,sp,-80
    800025e8:	e486                	sd	ra,72(sp)
    800025ea:	e0a2                	sd	s0,64(sp)
    800025ec:	fc26                	sd	s1,56(sp)
    800025ee:	f84a                	sd	s2,48(sp)
    800025f0:	f44e                	sd	s3,40(sp)
    800025f2:	f052                	sd	s4,32(sp)
    800025f4:	ec56                	sd	s5,24(sp)
    800025f6:	e85a                	sd	s6,16(sp)
    800025f8:	e45e                	sd	s7,8(sp)
    800025fa:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800025fc:	00006517          	auipc	a0,0x6
    80002600:	a1450513          	addi	a0,a0,-1516 # 80008010 <etext+0x10>
    80002604:	ffffe097          	auipc	ra,0xffffe
    80002608:	fa6080e7          	jalr	-90(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000260c:	00011497          	auipc	s1,0x11
    80002610:	4ec48493          	addi	s1,s1,1260 # 80013af8 <proc+0x158>
    80002614:	0001b917          	auipc	s2,0x1b
    80002618:	ee490913          	addi	s2,s2,-284 # 8001d4f8 <bcache+0x70>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000261c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000261e:	00006997          	auipc	s3,0x6
    80002622:	c4298993          	addi	s3,s3,-958 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002626:	00006a97          	auipc	s5,0x6
    8000262a:	c42a8a93          	addi	s5,s5,-958 # 80008268 <etext+0x268>
    printf("\n");
    8000262e:	00006a17          	auipc	s4,0x6
    80002632:	9e2a0a13          	addi	s4,s4,-1566 # 80008010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002636:	00006b97          	auipc	s7,0x6
    8000263a:	122b8b93          	addi	s7,s7,290 # 80008758 <states.0>
    8000263e:	a00d                	j	80002660 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002640:	ed86a583          	lw	a1,-296(a3)
    80002644:	8556                	mv	a0,s5
    80002646:	ffffe097          	auipc	ra,0xffffe
    8000264a:	f64080e7          	jalr	-156(ra) # 800005aa <printf>
    printf("\n");
    8000264e:	8552                	mv	a0,s4
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	f5a080e7          	jalr	-166(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002658:	26848493          	addi	s1,s1,616
    8000265c:	03248263          	beq	s1,s2,80002680 <procdump+0x9a>
    if (p->state == UNUSED)
    80002660:	86a6                	mv	a3,s1
    80002662:	ec04a783          	lw	a5,-320(s1)
    80002666:	dbed                	beqz	a5,80002658 <procdump+0x72>
      state = "???";
    80002668:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000266a:	fcfb6be3          	bltu	s6,a5,80002640 <procdump+0x5a>
    8000266e:	02079713          	slli	a4,a5,0x20
    80002672:	01d75793          	srli	a5,a4,0x1d
    80002676:	97de                	add	a5,a5,s7
    80002678:	6390                	ld	a2,0(a5)
    8000267a:	f279                	bnez	a2,80002640 <procdump+0x5a>
      state = "???";
    8000267c:	864e                	mv	a2,s3
    8000267e:	b7c9                	j	80002640 <procdump+0x5a>
  }
}
    80002680:	60a6                	ld	ra,72(sp)
    80002682:	6406                	ld	s0,64(sp)
    80002684:	74e2                	ld	s1,56(sp)
    80002686:	7942                	ld	s2,48(sp)
    80002688:	79a2                	ld	s3,40(sp)
    8000268a:	7a02                	ld	s4,32(sp)
    8000268c:	6ae2                	ld	s5,24(sp)
    8000268e:	6b42                	ld	s6,16(sp)
    80002690:	6ba2                	ld	s7,8(sp)
    80002692:	6161                	addi	sp,sp,80
    80002694:	8082                	ret

0000000080002696 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002696:	711d                	addi	sp,sp,-96
    80002698:	ec86                	sd	ra,88(sp)
    8000269a:	e8a2                	sd	s0,80(sp)
    8000269c:	e4a6                	sd	s1,72(sp)
    8000269e:	e0ca                	sd	s2,64(sp)
    800026a0:	fc4e                	sd	s3,56(sp)
    800026a2:	f852                	sd	s4,48(sp)
    800026a4:	f456                	sd	s5,40(sp)
    800026a6:	f05a                	sd	s6,32(sp)
    800026a8:	ec5e                	sd	s7,24(sp)
    800026aa:	e862                	sd	s8,16(sp)
    800026ac:	e466                	sd	s9,8(sp)
    800026ae:	e06a                	sd	s10,0(sp)
    800026b0:	1080                	addi	s0,sp,96
    800026b2:	8b2a                	mv	s6,a0
    800026b4:	8bae                	mv	s7,a1
    800026b6:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800026b8:	fffff097          	auipc	ra,0xfffff
    800026bc:	38a080e7          	jalr	906(ra) # 80001a42 <myproc>
    800026c0:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800026c2:	00011517          	auipc	a0,0x11
    800026c6:	ec650513          	addi	a0,a0,-314 # 80013588 <wait_lock>
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	56e080e7          	jalr	1390(ra) # 80000c38 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800026d2:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800026d4:	4a15                	li	s4,5
        havekids = 1;
    800026d6:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800026d8:	0001b997          	auipc	s3,0x1b
    800026dc:	cc898993          	addi	s3,s3,-824 # 8001d3a0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800026e0:	00011d17          	auipc	s10,0x11
    800026e4:	ea8d0d13          	addi	s10,s10,-344 # 80013588 <wait_lock>
    800026e8:	a8e9                	j	800027c2 <waitx+0x12c>
          pid = np->pid;
    800026ea:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800026ee:	1684a783          	lw	a5,360(s1)
    800026f2:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800026f6:	16c4a703          	lw	a4,364(s1)
    800026fa:	9f3d                	addw	a4,a4,a5
    800026fc:	1704a783          	lw	a5,368(s1)
    80002700:	9f99                	subw	a5,a5,a4
    80002702:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002706:	000b0e63          	beqz	s6,80002722 <waitx+0x8c>
    8000270a:	4691                	li	a3,4
    8000270c:	02c48613          	addi	a2,s1,44
    80002710:	85da                	mv	a1,s6
    80002712:	05093503          	ld	a0,80(s2)
    80002716:	fffff097          	auipc	ra,0xfffff
    8000271a:	fcc080e7          	jalr	-52(ra) # 800016e2 <copyout>
    8000271e:	04054363          	bltz	a0,80002764 <waitx+0xce>
          freeproc(np);
    80002722:	8526                	mv	a0,s1
    80002724:	fffff097          	auipc	ra,0xfffff
    80002728:	4d0080e7          	jalr	1232(ra) # 80001bf4 <freeproc>
          release(&np->lock);
    8000272c:	8526                	mv	a0,s1
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	5be080e7          	jalr	1470(ra) # 80000cec <release>
          release(&wait_lock);
    80002736:	00011517          	auipc	a0,0x11
    8000273a:	e5250513          	addi	a0,a0,-430 # 80013588 <wait_lock>
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	5ae080e7          	jalr	1454(ra) # 80000cec <release>
  }
}
    80002746:	854e                	mv	a0,s3
    80002748:	60e6                	ld	ra,88(sp)
    8000274a:	6446                	ld	s0,80(sp)
    8000274c:	64a6                	ld	s1,72(sp)
    8000274e:	6906                	ld	s2,64(sp)
    80002750:	79e2                	ld	s3,56(sp)
    80002752:	7a42                	ld	s4,48(sp)
    80002754:	7aa2                	ld	s5,40(sp)
    80002756:	7b02                	ld	s6,32(sp)
    80002758:	6be2                	ld	s7,24(sp)
    8000275a:	6c42                	ld	s8,16(sp)
    8000275c:	6ca2                	ld	s9,8(sp)
    8000275e:	6d02                	ld	s10,0(sp)
    80002760:	6125                	addi	sp,sp,96
    80002762:	8082                	ret
            release(&np->lock);
    80002764:	8526                	mv	a0,s1
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	586080e7          	jalr	1414(ra) # 80000cec <release>
            release(&wait_lock);
    8000276e:	00011517          	auipc	a0,0x11
    80002772:	e1a50513          	addi	a0,a0,-486 # 80013588 <wait_lock>
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	576080e7          	jalr	1398(ra) # 80000cec <release>
            return -1;
    8000277e:	59fd                	li	s3,-1
    80002780:	b7d9                	j	80002746 <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    80002782:	26848493          	addi	s1,s1,616
    80002786:	03348463          	beq	s1,s3,800027ae <waitx+0x118>
      if (np->parent == p)
    8000278a:	7c9c                	ld	a5,56(s1)
    8000278c:	ff279be3          	bne	a5,s2,80002782 <waitx+0xec>
        acquire(&np->lock);
    80002790:	8526                	mv	a0,s1
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	4a6080e7          	jalr	1190(ra) # 80000c38 <acquire>
        if (np->state == ZOMBIE)
    8000279a:	4c9c                	lw	a5,24(s1)
    8000279c:	f54787e3          	beq	a5,s4,800026ea <waitx+0x54>
        release(&np->lock);
    800027a0:	8526                	mv	a0,s1
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	54a080e7          	jalr	1354(ra) # 80000cec <release>
        havekids = 1;
    800027aa:	8756                	mv	a4,s5
    800027ac:	bfd9                	j	80002782 <waitx+0xec>
    if (!havekids || p->killed)
    800027ae:	c305                	beqz	a4,800027ce <waitx+0x138>
    800027b0:	02892783          	lw	a5,40(s2)
    800027b4:	ef89                	bnez	a5,800027ce <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027b6:	85ea                	mv	a1,s10
    800027b8:	854a                	mv	a0,s2
    800027ba:	00000097          	auipc	ra,0x0
    800027be:	96c080e7          	jalr	-1684(ra) # 80002126 <sleep>
    havekids = 0;
    800027c2:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800027c4:	00011497          	auipc	s1,0x11
    800027c8:	1dc48493          	addi	s1,s1,476 # 800139a0 <proc>
    800027cc:	bf7d                	j	8000278a <waitx+0xf4>
      release(&wait_lock);
    800027ce:	00011517          	auipc	a0,0x11
    800027d2:	dba50513          	addi	a0,a0,-582 # 80013588 <wait_lock>
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	516080e7          	jalr	1302(ra) # 80000cec <release>
      return -1;
    800027de:	59fd                	li	s3,-1
    800027e0:	b79d                	j	80002746 <waitx+0xb0>

00000000800027e2 <update_time>:

void update_time()
{
    800027e2:	7179                	addi	sp,sp,-48
    800027e4:	f406                	sd	ra,40(sp)
    800027e6:	f022                	sd	s0,32(sp)
    800027e8:	ec26                	sd	s1,24(sp)
    800027ea:	e84a                	sd	s2,16(sp)
    800027ec:	e44e                	sd	s3,8(sp)
    800027ee:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800027f0:	00011497          	auipc	s1,0x11
    800027f4:	1b048493          	addi	s1,s1,432 # 800139a0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800027f8:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    800027fa:	0001b917          	auipc	s2,0x1b
    800027fe:	ba690913          	addi	s2,s2,-1114 # 8001d3a0 <tickslock>
    80002802:	a811                	j	80002816 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002804:	8526                	mv	a0,s1
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	4e6080e7          	jalr	1254(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000280e:	26848493          	addi	s1,s1,616
    80002812:	03248063          	beq	s1,s2,80002832 <update_time+0x50>
    acquire(&p->lock);
    80002816:	8526                	mv	a0,s1
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	420080e7          	jalr	1056(ra) # 80000c38 <acquire>
    if (p->state == RUNNING)
    80002820:	4c9c                	lw	a5,24(s1)
    80002822:	ff3791e3          	bne	a5,s3,80002804 <update_time+0x22>
      p->rtime++;
    80002826:	1684a783          	lw	a5,360(s1)
    8000282a:	2785                	addiw	a5,a5,1
    8000282c:	16f4a423          	sw	a5,360(s1)
    80002830:	bfd1                	j	80002804 <update_time+0x22>
  }
    80002832:	70a2                	ld	ra,40(sp)
    80002834:	7402                	ld	s0,32(sp)
    80002836:	64e2                	ld	s1,24(sp)
    80002838:	6942                	ld	s2,16(sp)
    8000283a:	69a2                	ld	s3,8(sp)
    8000283c:	6145                	addi	sp,sp,48
    8000283e:	8082                	ret

0000000080002840 <swtch>:
    80002840:	00153023          	sd	ra,0(a0)
    80002844:	00253423          	sd	sp,8(a0)
    80002848:	e900                	sd	s0,16(a0)
    8000284a:	ed04                	sd	s1,24(a0)
    8000284c:	03253023          	sd	s2,32(a0)
    80002850:	03353423          	sd	s3,40(a0)
    80002854:	03453823          	sd	s4,48(a0)
    80002858:	03553c23          	sd	s5,56(a0)
    8000285c:	05653023          	sd	s6,64(a0)
    80002860:	05753423          	sd	s7,72(a0)
    80002864:	05853823          	sd	s8,80(a0)
    80002868:	05953c23          	sd	s9,88(a0)
    8000286c:	07a53023          	sd	s10,96(a0)
    80002870:	07b53423          	sd	s11,104(a0)
    80002874:	0005b083          	ld	ra,0(a1)
    80002878:	0085b103          	ld	sp,8(a1)
    8000287c:	6980                	ld	s0,16(a1)
    8000287e:	6d84                	ld	s1,24(a1)
    80002880:	0205b903          	ld	s2,32(a1)
    80002884:	0285b983          	ld	s3,40(a1)
    80002888:	0305ba03          	ld	s4,48(a1)
    8000288c:	0385ba83          	ld	s5,56(a1)
    80002890:	0405bb03          	ld	s6,64(a1)
    80002894:	0485bb83          	ld	s7,72(a1)
    80002898:	0505bc03          	ld	s8,80(a1)
    8000289c:	0585bc83          	ld	s9,88(a1)
    800028a0:	0605bd03          	ld	s10,96(a1)
    800028a4:	0685bd83          	ld	s11,104(a1)
    800028a8:	8082                	ret

00000000800028aa <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800028aa:	1141                	addi	sp,sp,-16
    800028ac:	e406                	sd	ra,8(sp)
    800028ae:	e022                	sd	s0,0(sp)
    800028b0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028b2:	00006597          	auipc	a1,0x6
    800028b6:	9f658593          	addi	a1,a1,-1546 # 800082a8 <etext+0x2a8>
    800028ba:	0001b517          	auipc	a0,0x1b
    800028be:	ae650513          	addi	a0,a0,-1306 # 8001d3a0 <tickslock>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	2e6080e7          	jalr	742(ra) # 80000ba8 <initlock>
}
    800028ca:	60a2                	ld	ra,8(sp)
    800028cc:	6402                	ld	s0,0(sp)
    800028ce:	0141                	addi	sp,sp,16
    800028d0:	8082                	ret

00000000800028d2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800028d2:	1141                	addi	sp,sp,-16
    800028d4:	e422                	sd	s0,8(sp)
    800028d6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028d8:	00003797          	auipc	a5,0x3
    800028dc:	7b878793          	addi	a5,a5,1976 # 80006090 <kernelvec>
    800028e0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028e4:	6422                	ld	s0,8(sp)
    800028e6:	0141                	addi	sp,sp,16
    800028e8:	8082                	ret

00000000800028ea <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800028ea:	1141                	addi	sp,sp,-16
    800028ec:	e406                	sd	ra,8(sp)
    800028ee:	e022                	sd	s0,0(sp)
    800028f0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028f2:	fffff097          	auipc	ra,0xfffff
    800028f6:	150080e7          	jalr	336(ra) # 80001a42 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028fe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002900:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002904:	00004697          	auipc	a3,0x4
    80002908:	6fc68693          	addi	a3,a3,1788 # 80007000 <_trampoline>
    8000290c:	00004717          	auipc	a4,0x4
    80002910:	6f470713          	addi	a4,a4,1780 # 80007000 <_trampoline>
    80002914:	8f15                	sub	a4,a4,a3
    80002916:	040007b7          	lui	a5,0x4000
    8000291a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000291c:	07b2                	slli	a5,a5,0xc
    8000291e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002920:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002924:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002926:	18002673          	csrr	a2,satp
    8000292a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000292c:	6d30                	ld	a2,88(a0)
    8000292e:	6138                	ld	a4,64(a0)
    80002930:	6585                	lui	a1,0x1
    80002932:	972e                	add	a4,a4,a1
    80002934:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002936:	6d38                	ld	a4,88(a0)
    80002938:	00000617          	auipc	a2,0x0
    8000293c:	14660613          	addi	a2,a2,326 # 80002a7e <usertrap>
    80002940:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002942:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002944:	8612                	mv	a2,tp
    80002946:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002948:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000294c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002950:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002954:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002958:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000295a:	6f18                	ld	a4,24(a4)
    8000295c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002960:	6928                	ld	a0,80(a0)
    80002962:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002964:	00004717          	auipc	a4,0x4
    80002968:	73870713          	addi	a4,a4,1848 # 8000709c <userret>
    8000296c:	8f15                	sub	a4,a4,a3
    8000296e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002970:	577d                	li	a4,-1
    80002972:	177e                	slli	a4,a4,0x3f
    80002974:	8d59                	or	a0,a0,a4
    80002976:	9782                	jalr	a5
}
    80002978:	60a2                	ld	ra,8(sp)
    8000297a:	6402                	ld	s0,0(sp)
    8000297c:	0141                	addi	sp,sp,16
    8000297e:	8082                	ret

0000000080002980 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002980:	1101                	addi	sp,sp,-32
    80002982:	ec06                	sd	ra,24(sp)
    80002984:	e822                	sd	s0,16(sp)
    80002986:	e426                	sd	s1,8(sp)
    80002988:	e04a                	sd	s2,0(sp)
    8000298a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000298c:	0001b917          	auipc	s2,0x1b
    80002990:	a1490913          	addi	s2,s2,-1516 # 8001d3a0 <tickslock>
    80002994:	854a                	mv	a0,s2
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	2a2080e7          	jalr	674(ra) # 80000c38 <acquire>
  ticks++;
    8000299e:	00009497          	auipc	s1,0x9
    800029a2:	96248493          	addi	s1,s1,-1694 # 8000b300 <ticks>
    800029a6:	409c                	lw	a5,0(s1)
    800029a8:	2785                	addiw	a5,a5,1
    800029aa:	c09c                	sw	a5,0(s1)
  update_time();
    800029ac:	00000097          	auipc	ra,0x0
    800029b0:	e36080e7          	jalr	-458(ra) # 800027e2 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    800029b4:	8526                	mv	a0,s1
    800029b6:	fffff097          	auipc	ra,0xfffff
    800029ba:	7d4080e7          	jalr	2004(ra) # 8000218a <wakeup>
  release(&tickslock);
    800029be:	854a                	mv	a0,s2
    800029c0:	ffffe097          	auipc	ra,0xffffe
    800029c4:	32c080e7          	jalr	812(ra) # 80000cec <release>
}
    800029c8:	60e2                	ld	ra,24(sp)
    800029ca:	6442                	ld	s0,16(sp)
    800029cc:	64a2                	ld	s1,8(sp)
    800029ce:	6902                	ld	s2,0(sp)
    800029d0:	6105                	addi	sp,sp,32
    800029d2:	8082                	ret

00000000800029d4 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029d4:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    800029d8:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    800029da:	0a07d163          	bgez	a5,80002a7c <devintr+0xa8>
{
    800029de:	1101                	addi	sp,sp,-32
    800029e0:	ec06                	sd	ra,24(sp)
    800029e2:	e822                	sd	s0,16(sp)
    800029e4:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    800029e6:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    800029ea:	46a5                	li	a3,9
    800029ec:	00d70c63          	beq	a4,a3,80002a04 <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    800029f0:	577d                	li	a4,-1
    800029f2:	177e                	slli	a4,a4,0x3f
    800029f4:	0705                	addi	a4,a4,1
    return 0;
    800029f6:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    800029f8:	06e78163          	beq	a5,a4,80002a5a <devintr+0x86>
  }
    800029fc:	60e2                	ld	ra,24(sp)
    800029fe:	6442                	ld	s0,16(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret
    80002a04:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a06:	00003097          	auipc	ra,0x3
    80002a0a:	796080e7          	jalr	1942(ra) # 8000619c <plic_claim>
    80002a0e:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002a10:	47a9                	li	a5,10
    80002a12:	00f50963          	beq	a0,a5,80002a24 <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002a16:	4785                	li	a5,1
    80002a18:	00f50b63          	beq	a0,a5,80002a2e <devintr+0x5a>
    return 1;
    80002a1c:	4505                	li	a0,1
    else if (irq)
    80002a1e:	ec89                	bnez	s1,80002a38 <devintr+0x64>
    80002a20:	64a2                	ld	s1,8(sp)
    80002a22:	bfe9                	j	800029fc <devintr+0x28>
      uartintr();
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	fd6080e7          	jalr	-42(ra) # 800009fa <uartintr>
    if (irq)
    80002a2c:	a839                	j	80002a4a <devintr+0x76>
      virtio_disk_intr();
    80002a2e:	00004097          	auipc	ra,0x4
    80002a32:	c98080e7          	jalr	-872(ra) # 800066c6 <virtio_disk_intr>
    if (irq)
    80002a36:	a811                	j	80002a4a <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a38:	85a6                	mv	a1,s1
    80002a3a:	00006517          	auipc	a0,0x6
    80002a3e:	87650513          	addi	a0,a0,-1930 # 800082b0 <etext+0x2b0>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	b68080e7          	jalr	-1176(ra) # 800005aa <printf>
      plic_complete(irq);
    80002a4a:	8526                	mv	a0,s1
    80002a4c:	00003097          	auipc	ra,0x3
    80002a50:	774080e7          	jalr	1908(ra) # 800061c0 <plic_complete>
    return 1;
    80002a54:	4505                	li	a0,1
    80002a56:	64a2                	ld	s1,8(sp)
    80002a58:	b755                	j	800029fc <devintr+0x28>
    if (cpuid() == 0)
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	fbc080e7          	jalr	-68(ra) # 80001a16 <cpuid>
    80002a62:	c901                	beqz	a0,80002a72 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a64:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a68:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a6a:	14479073          	csrw	sip,a5
    return 2;
    80002a6e:	4509                	li	a0,2
    80002a70:	b771                	j	800029fc <devintr+0x28>
      clockintr();
    80002a72:	00000097          	auipc	ra,0x0
    80002a76:	f0e080e7          	jalr	-242(ra) # 80002980 <clockintr>
    80002a7a:	b7ed                	j	80002a64 <devintr+0x90>
    80002a7c:	8082                	ret

0000000080002a7e <usertrap>:
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	e04a                	sd	s2,0(sp)
    80002a88:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a8a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a8e:	1007f793          	andi	a5,a5,256
    80002a92:	e3b1                	bnez	a5,80002ad6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a94:	00003797          	auipc	a5,0x3
    80002a98:	5fc78793          	addi	a5,a5,1532 # 80006090 <kernelvec>
    80002a9c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	fa2080e7          	jalr	-94(ra) # 80001a42 <myproc>
    80002aa8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002aaa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aac:	14102773          	csrr	a4,sepc
    80002ab0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ab2:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002ab6:	47a1                	li	a5,8
    80002ab8:	02f70763          	beq	a4,a5,80002ae6 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	f18080e7          	jalr	-232(ra) # 800029d4 <devintr>
    80002ac4:	892a                	mv	s2,a0
    80002ac6:	c92d                	beqz	a0,80002b38 <usertrap+0xba>
  if (killed(p))
    80002ac8:	8526                	mv	a0,s1
    80002aca:	00000097          	auipc	ra,0x0
    80002ace:	910080e7          	jalr	-1776(ra) # 800023da <killed>
    80002ad2:	c555                	beqz	a0,80002b7e <usertrap+0x100>
    80002ad4:	a045                	j	80002b74 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002ad6:	00005517          	auipc	a0,0x5
    80002ada:	7fa50513          	addi	a0,a0,2042 # 800082d0 <etext+0x2d0>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	a82080e7          	jalr	-1406(ra) # 80000560 <panic>
    if (killed(p))
    80002ae6:	00000097          	auipc	ra,0x0
    80002aea:	8f4080e7          	jalr	-1804(ra) # 800023da <killed>
    80002aee:	ed1d                	bnez	a0,80002b2c <usertrap+0xae>
    p->trapframe->epc += 4;
    80002af0:	6cb8                	ld	a4,88(s1)
    80002af2:	6f1c                	ld	a5,24(a4)
    80002af4:	0791                	addi	a5,a5,4
    80002af6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002afc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b00:	10079073          	csrw	sstatus,a5
    syscall();
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	33c080e7          	jalr	828(ra) # 80002e40 <syscall>
  if (killed(p))
    80002b0c:	8526                	mv	a0,s1
    80002b0e:	00000097          	auipc	ra,0x0
    80002b12:	8cc080e7          	jalr	-1844(ra) # 800023da <killed>
    80002b16:	ed31                	bnez	a0,80002b72 <usertrap+0xf4>
  usertrapret();
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	dd2080e7          	jalr	-558(ra) # 800028ea <usertrapret>
}
    80002b20:	60e2                	ld	ra,24(sp)
    80002b22:	6442                	ld	s0,16(sp)
    80002b24:	64a2                	ld	s1,8(sp)
    80002b26:	6902                	ld	s2,0(sp)
    80002b28:	6105                	addi	sp,sp,32
    80002b2a:	8082                	ret
      exit(-1);
    80002b2c:	557d                	li	a0,-1
    80002b2e:	fffff097          	auipc	ra,0xfffff
    80002b32:	72c080e7          	jalr	1836(ra) # 8000225a <exit>
    80002b36:	bf6d                	j	80002af0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b38:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b3c:	5890                	lw	a2,48(s1)
    80002b3e:	00005517          	auipc	a0,0x5
    80002b42:	7b250513          	addi	a0,a0,1970 # 800082f0 <etext+0x2f0>
    80002b46:	ffffe097          	auipc	ra,0xffffe
    80002b4a:	a64080e7          	jalr	-1436(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b4e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b52:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b56:	00005517          	auipc	a0,0x5
    80002b5a:	7ca50513          	addi	a0,a0,1994 # 80008320 <etext+0x320>
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	a4c080e7          	jalr	-1460(ra) # 800005aa <printf>
    setkilled(p);
    80002b66:	8526                	mv	a0,s1
    80002b68:	00000097          	auipc	ra,0x0
    80002b6c:	846080e7          	jalr	-1978(ra) # 800023ae <setkilled>
    80002b70:	bf71                	j	80002b0c <usertrap+0x8e>
  if (killed(p))
    80002b72:	4901                	li	s2,0
    exit(-1);
    80002b74:	557d                	li	a0,-1
    80002b76:	fffff097          	auipc	ra,0xfffff
    80002b7a:	6e4080e7          	jalr	1764(ra) # 8000225a <exit>
  if (which_dev == 2)
    80002b7e:	4789                	li	a5,2
    80002b80:	f8f91ce3          	bne	s2,a5,80002b18 <usertrap+0x9a>
    yield();
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	566080e7          	jalr	1382(ra) # 800020ea <yield>
    struct proc *p = myproc();
    80002b8c:	fffff097          	auipc	ra,0xfffff
    80002b90:	eb6080e7          	jalr	-330(ra) # 80001a42 <myproc>
    80002b94:	84aa                	mv	s1,a0
    if (p->alarm_interval > 0)
    80002b96:	24852703          	lw	a4,584(a0)
    80002b9a:	f6e05fe3          	blez	a4,80002b18 <usertrap+0x9a>
      p->ticks_count++;
    80002b9e:	25852783          	lw	a5,600(a0)
    80002ba2:	2785                	addiw	a5,a5,1
    80002ba4:	0007869b          	sext.w	a3,a5
    80002ba8:	24f52c23          	sw	a5,600(a0)
      if (p->ticks_count >= p->alarm_interval && !p->alarm_active)
    80002bac:	f6e6c6e3          	blt	a3,a4,80002b18 <usertrap+0x9a>
    80002bb0:	25c52783          	lw	a5,604(a0)
    80002bb4:	f3b5                	bnez	a5,80002b18 <usertrap+0x9a>
        p->ticks_count = 0;
    80002bb6:	24052c23          	sw	zero,600(a0)
        p->alarm_active = 1;
    80002bba:	4785                	li	a5,1
    80002bbc:	24f52e23          	sw	a5,604(a0)
        p->alarm_tf = kalloc();
    80002bc0:	ffffe097          	auipc	ra,0xffffe
    80002bc4:	f88080e7          	jalr	-120(ra) # 80000b48 <kalloc>
    80002bc8:	26a4b023          	sd	a0,608(s1)
        if (p->alarm_tf == 0)
    80002bcc:	cd09                	beqz	a0,80002be6 <usertrap+0x168>
        memmove(p->alarm_tf, p->trapframe, sizeof(struct trapframe));
    80002bce:	12000613          	li	a2,288
    80002bd2:	6cac                	ld	a1,88(s1)
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	1bc080e7          	jalr	444(ra) # 80000d90 <memmove>
        p->trapframe->epc = (uint64)p->alarm_handler;
    80002bdc:	6cbc                	ld	a5,88(s1)
    80002bde:	2504b703          	ld	a4,592(s1)
    80002be2:	ef98                	sd	a4,24(a5)
    80002be4:	bf15                	j	80002b18 <usertrap+0x9a>
          panic("usertrap: out of memory");
    80002be6:	00005517          	auipc	a0,0x5
    80002bea:	75a50513          	addi	a0,a0,1882 # 80008340 <etext+0x340>
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	972080e7          	jalr	-1678(ra) # 80000560 <panic>

0000000080002bf6 <kerneltrap>:
{
    80002bf6:	7179                	addi	sp,sp,-48
    80002bf8:	f406                	sd	ra,40(sp)
    80002bfa:	f022                	sd	s0,32(sp)
    80002bfc:	ec26                	sd	s1,24(sp)
    80002bfe:	e84a                	sd	s2,16(sp)
    80002c00:	e44e                	sd	s3,8(sp)
    80002c02:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c04:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c08:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002c10:	1004f793          	andi	a5,s1,256
    80002c14:	cb85                	beqz	a5,80002c44 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c16:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c1a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002c1c:	ef85                	bnez	a5,80002c54 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002c1e:	00000097          	auipc	ra,0x0
    80002c22:	db6080e7          	jalr	-586(ra) # 800029d4 <devintr>
    80002c26:	cd1d                	beqz	a0,80002c64 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c28:	4789                	li	a5,2
    80002c2a:	06f50a63          	beq	a0,a5,80002c9e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c2e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c32:	10049073          	csrw	sstatus,s1
}
    80002c36:	70a2                	ld	ra,40(sp)
    80002c38:	7402                	ld	s0,32(sp)
    80002c3a:	64e2                	ld	s1,24(sp)
    80002c3c:	6942                	ld	s2,16(sp)
    80002c3e:	69a2                	ld	s3,8(sp)
    80002c40:	6145                	addi	sp,sp,48
    80002c42:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c44:	00005517          	auipc	a0,0x5
    80002c48:	71450513          	addi	a0,a0,1812 # 80008358 <etext+0x358>
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	914080e7          	jalr	-1772(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	72c50513          	addi	a0,a0,1836 # 80008380 <etext+0x380>
    80002c5c:	ffffe097          	auipc	ra,0xffffe
    80002c60:	904080e7          	jalr	-1788(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002c64:	85ce                	mv	a1,s3
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	73a50513          	addi	a0,a0,1850 # 800083a0 <etext+0x3a0>
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	93c080e7          	jalr	-1732(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c76:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c7a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c7e:	00005517          	auipc	a0,0x5
    80002c82:	73250513          	addi	a0,a0,1842 # 800083b0 <etext+0x3b0>
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	924080e7          	jalr	-1756(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002c8e:	00005517          	auipc	a0,0x5
    80002c92:	73a50513          	addi	a0,a0,1850 # 800083c8 <etext+0x3c8>
    80002c96:	ffffe097          	auipc	ra,0xffffe
    80002c9a:	8ca080e7          	jalr	-1846(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	da4080e7          	jalr	-604(ra) # 80001a42 <myproc>
    80002ca6:	d541                	beqz	a0,80002c2e <kerneltrap+0x38>
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	d9a080e7          	jalr	-614(ra) # 80001a42 <myproc>
    80002cb0:	4d18                	lw	a4,24(a0)
    80002cb2:	4791                	li	a5,4
    80002cb4:	f6f71de3          	bne	a4,a5,80002c2e <kerneltrap+0x38>
    yield();
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	432080e7          	jalr	1074(ra) # 800020ea <yield>
    80002cc0:	b7bd                	j	80002c2e <kerneltrap+0x38>

0000000080002cc2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	1000                	addi	s0,sp,32
    80002ccc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	d74080e7          	jalr	-652(ra) # 80001a42 <myproc>
  switch (n)
    80002cd6:	4795                	li	a5,5
    80002cd8:	0497e163          	bltu	a5,s1,80002d1a <argraw+0x58>
    80002cdc:	048a                	slli	s1,s1,0x2
    80002cde:	00006717          	auipc	a4,0x6
    80002ce2:	aaa70713          	addi	a4,a4,-1366 # 80008788 <states.0+0x30>
    80002ce6:	94ba                	add	s1,s1,a4
    80002ce8:	409c                	lw	a5,0(s1)
    80002cea:	97ba                	add	a5,a5,a4
    80002cec:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002cee:	6d3c                	ld	a5,88(a0)
    80002cf0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cf2:	60e2                	ld	ra,24(sp)
    80002cf4:	6442                	ld	s0,16(sp)
    80002cf6:	64a2                	ld	s1,8(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret
    return p->trapframe->a1;
    80002cfc:	6d3c                	ld	a5,88(a0)
    80002cfe:	7fa8                	ld	a0,120(a5)
    80002d00:	bfcd                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a2;
    80002d02:	6d3c                	ld	a5,88(a0)
    80002d04:	63c8                	ld	a0,128(a5)
    80002d06:	b7f5                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a3;
    80002d08:	6d3c                	ld	a5,88(a0)
    80002d0a:	67c8                	ld	a0,136(a5)
    80002d0c:	b7dd                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a4;
    80002d0e:	6d3c                	ld	a5,88(a0)
    80002d10:	6bc8                	ld	a0,144(a5)
    80002d12:	b7c5                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a5;
    80002d14:	6d3c                	ld	a5,88(a0)
    80002d16:	6fc8                	ld	a0,152(a5)
    80002d18:	bfe9                	j	80002cf2 <argraw+0x30>
  panic("argraw");
    80002d1a:	00005517          	auipc	a0,0x5
    80002d1e:	6be50513          	addi	a0,a0,1726 # 800083d8 <etext+0x3d8>
    80002d22:	ffffe097          	auipc	ra,0xffffe
    80002d26:	83e080e7          	jalr	-1986(ra) # 80000560 <panic>

0000000080002d2a <fetchaddr>:
{
    80002d2a:	1101                	addi	sp,sp,-32
    80002d2c:	ec06                	sd	ra,24(sp)
    80002d2e:	e822                	sd	s0,16(sp)
    80002d30:	e426                	sd	s1,8(sp)
    80002d32:	e04a                	sd	s2,0(sp)
    80002d34:	1000                	addi	s0,sp,32
    80002d36:	84aa                	mv	s1,a0
    80002d38:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	d08080e7          	jalr	-760(ra) # 80001a42 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d42:	653c                	ld	a5,72(a0)
    80002d44:	02f4f863          	bgeu	s1,a5,80002d74 <fetchaddr+0x4a>
    80002d48:	00848713          	addi	a4,s1,8
    80002d4c:	02e7e663          	bltu	a5,a4,80002d78 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d50:	46a1                	li	a3,8
    80002d52:	8626                	mv	a2,s1
    80002d54:	85ca                	mv	a1,s2
    80002d56:	6928                	ld	a0,80(a0)
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	a16080e7          	jalr	-1514(ra) # 8000176e <copyin>
    80002d60:	00a03533          	snez	a0,a0
    80002d64:	40a00533          	neg	a0,a0
}
    80002d68:	60e2                	ld	ra,24(sp)
    80002d6a:	6442                	ld	s0,16(sp)
    80002d6c:	64a2                	ld	s1,8(sp)
    80002d6e:	6902                	ld	s2,0(sp)
    80002d70:	6105                	addi	sp,sp,32
    80002d72:	8082                	ret
    return -1;
    80002d74:	557d                	li	a0,-1
    80002d76:	bfcd                	j	80002d68 <fetchaddr+0x3e>
    80002d78:	557d                	li	a0,-1
    80002d7a:	b7fd                	j	80002d68 <fetchaddr+0x3e>

0000000080002d7c <fetchstr>:
{
    80002d7c:	7179                	addi	sp,sp,-48
    80002d7e:	f406                	sd	ra,40(sp)
    80002d80:	f022                	sd	s0,32(sp)
    80002d82:	ec26                	sd	s1,24(sp)
    80002d84:	e84a                	sd	s2,16(sp)
    80002d86:	e44e                	sd	s3,8(sp)
    80002d88:	1800                	addi	s0,sp,48
    80002d8a:	892a                	mv	s2,a0
    80002d8c:	84ae                	mv	s1,a1
    80002d8e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	cb2080e7          	jalr	-846(ra) # 80001a42 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d98:	86ce                	mv	a3,s3
    80002d9a:	864a                	mv	a2,s2
    80002d9c:	85a6                	mv	a1,s1
    80002d9e:	6928                	ld	a0,80(a0)
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	a5c080e7          	jalr	-1444(ra) # 800017fc <copyinstr>
    80002da8:	00054e63          	bltz	a0,80002dc4 <fetchstr+0x48>
  return strlen(buf);
    80002dac:	8526                	mv	a0,s1
    80002dae:	ffffe097          	auipc	ra,0xffffe
    80002db2:	0fa080e7          	jalr	250(ra) # 80000ea8 <strlen>
}
    80002db6:	70a2                	ld	ra,40(sp)
    80002db8:	7402                	ld	s0,32(sp)
    80002dba:	64e2                	ld	s1,24(sp)
    80002dbc:	6942                	ld	s2,16(sp)
    80002dbe:	69a2                	ld	s3,8(sp)
    80002dc0:	6145                	addi	sp,sp,48
    80002dc2:	8082                	ret
    return -1;
    80002dc4:	557d                	li	a0,-1
    80002dc6:	bfc5                	j	80002db6 <fetchstr+0x3a>

0000000080002dc8 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002dc8:	1101                	addi	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	e426                	sd	s1,8(sp)
    80002dd0:	1000                	addi	s0,sp,32
    80002dd2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	eee080e7          	jalr	-274(ra) # 80002cc2 <argraw>
    80002ddc:	c088                	sw	a0,0(s1)
}
    80002dde:	60e2                	ld	ra,24(sp)
    80002de0:	6442                	ld	s0,16(sp)
    80002de2:	64a2                	ld	s1,8(sp)
    80002de4:	6105                	addi	sp,sp,32
    80002de6:	8082                	ret

0000000080002de8 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002de8:	1101                	addi	sp,sp,-32
    80002dea:	ec06                	sd	ra,24(sp)
    80002dec:	e822                	sd	s0,16(sp)
    80002dee:	e426                	sd	s1,8(sp)
    80002df0:	1000                	addi	s0,sp,32
    80002df2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df4:	00000097          	auipc	ra,0x0
    80002df8:	ece080e7          	jalr	-306(ra) # 80002cc2 <argraw>
    80002dfc:	e088                	sd	a0,0(s1)
}
    80002dfe:	60e2                	ld	ra,24(sp)
    80002e00:	6442                	ld	s0,16(sp)
    80002e02:	64a2                	ld	s1,8(sp)
    80002e04:	6105                	addi	sp,sp,32
    80002e06:	8082                	ret

0000000080002e08 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002e08:	7179                	addi	sp,sp,-48
    80002e0a:	f406                	sd	ra,40(sp)
    80002e0c:	f022                	sd	s0,32(sp)
    80002e0e:	ec26                	sd	s1,24(sp)
    80002e10:	e84a                	sd	s2,16(sp)
    80002e12:	1800                	addi	s0,sp,48
    80002e14:	84ae                	mv	s1,a1
    80002e16:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e18:	fd840593          	addi	a1,s0,-40
    80002e1c:	00000097          	auipc	ra,0x0
    80002e20:	fcc080e7          	jalr	-52(ra) # 80002de8 <argaddr>
  return fetchstr(addr, buf, max);
    80002e24:	864a                	mv	a2,s2
    80002e26:	85a6                	mv	a1,s1
    80002e28:	fd843503          	ld	a0,-40(s0)
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	f50080e7          	jalr	-176(ra) # 80002d7c <fetchstr>
}
    80002e34:	70a2                	ld	ra,40(sp)
    80002e36:	7402                	ld	s0,32(sp)
    80002e38:	64e2                	ld	s1,24(sp)
    80002e3a:	6942                	ld	s2,16(sp)
    80002e3c:	6145                	addi	sp,sp,48
    80002e3e:	8082                	ret

0000000080002e40 <syscall>:
};

// Add a new array to keep track of syscall counts
uint64 syscall_counts[NSYSCALLS] = {0};
void syscall(void)
{
    80002e40:	7179                	addi	sp,sp,-48
    80002e42:	f406                	sd	ra,40(sp)
    80002e44:	f022                	sd	s0,32(sp)
    80002e46:	ec26                	sd	s1,24(sp)
    80002e48:	e84a                	sd	s2,16(sp)
    80002e4a:	e44e                	sd	s3,8(sp)
    80002e4c:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	bf4080e7          	jalr	-1036(ra) # 80001a42 <myproc>
    80002e56:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e58:	05853983          	ld	s3,88(a0)
    80002e5c:	0a89b783          	ld	a5,168(s3)
    80002e60:	0007891b          	sext.w	s2,a5
  if (num > 0 && num < NSYSCALLS && syscalls[num])
    80002e64:	37fd                	addiw	a5,a5,-1
    80002e66:	4761                	li	a4,24
    80002e68:	02f76863          	bltu	a4,a5,80002e98 <syscall+0x58>
    80002e6c:	00391713          	slli	a4,s2,0x3
    80002e70:	00006797          	auipc	a5,0x6
    80002e74:	93078793          	addi	a5,a5,-1744 # 800087a0 <syscalls>
    80002e78:	97ba                	add	a5,a5,a4
    80002e7a:	639c                	ld	a5,0(a5)
    80002e7c:	cf91                	beqz	a5,80002e98 <syscall+0x58>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    // if(num == SYS_exec)
    //   printf("exec called in %d\n",p->pid);
    p->trapframe->a0 = syscalls[num]();
    80002e7e:	9782                	jalr	a5
    80002e80:	06a9b823          	sd	a0,112(s3)
    syscall_counts[num]++; // Increment the count for this syscall
    80002e84:	090e                	slli	s2,s2,0x3
    80002e86:	0001a797          	auipc	a5,0x1a
    80002e8a:	53278793          	addi	a5,a5,1330 # 8001d3b8 <syscall_counts>
    80002e8e:	97ca                	add	a5,a5,s2
    80002e90:	6398                	ld	a4,0(a5)
    80002e92:	0705                	addi	a4,a4,1
    80002e94:	e398                	sd	a4,0(a5)
    80002e96:	a005                	j	80002eb6 <syscall+0x76>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002e98:	86ca                	mv	a3,s2
    80002e9a:	15848613          	addi	a2,s1,344
    80002e9e:	588c                	lw	a1,48(s1)
    80002ea0:	00005517          	auipc	a0,0x5
    80002ea4:	54050513          	addi	a0,a0,1344 # 800083e0 <etext+0x3e0>
    80002ea8:	ffffd097          	auipc	ra,0xffffd
    80002eac:	702080e7          	jalr	1794(ra) # 800005aa <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002eb0:	6cbc                	ld	a5,88(s1)
    80002eb2:	577d                	li	a4,-1
    80002eb4:	fbb8                	sd	a4,112(a5)
  }
}
    80002eb6:	70a2                	ld	ra,40(sp)
    80002eb8:	7402                	ld	s0,32(sp)
    80002eba:	64e2                	ld	s1,24(sp)
    80002ebc:	6942                	ld	s2,16(sp)
    80002ebe:	69a2                	ld	s3,8(sp)
    80002ec0:	6145                	addi	sp,sp,48
    80002ec2:	8082                	ret

0000000080002ec4 <sys_exit>:

extern uint64 syscall_counts[];

uint64
sys_exit(void)
{
    80002ec4:	1101                	addi	sp,sp,-32
    80002ec6:	ec06                	sd	ra,24(sp)
    80002ec8:	e822                	sd	s0,16(sp)
    80002eca:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ecc:	fec40593          	addi	a1,s0,-20
    80002ed0:	4501                	li	a0,0
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	ef6080e7          	jalr	-266(ra) # 80002dc8 <argint>
  exit(n);
    80002eda:	fec42503          	lw	a0,-20(s0)
    80002ede:	fffff097          	auipc	ra,0xfffff
    80002ee2:	37c080e7          	jalr	892(ra) # 8000225a <exit>
  return 0; // not reached
}
    80002ee6:	4501                	li	a0,0
    80002ee8:	60e2                	ld	ra,24(sp)
    80002eea:	6442                	ld	s0,16(sp)
    80002eec:	6105                	addi	sp,sp,32
    80002eee:	8082                	ret

0000000080002ef0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ef0:	1141                	addi	sp,sp,-16
    80002ef2:	e406                	sd	ra,8(sp)
    80002ef4:	e022                	sd	s0,0(sp)
    80002ef6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ef8:	fffff097          	auipc	ra,0xfffff
    80002efc:	b4a080e7          	jalr	-1206(ra) # 80001a42 <myproc>
}
    80002f00:	5908                	lw	a0,48(a0)
    80002f02:	60a2                	ld	ra,8(sp)
    80002f04:	6402                	ld	s0,0(sp)
    80002f06:	0141                	addi	sp,sp,16
    80002f08:	8082                	ret

0000000080002f0a <sys_fork>:

uint64
sys_fork(void)
{
    80002f0a:	1141                	addi	sp,sp,-16
    80002f0c:	e406                	sd	ra,8(sp)
    80002f0e:	e022                	sd	s0,0(sp)
    80002f10:	0800                	addi	s0,sp,16
  return fork();
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	f0c080e7          	jalr	-244(ra) # 80001e1e <fork>
}
    80002f1a:	60a2                	ld	ra,8(sp)
    80002f1c:	6402                	ld	s0,0(sp)
    80002f1e:	0141                	addi	sp,sp,16
    80002f20:	8082                	ret

0000000080002f22 <sys_wait>:

uint64
sys_wait(void)
{
    80002f22:	1101                	addi	sp,sp,-32
    80002f24:	ec06                	sd	ra,24(sp)
    80002f26:	e822                	sd	s0,16(sp)
    80002f28:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f2a:	fe840593          	addi	a1,s0,-24
    80002f2e:	4501                	li	a0,0
    80002f30:	00000097          	auipc	ra,0x0
    80002f34:	eb8080e7          	jalr	-328(ra) # 80002de8 <argaddr>
  return wait(p);
    80002f38:	fe843503          	ld	a0,-24(s0)
    80002f3c:	fffff097          	auipc	ra,0xfffff
    80002f40:	4d0080e7          	jalr	1232(ra) # 8000240c <wait>
}
    80002f44:	60e2                	ld	ra,24(sp)
    80002f46:	6442                	ld	s0,16(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret

0000000080002f4c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f4c:	7179                	addi	sp,sp,-48
    80002f4e:	f406                	sd	ra,40(sp)
    80002f50:	f022                	sd	s0,32(sp)
    80002f52:	ec26                	sd	s1,24(sp)
    80002f54:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f56:	fdc40593          	addi	a1,s0,-36
    80002f5a:	4501                	li	a0,0
    80002f5c:	00000097          	auipc	ra,0x0
    80002f60:	e6c080e7          	jalr	-404(ra) # 80002dc8 <argint>
  addr = myproc()->sz;
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	ade080e7          	jalr	-1314(ra) # 80001a42 <myproc>
    80002f6c:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002f6e:	fdc42503          	lw	a0,-36(s0)
    80002f72:	fffff097          	auipc	ra,0xfffff
    80002f76:	e50080e7          	jalr	-432(ra) # 80001dc2 <growproc>
    80002f7a:	00054863          	bltz	a0,80002f8a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f7e:	8526                	mv	a0,s1
    80002f80:	70a2                	ld	ra,40(sp)
    80002f82:	7402                	ld	s0,32(sp)
    80002f84:	64e2                	ld	s1,24(sp)
    80002f86:	6145                	addi	sp,sp,48
    80002f88:	8082                	ret
    return -1;
    80002f8a:	54fd                	li	s1,-1
    80002f8c:	bfcd                	j	80002f7e <sys_sbrk+0x32>

0000000080002f8e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f8e:	7139                	addi	sp,sp,-64
    80002f90:	fc06                	sd	ra,56(sp)
    80002f92:	f822                	sd	s0,48(sp)
    80002f94:	f04a                	sd	s2,32(sp)
    80002f96:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f98:	fcc40593          	addi	a1,s0,-52
    80002f9c:	4501                	li	a0,0
    80002f9e:	00000097          	auipc	ra,0x0
    80002fa2:	e2a080e7          	jalr	-470(ra) # 80002dc8 <argint>
  acquire(&tickslock);
    80002fa6:	0001a517          	auipc	a0,0x1a
    80002faa:	3fa50513          	addi	a0,a0,1018 # 8001d3a0 <tickslock>
    80002fae:	ffffe097          	auipc	ra,0xffffe
    80002fb2:	c8a080e7          	jalr	-886(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80002fb6:	00008917          	auipc	s2,0x8
    80002fba:	34a92903          	lw	s2,842(s2) # 8000b300 <ticks>
  while (ticks - ticks0 < n)
    80002fbe:	fcc42783          	lw	a5,-52(s0)
    80002fc2:	c3b9                	beqz	a5,80003008 <sys_sleep+0x7a>
    80002fc4:	f426                	sd	s1,40(sp)
    80002fc6:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fc8:	0001a997          	auipc	s3,0x1a
    80002fcc:	3d898993          	addi	s3,s3,984 # 8001d3a0 <tickslock>
    80002fd0:	00008497          	auipc	s1,0x8
    80002fd4:	33048493          	addi	s1,s1,816 # 8000b300 <ticks>
    if (killed(myproc()))
    80002fd8:	fffff097          	auipc	ra,0xfffff
    80002fdc:	a6a080e7          	jalr	-1430(ra) # 80001a42 <myproc>
    80002fe0:	fffff097          	auipc	ra,0xfffff
    80002fe4:	3fa080e7          	jalr	1018(ra) # 800023da <killed>
    80002fe8:	ed15                	bnez	a0,80003024 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fea:	85ce                	mv	a1,s3
    80002fec:	8526                	mv	a0,s1
    80002fee:	fffff097          	auipc	ra,0xfffff
    80002ff2:	138080e7          	jalr	312(ra) # 80002126 <sleep>
  while (ticks - ticks0 < n)
    80002ff6:	409c                	lw	a5,0(s1)
    80002ff8:	412787bb          	subw	a5,a5,s2
    80002ffc:	fcc42703          	lw	a4,-52(s0)
    80003000:	fce7ece3          	bltu	a5,a4,80002fd8 <sys_sleep+0x4a>
    80003004:	74a2                	ld	s1,40(sp)
    80003006:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003008:	0001a517          	auipc	a0,0x1a
    8000300c:	39850513          	addi	a0,a0,920 # 8001d3a0 <tickslock>
    80003010:	ffffe097          	auipc	ra,0xffffe
    80003014:	cdc080e7          	jalr	-804(ra) # 80000cec <release>
  return 0;
    80003018:	4501                	li	a0,0
}
    8000301a:	70e2                	ld	ra,56(sp)
    8000301c:	7442                	ld	s0,48(sp)
    8000301e:	7902                	ld	s2,32(sp)
    80003020:	6121                	addi	sp,sp,64
    80003022:	8082                	ret
      release(&tickslock);
    80003024:	0001a517          	auipc	a0,0x1a
    80003028:	37c50513          	addi	a0,a0,892 # 8001d3a0 <tickslock>
    8000302c:	ffffe097          	auipc	ra,0xffffe
    80003030:	cc0080e7          	jalr	-832(ra) # 80000cec <release>
      return -1;
    80003034:	557d                	li	a0,-1
    80003036:	74a2                	ld	s1,40(sp)
    80003038:	69e2                	ld	s3,24(sp)
    8000303a:	b7c5                	j	8000301a <sys_sleep+0x8c>

000000008000303c <sys_kill>:

uint64
sys_kill(void)
{
    8000303c:	1101                	addi	sp,sp,-32
    8000303e:	ec06                	sd	ra,24(sp)
    80003040:	e822                	sd	s0,16(sp)
    80003042:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003044:	fec40593          	addi	a1,s0,-20
    80003048:	4501                	li	a0,0
    8000304a:	00000097          	auipc	ra,0x0
    8000304e:	d7e080e7          	jalr	-642(ra) # 80002dc8 <argint>
  return kill(pid);
    80003052:	fec42503          	lw	a0,-20(s0)
    80003056:	fffff097          	auipc	ra,0xfffff
    8000305a:	2e6080e7          	jalr	742(ra) # 8000233c <kill>
}
    8000305e:	60e2                	ld	ra,24(sp)
    80003060:	6442                	ld	s0,16(sp)
    80003062:	6105                	addi	sp,sp,32
    80003064:	8082                	ret

0000000080003066 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003066:	1101                	addi	sp,sp,-32
    80003068:	ec06                	sd	ra,24(sp)
    8000306a:	e822                	sd	s0,16(sp)
    8000306c:	e426                	sd	s1,8(sp)
    8000306e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003070:	0001a517          	auipc	a0,0x1a
    80003074:	33050513          	addi	a0,a0,816 # 8001d3a0 <tickslock>
    80003078:	ffffe097          	auipc	ra,0xffffe
    8000307c:	bc0080e7          	jalr	-1088(ra) # 80000c38 <acquire>
  xticks = ticks;
    80003080:	00008497          	auipc	s1,0x8
    80003084:	2804a483          	lw	s1,640(s1) # 8000b300 <ticks>
  release(&tickslock);
    80003088:	0001a517          	auipc	a0,0x1a
    8000308c:	31850513          	addi	a0,a0,792 # 8001d3a0 <tickslock>
    80003090:	ffffe097          	auipc	ra,0xffffe
    80003094:	c5c080e7          	jalr	-932(ra) # 80000cec <release>
  return xticks;
}
    80003098:	02049513          	slli	a0,s1,0x20
    8000309c:	9101                	srli	a0,a0,0x20
    8000309e:	60e2                	ld	ra,24(sp)
    800030a0:	6442                	ld	s0,16(sp)
    800030a2:	64a2                	ld	s1,8(sp)
    800030a4:	6105                	addi	sp,sp,32
    800030a6:	8082                	ret

00000000800030a8 <sys_waitx>:

uint64
sys_waitx(void)
{
    800030a8:	7139                	addi	sp,sp,-64
    800030aa:	fc06                	sd	ra,56(sp)
    800030ac:	f822                	sd	s0,48(sp)
    800030ae:	f426                	sd	s1,40(sp)
    800030b0:	f04a                	sd	s2,32(sp)
    800030b2:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800030b4:	fd840593          	addi	a1,s0,-40
    800030b8:	4501                	li	a0,0
    800030ba:	00000097          	auipc	ra,0x0
    800030be:	d2e080e7          	jalr	-722(ra) # 80002de8 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800030c2:	fd040593          	addi	a1,s0,-48
    800030c6:	4505                	li	a0,1
    800030c8:	00000097          	auipc	ra,0x0
    800030cc:	d20080e7          	jalr	-736(ra) # 80002de8 <argaddr>
  argaddr(2, &addr2);
    800030d0:	fc840593          	addi	a1,s0,-56
    800030d4:	4509                	li	a0,2
    800030d6:	00000097          	auipc	ra,0x0
    800030da:	d12080e7          	jalr	-750(ra) # 80002de8 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800030de:	fc040613          	addi	a2,s0,-64
    800030e2:	fc440593          	addi	a1,s0,-60
    800030e6:	fd843503          	ld	a0,-40(s0)
    800030ea:	fffff097          	auipc	ra,0xfffff
    800030ee:	5ac080e7          	jalr	1452(ra) # 80002696 <waitx>
    800030f2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	94e080e7          	jalr	-1714(ra) # 80001a42 <myproc>
    800030fc:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030fe:	4691                	li	a3,4
    80003100:	fc440613          	addi	a2,s0,-60
    80003104:	fd043583          	ld	a1,-48(s0)
    80003108:	6928                	ld	a0,80(a0)
    8000310a:	ffffe097          	auipc	ra,0xffffe
    8000310e:	5d8080e7          	jalr	1496(ra) # 800016e2 <copyout>
    return -1;
    80003112:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003114:	00054f63          	bltz	a0,80003132 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003118:	4691                	li	a3,4
    8000311a:	fc040613          	addi	a2,s0,-64
    8000311e:	fc843583          	ld	a1,-56(s0)
    80003122:	68a8                	ld	a0,80(s1)
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	5be080e7          	jalr	1470(ra) # 800016e2 <copyout>
    8000312c:	00054a63          	bltz	a0,80003140 <sys_waitx+0x98>
    return -1;
  return ret;
    80003130:	87ca                	mv	a5,s2
}
    80003132:	853e                	mv	a0,a5
    80003134:	70e2                	ld	ra,56(sp)
    80003136:	7442                	ld	s0,48(sp)
    80003138:	74a2                	ld	s1,40(sp)
    8000313a:	7902                	ld	s2,32(sp)
    8000313c:	6121                	addi	sp,sp,64
    8000313e:	8082                	ret
    return -1;
    80003140:	57fd                	li	a5,-1
    80003142:	bfc5                	j	80003132 <sys_waitx+0x8a>

0000000080003144 <sys_getsyscount>:

uint64
sys_getsyscount(void)
{
    80003144:	1101                	addi	sp,sp,-32
    80003146:	ec06                	sd	ra,24(sp)
    80003148:	e822                	sd	s0,16(sp)
    8000314a:	1000                	addi	s0,sp,32
  int mask;
  argint(0, &mask); // argint is a void function, it directly sets the value of mask
    8000314c:	fec40593          	addi	a1,s0,-20
    80003150:	4501                	li	a0,0
    80003152:	00000097          	auipc	ra,0x0
    80003156:	c76080e7          	jalr	-906(ra) # 80002dc8 <argint>

  // Find the syscall number from the mask
  int syscall_num = -1;
  for (int i = 1; i < NSYSCALLS; i++)
  {
    if (mask == (1 << i))
    8000315a:	fec42603          	lw	a2,-20(s0)
  for (int i = 1; i < NSYSCALLS; i++)
    8000315e:	4785                	li	a5,1
    if (mask == (1 << i))
    80003160:	4685                	li	a3,1
  for (int i = 1; i < NSYSCALLS; i++)
    80003162:	45e9                	li	a1,26
    if (mask == (1 << i))
    80003164:	00f6973b          	sllw	a4,a3,a5
    80003168:	00c70763          	beq	a4,a2,80003176 <sys_getsyscount+0x32>
  for (int i = 1; i < NSYSCALLS; i++)
    8000316c:	2785                	addiw	a5,a5,1
    8000316e:	feb79be3          	bne	a5,a1,80003164 <sys_getsyscount+0x20>
      break;
    }
  }

  if (syscall_num == -1 || syscall_num >= NSYSCALLS)
    return -1;
    80003172:	557d                	li	a0,-1
    80003174:	a829                	j	8000318e <sys_getsyscount+0x4a>
  if (syscall_num == -1 || syscall_num >= NSYSCALLS)
    80003176:	577d                	li	a4,-1
    80003178:	00e78f63          	beq	a5,a4,80003196 <sys_getsyscount+0x52>

  uint64 count = syscall_counts[syscall_num];
    8000317c:	078e                	slli	a5,a5,0x3
    8000317e:	0001a717          	auipc	a4,0x1a
    80003182:	23a70713          	addi	a4,a4,570 # 8001d3b8 <syscall_counts>
    80003186:	97ba                	add	a5,a5,a4
    80003188:	6388                	ld	a0,0(a5)
  syscall_counts[syscall_num] = 0; // Reset the count after reading
    8000318a:	0007b023          	sd	zero,0(a5)
  return count;
}
    8000318e:	60e2                	ld	ra,24(sp)
    80003190:	6442                	ld	s0,16(sp)
    80003192:	6105                	addi	sp,sp,32
    80003194:	8082                	ret
    return -1;
    80003196:	557d                	li	a0,-1
    80003198:	bfdd                	j	8000318e <sys_getsyscount+0x4a>

000000008000319a <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	1000                	addi	s0,sp,32
  int interval;
  uint64 handler;

  argint(0, &interval);
    800031a2:	fec40593          	addi	a1,s0,-20
    800031a6:	4501                	li	a0,0
    800031a8:	00000097          	auipc	ra,0x0
    800031ac:	c20080e7          	jalr	-992(ra) # 80002dc8 <argint>
  argaddr(1, &handler);
    800031b0:	fe040593          	addi	a1,s0,-32
    800031b4:	4505                	li	a0,1
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	c32080e7          	jalr	-974(ra) # 80002de8 <argaddr>

  struct proc *p = myproc();
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	884080e7          	jalr	-1916(ra) # 80001a42 <myproc>
  p->alarm_interval = interval;
    800031c6:	fec42783          	lw	a5,-20(s0)
    800031ca:	24f52423          	sw	a5,584(a0)
  p->alarm_handler = (void (*)())handler;
    800031ce:	fe043783          	ld	a5,-32(s0)
    800031d2:	24f53823          	sd	a5,592(a0)
  p->ticks_count = 0;
    800031d6:	24052c23          	sw	zero,600(a0)
  p->alarm_active = 0;
    800031da:	24052e23          	sw	zero,604(a0)

  return 0;
}
    800031de:	4501                	li	a0,0
    800031e0:	60e2                	ld	ra,24(sp)
    800031e2:	6442                	ld	s0,16(sp)
    800031e4:	6105                	addi	sp,sp,32
    800031e6:	8082                	ret

00000000800031e8 <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    800031e8:	1101                	addi	sp,sp,-32
    800031ea:	ec06                	sd	ra,24(sp)
    800031ec:	e822                	sd	s0,16(sp)
    800031ee:	e426                	sd	s1,8(sp)
    800031f0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800031f2:	fffff097          	auipc	ra,0xfffff
    800031f6:	850080e7          	jalr	-1968(ra) # 80001a42 <myproc>
    800031fa:	84aa                	mv	s1,a0
  if (p->alarm_tf)
    800031fc:	26053583          	ld	a1,608(a0)
    80003200:	c195                	beqz	a1,80003224 <sys_sigreturn+0x3c>
  {
    memmove(p->trapframe, p->alarm_tf, sizeof(struct trapframe));
    80003202:	12000613          	li	a2,288
    80003206:	6d28                	ld	a0,88(a0)
    80003208:	ffffe097          	auipc	ra,0xffffe
    8000320c:	b88080e7          	jalr	-1144(ra) # 80000d90 <memmove>
    kfree(p->alarm_tf);
    80003210:	2604b503          	ld	a0,608(s1)
    80003214:	ffffe097          	auipc	ra,0xffffe
    80003218:	836080e7          	jalr	-1994(ra) # 80000a4a <kfree>
    p->alarm_tf = 0;
    8000321c:	2604b023          	sd	zero,608(s1)
    p->alarm_active = 0;
    80003220:	2404ae23          	sw	zero,604(s1)
  }
  return p->trapframe->a0;
    80003224:	6cbc                	ld	a5,88(s1)
}
    80003226:	7ba8                	ld	a0,112(a5)
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	64a2                	ld	s1,8(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret

0000000080003232 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003232:	7179                	addi	sp,sp,-48
    80003234:	f406                	sd	ra,40(sp)
    80003236:	f022                	sd	s0,32(sp)
    80003238:	ec26                	sd	s1,24(sp)
    8000323a:	e84a                	sd	s2,16(sp)
    8000323c:	e44e                	sd	s3,8(sp)
    8000323e:	e052                	sd	s4,0(sp)
    80003240:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003242:	00005597          	auipc	a1,0x5
    80003246:	1be58593          	addi	a1,a1,446 # 80008400 <etext+0x400>
    8000324a:	0001a517          	auipc	a0,0x1a
    8000324e:	23e50513          	addi	a0,a0,574 # 8001d488 <bcache>
    80003252:	ffffe097          	auipc	ra,0xffffe
    80003256:	956080e7          	jalr	-1706(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000325a:	00022797          	auipc	a5,0x22
    8000325e:	22e78793          	addi	a5,a5,558 # 80025488 <bcache+0x8000>
    80003262:	00022717          	auipc	a4,0x22
    80003266:	48e70713          	addi	a4,a4,1166 # 800256f0 <bcache+0x8268>
    8000326a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000326e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003272:	0001a497          	auipc	s1,0x1a
    80003276:	22e48493          	addi	s1,s1,558 # 8001d4a0 <bcache+0x18>
    b->next = bcache.head.next;
    8000327a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000327c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000327e:	00005a17          	auipc	s4,0x5
    80003282:	18aa0a13          	addi	s4,s4,394 # 80008408 <etext+0x408>
    b->next = bcache.head.next;
    80003286:	2b893783          	ld	a5,696(s2)
    8000328a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000328c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003290:	85d2                	mv	a1,s4
    80003292:	01048513          	addi	a0,s1,16
    80003296:	00001097          	auipc	ra,0x1
    8000329a:	4e8080e7          	jalr	1256(ra) # 8000477e <initsleeplock>
    bcache.head.next->prev = b;
    8000329e:	2b893783          	ld	a5,696(s2)
    800032a2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032a4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032a8:	45848493          	addi	s1,s1,1112
    800032ac:	fd349de3          	bne	s1,s3,80003286 <binit+0x54>
  }
}
    800032b0:	70a2                	ld	ra,40(sp)
    800032b2:	7402                	ld	s0,32(sp)
    800032b4:	64e2                	ld	s1,24(sp)
    800032b6:	6942                	ld	s2,16(sp)
    800032b8:	69a2                	ld	s3,8(sp)
    800032ba:	6a02                	ld	s4,0(sp)
    800032bc:	6145                	addi	sp,sp,48
    800032be:	8082                	ret

00000000800032c0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032c0:	7179                	addi	sp,sp,-48
    800032c2:	f406                	sd	ra,40(sp)
    800032c4:	f022                	sd	s0,32(sp)
    800032c6:	ec26                	sd	s1,24(sp)
    800032c8:	e84a                	sd	s2,16(sp)
    800032ca:	e44e                	sd	s3,8(sp)
    800032cc:	1800                	addi	s0,sp,48
    800032ce:	892a                	mv	s2,a0
    800032d0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800032d2:	0001a517          	auipc	a0,0x1a
    800032d6:	1b650513          	addi	a0,a0,438 # 8001d488 <bcache>
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	95e080e7          	jalr	-1698(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032e2:	00022497          	auipc	s1,0x22
    800032e6:	45e4b483          	ld	s1,1118(s1) # 80025740 <bcache+0x82b8>
    800032ea:	00022797          	auipc	a5,0x22
    800032ee:	40678793          	addi	a5,a5,1030 # 800256f0 <bcache+0x8268>
    800032f2:	02f48f63          	beq	s1,a5,80003330 <bread+0x70>
    800032f6:	873e                	mv	a4,a5
    800032f8:	a021                	j	80003300 <bread+0x40>
    800032fa:	68a4                	ld	s1,80(s1)
    800032fc:	02e48a63          	beq	s1,a4,80003330 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003300:	449c                	lw	a5,8(s1)
    80003302:	ff279ce3          	bne	a5,s2,800032fa <bread+0x3a>
    80003306:	44dc                	lw	a5,12(s1)
    80003308:	ff3799e3          	bne	a5,s3,800032fa <bread+0x3a>
      b->refcnt++;
    8000330c:	40bc                	lw	a5,64(s1)
    8000330e:	2785                	addiw	a5,a5,1
    80003310:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003312:	0001a517          	auipc	a0,0x1a
    80003316:	17650513          	addi	a0,a0,374 # 8001d488 <bcache>
    8000331a:	ffffe097          	auipc	ra,0xffffe
    8000331e:	9d2080e7          	jalr	-1582(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003322:	01048513          	addi	a0,s1,16
    80003326:	00001097          	auipc	ra,0x1
    8000332a:	492080e7          	jalr	1170(ra) # 800047b8 <acquiresleep>
      return b;
    8000332e:	a8b9                	j	8000338c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003330:	00022497          	auipc	s1,0x22
    80003334:	4084b483          	ld	s1,1032(s1) # 80025738 <bcache+0x82b0>
    80003338:	00022797          	auipc	a5,0x22
    8000333c:	3b878793          	addi	a5,a5,952 # 800256f0 <bcache+0x8268>
    80003340:	00f48863          	beq	s1,a5,80003350 <bread+0x90>
    80003344:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003346:	40bc                	lw	a5,64(s1)
    80003348:	cf81                	beqz	a5,80003360 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000334a:	64a4                	ld	s1,72(s1)
    8000334c:	fee49de3          	bne	s1,a4,80003346 <bread+0x86>
  panic("bget: no buffers");
    80003350:	00005517          	auipc	a0,0x5
    80003354:	0c050513          	addi	a0,a0,192 # 80008410 <etext+0x410>
    80003358:	ffffd097          	auipc	ra,0xffffd
    8000335c:	208080e7          	jalr	520(ra) # 80000560 <panic>
      b->dev = dev;
    80003360:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003364:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003368:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000336c:	4785                	li	a5,1
    8000336e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003370:	0001a517          	auipc	a0,0x1a
    80003374:	11850513          	addi	a0,a0,280 # 8001d488 <bcache>
    80003378:	ffffe097          	auipc	ra,0xffffe
    8000337c:	974080e7          	jalr	-1676(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003380:	01048513          	addi	a0,s1,16
    80003384:	00001097          	auipc	ra,0x1
    80003388:	434080e7          	jalr	1076(ra) # 800047b8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000338c:	409c                	lw	a5,0(s1)
    8000338e:	cb89                	beqz	a5,800033a0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003390:	8526                	mv	a0,s1
    80003392:	70a2                	ld	ra,40(sp)
    80003394:	7402                	ld	s0,32(sp)
    80003396:	64e2                	ld	s1,24(sp)
    80003398:	6942                	ld	s2,16(sp)
    8000339a:	69a2                	ld	s3,8(sp)
    8000339c:	6145                	addi	sp,sp,48
    8000339e:	8082                	ret
    virtio_disk_rw(b, 0);
    800033a0:	4581                	li	a1,0
    800033a2:	8526                	mv	a0,s1
    800033a4:	00003097          	auipc	ra,0x3
    800033a8:	0f4080e7          	jalr	244(ra) # 80006498 <virtio_disk_rw>
    b->valid = 1;
    800033ac:	4785                	li	a5,1
    800033ae:	c09c                	sw	a5,0(s1)
  return b;
    800033b0:	b7c5                	j	80003390 <bread+0xd0>

00000000800033b2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033b2:	1101                	addi	sp,sp,-32
    800033b4:	ec06                	sd	ra,24(sp)
    800033b6:	e822                	sd	s0,16(sp)
    800033b8:	e426                	sd	s1,8(sp)
    800033ba:	1000                	addi	s0,sp,32
    800033bc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033be:	0541                	addi	a0,a0,16
    800033c0:	00001097          	auipc	ra,0x1
    800033c4:	492080e7          	jalr	1170(ra) # 80004852 <holdingsleep>
    800033c8:	cd01                	beqz	a0,800033e0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033ca:	4585                	li	a1,1
    800033cc:	8526                	mv	a0,s1
    800033ce:	00003097          	auipc	ra,0x3
    800033d2:	0ca080e7          	jalr	202(ra) # 80006498 <virtio_disk_rw>
}
    800033d6:	60e2                	ld	ra,24(sp)
    800033d8:	6442                	ld	s0,16(sp)
    800033da:	64a2                	ld	s1,8(sp)
    800033dc:	6105                	addi	sp,sp,32
    800033de:	8082                	ret
    panic("bwrite");
    800033e0:	00005517          	auipc	a0,0x5
    800033e4:	04850513          	addi	a0,a0,72 # 80008428 <etext+0x428>
    800033e8:	ffffd097          	auipc	ra,0xffffd
    800033ec:	178080e7          	jalr	376(ra) # 80000560 <panic>

00000000800033f0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033f0:	1101                	addi	sp,sp,-32
    800033f2:	ec06                	sd	ra,24(sp)
    800033f4:	e822                	sd	s0,16(sp)
    800033f6:	e426                	sd	s1,8(sp)
    800033f8:	e04a                	sd	s2,0(sp)
    800033fa:	1000                	addi	s0,sp,32
    800033fc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033fe:	01050913          	addi	s2,a0,16
    80003402:	854a                	mv	a0,s2
    80003404:	00001097          	auipc	ra,0x1
    80003408:	44e080e7          	jalr	1102(ra) # 80004852 <holdingsleep>
    8000340c:	c925                	beqz	a0,8000347c <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    8000340e:	854a                	mv	a0,s2
    80003410:	00001097          	auipc	ra,0x1
    80003414:	3fe080e7          	jalr	1022(ra) # 8000480e <releasesleep>

  acquire(&bcache.lock);
    80003418:	0001a517          	auipc	a0,0x1a
    8000341c:	07050513          	addi	a0,a0,112 # 8001d488 <bcache>
    80003420:	ffffe097          	auipc	ra,0xffffe
    80003424:	818080e7          	jalr	-2024(ra) # 80000c38 <acquire>
  b->refcnt--;
    80003428:	40bc                	lw	a5,64(s1)
    8000342a:	37fd                	addiw	a5,a5,-1
    8000342c:	0007871b          	sext.w	a4,a5
    80003430:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003432:	e71d                	bnez	a4,80003460 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003434:	68b8                	ld	a4,80(s1)
    80003436:	64bc                	ld	a5,72(s1)
    80003438:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000343a:	68b8                	ld	a4,80(s1)
    8000343c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000343e:	00022797          	auipc	a5,0x22
    80003442:	04a78793          	addi	a5,a5,74 # 80025488 <bcache+0x8000>
    80003446:	2b87b703          	ld	a4,696(a5)
    8000344a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000344c:	00022717          	auipc	a4,0x22
    80003450:	2a470713          	addi	a4,a4,676 # 800256f0 <bcache+0x8268>
    80003454:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003456:	2b87b703          	ld	a4,696(a5)
    8000345a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000345c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003460:	0001a517          	auipc	a0,0x1a
    80003464:	02850513          	addi	a0,a0,40 # 8001d488 <bcache>
    80003468:	ffffe097          	auipc	ra,0xffffe
    8000346c:	884080e7          	jalr	-1916(ra) # 80000cec <release>
}
    80003470:	60e2                	ld	ra,24(sp)
    80003472:	6442                	ld	s0,16(sp)
    80003474:	64a2                	ld	s1,8(sp)
    80003476:	6902                	ld	s2,0(sp)
    80003478:	6105                	addi	sp,sp,32
    8000347a:	8082                	ret
    panic("brelse");
    8000347c:	00005517          	auipc	a0,0x5
    80003480:	fb450513          	addi	a0,a0,-76 # 80008430 <etext+0x430>
    80003484:	ffffd097          	auipc	ra,0xffffd
    80003488:	0dc080e7          	jalr	220(ra) # 80000560 <panic>

000000008000348c <bpin>:

void
bpin(struct buf *b) {
    8000348c:	1101                	addi	sp,sp,-32
    8000348e:	ec06                	sd	ra,24(sp)
    80003490:	e822                	sd	s0,16(sp)
    80003492:	e426                	sd	s1,8(sp)
    80003494:	1000                	addi	s0,sp,32
    80003496:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003498:	0001a517          	auipc	a0,0x1a
    8000349c:	ff050513          	addi	a0,a0,-16 # 8001d488 <bcache>
    800034a0:	ffffd097          	auipc	ra,0xffffd
    800034a4:	798080e7          	jalr	1944(ra) # 80000c38 <acquire>
  b->refcnt++;
    800034a8:	40bc                	lw	a5,64(s1)
    800034aa:	2785                	addiw	a5,a5,1
    800034ac:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034ae:	0001a517          	auipc	a0,0x1a
    800034b2:	fda50513          	addi	a0,a0,-38 # 8001d488 <bcache>
    800034b6:	ffffe097          	auipc	ra,0xffffe
    800034ba:	836080e7          	jalr	-1994(ra) # 80000cec <release>
}
    800034be:	60e2                	ld	ra,24(sp)
    800034c0:	6442                	ld	s0,16(sp)
    800034c2:	64a2                	ld	s1,8(sp)
    800034c4:	6105                	addi	sp,sp,32
    800034c6:	8082                	ret

00000000800034c8 <bunpin>:

void
bunpin(struct buf *b) {
    800034c8:	1101                	addi	sp,sp,-32
    800034ca:	ec06                	sd	ra,24(sp)
    800034cc:	e822                	sd	s0,16(sp)
    800034ce:	e426                	sd	s1,8(sp)
    800034d0:	1000                	addi	s0,sp,32
    800034d2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034d4:	0001a517          	auipc	a0,0x1a
    800034d8:	fb450513          	addi	a0,a0,-76 # 8001d488 <bcache>
    800034dc:	ffffd097          	auipc	ra,0xffffd
    800034e0:	75c080e7          	jalr	1884(ra) # 80000c38 <acquire>
  b->refcnt--;
    800034e4:	40bc                	lw	a5,64(s1)
    800034e6:	37fd                	addiw	a5,a5,-1
    800034e8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034ea:	0001a517          	auipc	a0,0x1a
    800034ee:	f9e50513          	addi	a0,a0,-98 # 8001d488 <bcache>
    800034f2:	ffffd097          	auipc	ra,0xffffd
    800034f6:	7fa080e7          	jalr	2042(ra) # 80000cec <release>
}
    800034fa:	60e2                	ld	ra,24(sp)
    800034fc:	6442                	ld	s0,16(sp)
    800034fe:	64a2                	ld	s1,8(sp)
    80003500:	6105                	addi	sp,sp,32
    80003502:	8082                	ret

0000000080003504 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003504:	1101                	addi	sp,sp,-32
    80003506:	ec06                	sd	ra,24(sp)
    80003508:	e822                	sd	s0,16(sp)
    8000350a:	e426                	sd	s1,8(sp)
    8000350c:	e04a                	sd	s2,0(sp)
    8000350e:	1000                	addi	s0,sp,32
    80003510:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003512:	00d5d59b          	srliw	a1,a1,0xd
    80003516:	00022797          	auipc	a5,0x22
    8000351a:	64e7a783          	lw	a5,1614(a5) # 80025b64 <sb+0x1c>
    8000351e:	9dbd                	addw	a1,a1,a5
    80003520:	00000097          	auipc	ra,0x0
    80003524:	da0080e7          	jalr	-608(ra) # 800032c0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003528:	0074f713          	andi	a4,s1,7
    8000352c:	4785                	li	a5,1
    8000352e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003532:	14ce                	slli	s1,s1,0x33
    80003534:	90d9                	srli	s1,s1,0x36
    80003536:	00950733          	add	a4,a0,s1
    8000353a:	05874703          	lbu	a4,88(a4)
    8000353e:	00e7f6b3          	and	a3,a5,a4
    80003542:	c69d                	beqz	a3,80003570 <bfree+0x6c>
    80003544:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003546:	94aa                	add	s1,s1,a0
    80003548:	fff7c793          	not	a5,a5
    8000354c:	8f7d                	and	a4,a4,a5
    8000354e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003552:	00001097          	auipc	ra,0x1
    80003556:	148080e7          	jalr	328(ra) # 8000469a <log_write>
  brelse(bp);
    8000355a:	854a                	mv	a0,s2
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	e94080e7          	jalr	-364(ra) # 800033f0 <brelse>
}
    80003564:	60e2                	ld	ra,24(sp)
    80003566:	6442                	ld	s0,16(sp)
    80003568:	64a2                	ld	s1,8(sp)
    8000356a:	6902                	ld	s2,0(sp)
    8000356c:	6105                	addi	sp,sp,32
    8000356e:	8082                	ret
    panic("freeing free block");
    80003570:	00005517          	auipc	a0,0x5
    80003574:	ec850513          	addi	a0,a0,-312 # 80008438 <etext+0x438>
    80003578:	ffffd097          	auipc	ra,0xffffd
    8000357c:	fe8080e7          	jalr	-24(ra) # 80000560 <panic>

0000000080003580 <balloc>:
{
    80003580:	711d                	addi	sp,sp,-96
    80003582:	ec86                	sd	ra,88(sp)
    80003584:	e8a2                	sd	s0,80(sp)
    80003586:	e4a6                	sd	s1,72(sp)
    80003588:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000358a:	00022797          	auipc	a5,0x22
    8000358e:	5c27a783          	lw	a5,1474(a5) # 80025b4c <sb+0x4>
    80003592:	10078f63          	beqz	a5,800036b0 <balloc+0x130>
    80003596:	e0ca                	sd	s2,64(sp)
    80003598:	fc4e                	sd	s3,56(sp)
    8000359a:	f852                	sd	s4,48(sp)
    8000359c:	f456                	sd	s5,40(sp)
    8000359e:	f05a                	sd	s6,32(sp)
    800035a0:	ec5e                	sd	s7,24(sp)
    800035a2:	e862                	sd	s8,16(sp)
    800035a4:	e466                	sd	s9,8(sp)
    800035a6:	8baa                	mv	s7,a0
    800035a8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035aa:	00022b17          	auipc	s6,0x22
    800035ae:	59eb0b13          	addi	s6,s6,1438 # 80025b48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035b2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035b4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035b6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035b8:	6c89                	lui	s9,0x2
    800035ba:	a061                	j	80003642 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035bc:	97ca                	add	a5,a5,s2
    800035be:	8e55                	or	a2,a2,a3
    800035c0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035c4:	854a                	mv	a0,s2
    800035c6:	00001097          	auipc	ra,0x1
    800035ca:	0d4080e7          	jalr	212(ra) # 8000469a <log_write>
        brelse(bp);
    800035ce:	854a                	mv	a0,s2
    800035d0:	00000097          	auipc	ra,0x0
    800035d4:	e20080e7          	jalr	-480(ra) # 800033f0 <brelse>
  bp = bread(dev, bno);
    800035d8:	85a6                	mv	a1,s1
    800035da:	855e                	mv	a0,s7
    800035dc:	00000097          	auipc	ra,0x0
    800035e0:	ce4080e7          	jalr	-796(ra) # 800032c0 <bread>
    800035e4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035e6:	40000613          	li	a2,1024
    800035ea:	4581                	li	a1,0
    800035ec:	05850513          	addi	a0,a0,88
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	744080e7          	jalr	1860(ra) # 80000d34 <memset>
  log_write(bp);
    800035f8:	854a                	mv	a0,s2
    800035fa:	00001097          	auipc	ra,0x1
    800035fe:	0a0080e7          	jalr	160(ra) # 8000469a <log_write>
  brelse(bp);
    80003602:	854a                	mv	a0,s2
    80003604:	00000097          	auipc	ra,0x0
    80003608:	dec080e7          	jalr	-532(ra) # 800033f0 <brelse>
}
    8000360c:	6906                	ld	s2,64(sp)
    8000360e:	79e2                	ld	s3,56(sp)
    80003610:	7a42                	ld	s4,48(sp)
    80003612:	7aa2                	ld	s5,40(sp)
    80003614:	7b02                	ld	s6,32(sp)
    80003616:	6be2                	ld	s7,24(sp)
    80003618:	6c42                	ld	s8,16(sp)
    8000361a:	6ca2                	ld	s9,8(sp)
}
    8000361c:	8526                	mv	a0,s1
    8000361e:	60e6                	ld	ra,88(sp)
    80003620:	6446                	ld	s0,80(sp)
    80003622:	64a6                	ld	s1,72(sp)
    80003624:	6125                	addi	sp,sp,96
    80003626:	8082                	ret
    brelse(bp);
    80003628:	854a                	mv	a0,s2
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	dc6080e7          	jalr	-570(ra) # 800033f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003632:	015c87bb          	addw	a5,s9,s5
    80003636:	00078a9b          	sext.w	s5,a5
    8000363a:	004b2703          	lw	a4,4(s6)
    8000363e:	06eaf163          	bgeu	s5,a4,800036a0 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003642:	41fad79b          	sraiw	a5,s5,0x1f
    80003646:	0137d79b          	srliw	a5,a5,0x13
    8000364a:	015787bb          	addw	a5,a5,s5
    8000364e:	40d7d79b          	sraiw	a5,a5,0xd
    80003652:	01cb2583          	lw	a1,28(s6)
    80003656:	9dbd                	addw	a1,a1,a5
    80003658:	855e                	mv	a0,s7
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	c66080e7          	jalr	-922(ra) # 800032c0 <bread>
    80003662:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003664:	004b2503          	lw	a0,4(s6)
    80003668:	000a849b          	sext.w	s1,s5
    8000366c:	8762                	mv	a4,s8
    8000366e:	faa4fde3          	bgeu	s1,a0,80003628 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003672:	00777693          	andi	a3,a4,7
    80003676:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000367a:	41f7579b          	sraiw	a5,a4,0x1f
    8000367e:	01d7d79b          	srliw	a5,a5,0x1d
    80003682:	9fb9                	addw	a5,a5,a4
    80003684:	4037d79b          	sraiw	a5,a5,0x3
    80003688:	00f90633          	add	a2,s2,a5
    8000368c:	05864603          	lbu	a2,88(a2)
    80003690:	00c6f5b3          	and	a1,a3,a2
    80003694:	d585                	beqz	a1,800035bc <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003696:	2705                	addiw	a4,a4,1
    80003698:	2485                	addiw	s1,s1,1
    8000369a:	fd471ae3          	bne	a4,s4,8000366e <balloc+0xee>
    8000369e:	b769                	j	80003628 <balloc+0xa8>
    800036a0:	6906                	ld	s2,64(sp)
    800036a2:	79e2                	ld	s3,56(sp)
    800036a4:	7a42                	ld	s4,48(sp)
    800036a6:	7aa2                	ld	s5,40(sp)
    800036a8:	7b02                	ld	s6,32(sp)
    800036aa:	6be2                	ld	s7,24(sp)
    800036ac:	6c42                	ld	s8,16(sp)
    800036ae:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800036b0:	00005517          	auipc	a0,0x5
    800036b4:	da050513          	addi	a0,a0,-608 # 80008450 <etext+0x450>
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	ef2080e7          	jalr	-270(ra) # 800005aa <printf>
  return 0;
    800036c0:	4481                	li	s1,0
    800036c2:	bfa9                	j	8000361c <balloc+0x9c>

00000000800036c4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800036c4:	7179                	addi	sp,sp,-48
    800036c6:	f406                	sd	ra,40(sp)
    800036c8:	f022                	sd	s0,32(sp)
    800036ca:	ec26                	sd	s1,24(sp)
    800036cc:	e84a                	sd	s2,16(sp)
    800036ce:	e44e                	sd	s3,8(sp)
    800036d0:	1800                	addi	s0,sp,48
    800036d2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036d4:	47ad                	li	a5,11
    800036d6:	02b7e863          	bltu	a5,a1,80003706 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800036da:	02059793          	slli	a5,a1,0x20
    800036de:	01e7d593          	srli	a1,a5,0x1e
    800036e2:	00b504b3          	add	s1,a0,a1
    800036e6:	0504a903          	lw	s2,80(s1)
    800036ea:	08091263          	bnez	s2,8000376e <bmap+0xaa>
      addr = balloc(ip->dev);
    800036ee:	4108                	lw	a0,0(a0)
    800036f0:	00000097          	auipc	ra,0x0
    800036f4:	e90080e7          	jalr	-368(ra) # 80003580 <balloc>
    800036f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036fc:	06090963          	beqz	s2,8000376e <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003700:	0524a823          	sw	s2,80(s1)
    80003704:	a0ad                	j	8000376e <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003706:	ff45849b          	addiw	s1,a1,-12
    8000370a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000370e:	0ff00793          	li	a5,255
    80003712:	08e7e863          	bltu	a5,a4,800037a2 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003716:	08052903          	lw	s2,128(a0)
    8000371a:	00091f63          	bnez	s2,80003738 <bmap+0x74>
      addr = balloc(ip->dev);
    8000371e:	4108                	lw	a0,0(a0)
    80003720:	00000097          	auipc	ra,0x0
    80003724:	e60080e7          	jalr	-416(ra) # 80003580 <balloc>
    80003728:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000372c:	04090163          	beqz	s2,8000376e <bmap+0xaa>
    80003730:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003732:	0929a023          	sw	s2,128(s3)
    80003736:	a011                	j	8000373a <bmap+0x76>
    80003738:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000373a:	85ca                	mv	a1,s2
    8000373c:	0009a503          	lw	a0,0(s3)
    80003740:	00000097          	auipc	ra,0x0
    80003744:	b80080e7          	jalr	-1152(ra) # 800032c0 <bread>
    80003748:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000374a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000374e:	02049713          	slli	a4,s1,0x20
    80003752:	01e75593          	srli	a1,a4,0x1e
    80003756:	00b784b3          	add	s1,a5,a1
    8000375a:	0004a903          	lw	s2,0(s1)
    8000375e:	02090063          	beqz	s2,8000377e <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003762:	8552                	mv	a0,s4
    80003764:	00000097          	auipc	ra,0x0
    80003768:	c8c080e7          	jalr	-884(ra) # 800033f0 <brelse>
    return addr;
    8000376c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000376e:	854a                	mv	a0,s2
    80003770:	70a2                	ld	ra,40(sp)
    80003772:	7402                	ld	s0,32(sp)
    80003774:	64e2                	ld	s1,24(sp)
    80003776:	6942                	ld	s2,16(sp)
    80003778:	69a2                	ld	s3,8(sp)
    8000377a:	6145                	addi	sp,sp,48
    8000377c:	8082                	ret
      addr = balloc(ip->dev);
    8000377e:	0009a503          	lw	a0,0(s3)
    80003782:	00000097          	auipc	ra,0x0
    80003786:	dfe080e7          	jalr	-514(ra) # 80003580 <balloc>
    8000378a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000378e:	fc090ae3          	beqz	s2,80003762 <bmap+0x9e>
        a[bn] = addr;
    80003792:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003796:	8552                	mv	a0,s4
    80003798:	00001097          	auipc	ra,0x1
    8000379c:	f02080e7          	jalr	-254(ra) # 8000469a <log_write>
    800037a0:	b7c9                	j	80003762 <bmap+0x9e>
    800037a2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800037a4:	00005517          	auipc	a0,0x5
    800037a8:	cc450513          	addi	a0,a0,-828 # 80008468 <etext+0x468>
    800037ac:	ffffd097          	auipc	ra,0xffffd
    800037b0:	db4080e7          	jalr	-588(ra) # 80000560 <panic>

00000000800037b4 <iget>:
{
    800037b4:	7179                	addi	sp,sp,-48
    800037b6:	f406                	sd	ra,40(sp)
    800037b8:	f022                	sd	s0,32(sp)
    800037ba:	ec26                	sd	s1,24(sp)
    800037bc:	e84a                	sd	s2,16(sp)
    800037be:	e44e                	sd	s3,8(sp)
    800037c0:	e052                	sd	s4,0(sp)
    800037c2:	1800                	addi	s0,sp,48
    800037c4:	89aa                	mv	s3,a0
    800037c6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037c8:	00022517          	auipc	a0,0x22
    800037cc:	3a050513          	addi	a0,a0,928 # 80025b68 <itable>
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	468080e7          	jalr	1128(ra) # 80000c38 <acquire>
  empty = 0;
    800037d8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037da:	00022497          	auipc	s1,0x22
    800037de:	3a648493          	addi	s1,s1,934 # 80025b80 <itable+0x18>
    800037e2:	00024697          	auipc	a3,0x24
    800037e6:	e2e68693          	addi	a3,a3,-466 # 80027610 <log>
    800037ea:	a039                	j	800037f8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037ec:	02090b63          	beqz	s2,80003822 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037f0:	08848493          	addi	s1,s1,136
    800037f4:	02d48a63          	beq	s1,a3,80003828 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037f8:	449c                	lw	a5,8(s1)
    800037fa:	fef059e3          	blez	a5,800037ec <iget+0x38>
    800037fe:	4098                	lw	a4,0(s1)
    80003800:	ff3716e3          	bne	a4,s3,800037ec <iget+0x38>
    80003804:	40d8                	lw	a4,4(s1)
    80003806:	ff4713e3          	bne	a4,s4,800037ec <iget+0x38>
      ip->ref++;
    8000380a:	2785                	addiw	a5,a5,1
    8000380c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000380e:	00022517          	auipc	a0,0x22
    80003812:	35a50513          	addi	a0,a0,858 # 80025b68 <itable>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	4d6080e7          	jalr	1238(ra) # 80000cec <release>
      return ip;
    8000381e:	8926                	mv	s2,s1
    80003820:	a03d                	j	8000384e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003822:	f7f9                	bnez	a5,800037f0 <iget+0x3c>
      empty = ip;
    80003824:	8926                	mv	s2,s1
    80003826:	b7e9                	j	800037f0 <iget+0x3c>
  if(empty == 0)
    80003828:	02090c63          	beqz	s2,80003860 <iget+0xac>
  ip->dev = dev;
    8000382c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003830:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003834:	4785                	li	a5,1
    80003836:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000383a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000383e:	00022517          	auipc	a0,0x22
    80003842:	32a50513          	addi	a0,a0,810 # 80025b68 <itable>
    80003846:	ffffd097          	auipc	ra,0xffffd
    8000384a:	4a6080e7          	jalr	1190(ra) # 80000cec <release>
}
    8000384e:	854a                	mv	a0,s2
    80003850:	70a2                	ld	ra,40(sp)
    80003852:	7402                	ld	s0,32(sp)
    80003854:	64e2                	ld	s1,24(sp)
    80003856:	6942                	ld	s2,16(sp)
    80003858:	69a2                	ld	s3,8(sp)
    8000385a:	6a02                	ld	s4,0(sp)
    8000385c:	6145                	addi	sp,sp,48
    8000385e:	8082                	ret
    panic("iget: no inodes");
    80003860:	00005517          	auipc	a0,0x5
    80003864:	c2050513          	addi	a0,a0,-992 # 80008480 <etext+0x480>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	cf8080e7          	jalr	-776(ra) # 80000560 <panic>

0000000080003870 <fsinit>:
fsinit(int dev) {
    80003870:	7179                	addi	sp,sp,-48
    80003872:	f406                	sd	ra,40(sp)
    80003874:	f022                	sd	s0,32(sp)
    80003876:	ec26                	sd	s1,24(sp)
    80003878:	e84a                	sd	s2,16(sp)
    8000387a:	e44e                	sd	s3,8(sp)
    8000387c:	1800                	addi	s0,sp,48
    8000387e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003880:	4585                	li	a1,1
    80003882:	00000097          	auipc	ra,0x0
    80003886:	a3e080e7          	jalr	-1474(ra) # 800032c0 <bread>
    8000388a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000388c:	00022997          	auipc	s3,0x22
    80003890:	2bc98993          	addi	s3,s3,700 # 80025b48 <sb>
    80003894:	02000613          	li	a2,32
    80003898:	05850593          	addi	a1,a0,88
    8000389c:	854e                	mv	a0,s3
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	4f2080e7          	jalr	1266(ra) # 80000d90 <memmove>
  brelse(bp);
    800038a6:	8526                	mv	a0,s1
    800038a8:	00000097          	auipc	ra,0x0
    800038ac:	b48080e7          	jalr	-1208(ra) # 800033f0 <brelse>
  if(sb.magic != FSMAGIC)
    800038b0:	0009a703          	lw	a4,0(s3)
    800038b4:	102037b7          	lui	a5,0x10203
    800038b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038bc:	02f71263          	bne	a4,a5,800038e0 <fsinit+0x70>
  initlog(dev, &sb);
    800038c0:	00022597          	auipc	a1,0x22
    800038c4:	28858593          	addi	a1,a1,648 # 80025b48 <sb>
    800038c8:	854a                	mv	a0,s2
    800038ca:	00001097          	auipc	ra,0x1
    800038ce:	b60080e7          	jalr	-1184(ra) # 8000442a <initlog>
}
    800038d2:	70a2                	ld	ra,40(sp)
    800038d4:	7402                	ld	s0,32(sp)
    800038d6:	64e2                	ld	s1,24(sp)
    800038d8:	6942                	ld	s2,16(sp)
    800038da:	69a2                	ld	s3,8(sp)
    800038dc:	6145                	addi	sp,sp,48
    800038de:	8082                	ret
    panic("invalid file system");
    800038e0:	00005517          	auipc	a0,0x5
    800038e4:	bb050513          	addi	a0,a0,-1104 # 80008490 <etext+0x490>
    800038e8:	ffffd097          	auipc	ra,0xffffd
    800038ec:	c78080e7          	jalr	-904(ra) # 80000560 <panic>

00000000800038f0 <iinit>:
{
    800038f0:	7179                	addi	sp,sp,-48
    800038f2:	f406                	sd	ra,40(sp)
    800038f4:	f022                	sd	s0,32(sp)
    800038f6:	ec26                	sd	s1,24(sp)
    800038f8:	e84a                	sd	s2,16(sp)
    800038fa:	e44e                	sd	s3,8(sp)
    800038fc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038fe:	00005597          	auipc	a1,0x5
    80003902:	baa58593          	addi	a1,a1,-1110 # 800084a8 <etext+0x4a8>
    80003906:	00022517          	auipc	a0,0x22
    8000390a:	26250513          	addi	a0,a0,610 # 80025b68 <itable>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	29a080e7          	jalr	666(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003916:	00022497          	auipc	s1,0x22
    8000391a:	27a48493          	addi	s1,s1,634 # 80025b90 <itable+0x28>
    8000391e:	00024997          	auipc	s3,0x24
    80003922:	d0298993          	addi	s3,s3,-766 # 80027620 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003926:	00005917          	auipc	s2,0x5
    8000392a:	b8a90913          	addi	s2,s2,-1142 # 800084b0 <etext+0x4b0>
    8000392e:	85ca                	mv	a1,s2
    80003930:	8526                	mv	a0,s1
    80003932:	00001097          	auipc	ra,0x1
    80003936:	e4c080e7          	jalr	-436(ra) # 8000477e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000393a:	08848493          	addi	s1,s1,136
    8000393e:	ff3498e3          	bne	s1,s3,8000392e <iinit+0x3e>
}
    80003942:	70a2                	ld	ra,40(sp)
    80003944:	7402                	ld	s0,32(sp)
    80003946:	64e2                	ld	s1,24(sp)
    80003948:	6942                	ld	s2,16(sp)
    8000394a:	69a2                	ld	s3,8(sp)
    8000394c:	6145                	addi	sp,sp,48
    8000394e:	8082                	ret

0000000080003950 <ialloc>:
{
    80003950:	7139                	addi	sp,sp,-64
    80003952:	fc06                	sd	ra,56(sp)
    80003954:	f822                	sd	s0,48(sp)
    80003956:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003958:	00022717          	auipc	a4,0x22
    8000395c:	1fc72703          	lw	a4,508(a4) # 80025b54 <sb+0xc>
    80003960:	4785                	li	a5,1
    80003962:	06e7f463          	bgeu	a5,a4,800039ca <ialloc+0x7a>
    80003966:	f426                	sd	s1,40(sp)
    80003968:	f04a                	sd	s2,32(sp)
    8000396a:	ec4e                	sd	s3,24(sp)
    8000396c:	e852                	sd	s4,16(sp)
    8000396e:	e456                	sd	s5,8(sp)
    80003970:	e05a                	sd	s6,0(sp)
    80003972:	8aaa                	mv	s5,a0
    80003974:	8b2e                	mv	s6,a1
    80003976:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003978:	00022a17          	auipc	s4,0x22
    8000397c:	1d0a0a13          	addi	s4,s4,464 # 80025b48 <sb>
    80003980:	00495593          	srli	a1,s2,0x4
    80003984:	018a2783          	lw	a5,24(s4)
    80003988:	9dbd                	addw	a1,a1,a5
    8000398a:	8556                	mv	a0,s5
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	934080e7          	jalr	-1740(ra) # 800032c0 <bread>
    80003994:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003996:	05850993          	addi	s3,a0,88
    8000399a:	00f97793          	andi	a5,s2,15
    8000399e:	079a                	slli	a5,a5,0x6
    800039a0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039a2:	00099783          	lh	a5,0(s3)
    800039a6:	cf9d                	beqz	a5,800039e4 <ialloc+0x94>
    brelse(bp);
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	a48080e7          	jalr	-1464(ra) # 800033f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800039b0:	0905                	addi	s2,s2,1
    800039b2:	00ca2703          	lw	a4,12(s4)
    800039b6:	0009079b          	sext.w	a5,s2
    800039ba:	fce7e3e3          	bltu	a5,a4,80003980 <ialloc+0x30>
    800039be:	74a2                	ld	s1,40(sp)
    800039c0:	7902                	ld	s2,32(sp)
    800039c2:	69e2                	ld	s3,24(sp)
    800039c4:	6a42                	ld	s4,16(sp)
    800039c6:	6aa2                	ld	s5,8(sp)
    800039c8:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800039ca:	00005517          	auipc	a0,0x5
    800039ce:	aee50513          	addi	a0,a0,-1298 # 800084b8 <etext+0x4b8>
    800039d2:	ffffd097          	auipc	ra,0xffffd
    800039d6:	bd8080e7          	jalr	-1064(ra) # 800005aa <printf>
  return 0;
    800039da:	4501                	li	a0,0
}
    800039dc:	70e2                	ld	ra,56(sp)
    800039de:	7442                	ld	s0,48(sp)
    800039e0:	6121                	addi	sp,sp,64
    800039e2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800039e4:	04000613          	li	a2,64
    800039e8:	4581                	li	a1,0
    800039ea:	854e                	mv	a0,s3
    800039ec:	ffffd097          	auipc	ra,0xffffd
    800039f0:	348080e7          	jalr	840(ra) # 80000d34 <memset>
      dip->type = type;
    800039f4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039f8:	8526                	mv	a0,s1
    800039fa:	00001097          	auipc	ra,0x1
    800039fe:	ca0080e7          	jalr	-864(ra) # 8000469a <log_write>
      brelse(bp);
    80003a02:	8526                	mv	a0,s1
    80003a04:	00000097          	auipc	ra,0x0
    80003a08:	9ec080e7          	jalr	-1556(ra) # 800033f0 <brelse>
      return iget(dev, inum);
    80003a0c:	0009059b          	sext.w	a1,s2
    80003a10:	8556                	mv	a0,s5
    80003a12:	00000097          	auipc	ra,0x0
    80003a16:	da2080e7          	jalr	-606(ra) # 800037b4 <iget>
    80003a1a:	74a2                	ld	s1,40(sp)
    80003a1c:	7902                	ld	s2,32(sp)
    80003a1e:	69e2                	ld	s3,24(sp)
    80003a20:	6a42                	ld	s4,16(sp)
    80003a22:	6aa2                	ld	s5,8(sp)
    80003a24:	6b02                	ld	s6,0(sp)
    80003a26:	bf5d                	j	800039dc <ialloc+0x8c>

0000000080003a28 <iupdate>:
{
    80003a28:	1101                	addi	sp,sp,-32
    80003a2a:	ec06                	sd	ra,24(sp)
    80003a2c:	e822                	sd	s0,16(sp)
    80003a2e:	e426                	sd	s1,8(sp)
    80003a30:	e04a                	sd	s2,0(sp)
    80003a32:	1000                	addi	s0,sp,32
    80003a34:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a36:	415c                	lw	a5,4(a0)
    80003a38:	0047d79b          	srliw	a5,a5,0x4
    80003a3c:	00022597          	auipc	a1,0x22
    80003a40:	1245a583          	lw	a1,292(a1) # 80025b60 <sb+0x18>
    80003a44:	9dbd                	addw	a1,a1,a5
    80003a46:	4108                	lw	a0,0(a0)
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	878080e7          	jalr	-1928(ra) # 800032c0 <bread>
    80003a50:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a52:	05850793          	addi	a5,a0,88
    80003a56:	40d8                	lw	a4,4(s1)
    80003a58:	8b3d                	andi	a4,a4,15
    80003a5a:	071a                	slli	a4,a4,0x6
    80003a5c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003a5e:	04449703          	lh	a4,68(s1)
    80003a62:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003a66:	04649703          	lh	a4,70(s1)
    80003a6a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003a6e:	04849703          	lh	a4,72(s1)
    80003a72:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003a76:	04a49703          	lh	a4,74(s1)
    80003a7a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003a7e:	44f8                	lw	a4,76(s1)
    80003a80:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a82:	03400613          	li	a2,52
    80003a86:	05048593          	addi	a1,s1,80
    80003a8a:	00c78513          	addi	a0,a5,12
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	302080e7          	jalr	770(ra) # 80000d90 <memmove>
  log_write(bp);
    80003a96:	854a                	mv	a0,s2
    80003a98:	00001097          	auipc	ra,0x1
    80003a9c:	c02080e7          	jalr	-1022(ra) # 8000469a <log_write>
  brelse(bp);
    80003aa0:	854a                	mv	a0,s2
    80003aa2:	00000097          	auipc	ra,0x0
    80003aa6:	94e080e7          	jalr	-1714(ra) # 800033f0 <brelse>
}
    80003aaa:	60e2                	ld	ra,24(sp)
    80003aac:	6442                	ld	s0,16(sp)
    80003aae:	64a2                	ld	s1,8(sp)
    80003ab0:	6902                	ld	s2,0(sp)
    80003ab2:	6105                	addi	sp,sp,32
    80003ab4:	8082                	ret

0000000080003ab6 <idup>:
{
    80003ab6:	1101                	addi	sp,sp,-32
    80003ab8:	ec06                	sd	ra,24(sp)
    80003aba:	e822                	sd	s0,16(sp)
    80003abc:	e426                	sd	s1,8(sp)
    80003abe:	1000                	addi	s0,sp,32
    80003ac0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ac2:	00022517          	auipc	a0,0x22
    80003ac6:	0a650513          	addi	a0,a0,166 # 80025b68 <itable>
    80003aca:	ffffd097          	auipc	ra,0xffffd
    80003ace:	16e080e7          	jalr	366(ra) # 80000c38 <acquire>
  ip->ref++;
    80003ad2:	449c                	lw	a5,8(s1)
    80003ad4:	2785                	addiw	a5,a5,1
    80003ad6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ad8:	00022517          	auipc	a0,0x22
    80003adc:	09050513          	addi	a0,a0,144 # 80025b68 <itable>
    80003ae0:	ffffd097          	auipc	ra,0xffffd
    80003ae4:	20c080e7          	jalr	524(ra) # 80000cec <release>
}
    80003ae8:	8526                	mv	a0,s1
    80003aea:	60e2                	ld	ra,24(sp)
    80003aec:	6442                	ld	s0,16(sp)
    80003aee:	64a2                	ld	s1,8(sp)
    80003af0:	6105                	addi	sp,sp,32
    80003af2:	8082                	ret

0000000080003af4 <ilock>:
{
    80003af4:	1101                	addi	sp,sp,-32
    80003af6:	ec06                	sd	ra,24(sp)
    80003af8:	e822                	sd	s0,16(sp)
    80003afa:	e426                	sd	s1,8(sp)
    80003afc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003afe:	c10d                	beqz	a0,80003b20 <ilock+0x2c>
    80003b00:	84aa                	mv	s1,a0
    80003b02:	451c                	lw	a5,8(a0)
    80003b04:	00f05e63          	blez	a5,80003b20 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003b08:	0541                	addi	a0,a0,16
    80003b0a:	00001097          	auipc	ra,0x1
    80003b0e:	cae080e7          	jalr	-850(ra) # 800047b8 <acquiresleep>
  if(ip->valid == 0){
    80003b12:	40bc                	lw	a5,64(s1)
    80003b14:	cf99                	beqz	a5,80003b32 <ilock+0x3e>
}
    80003b16:	60e2                	ld	ra,24(sp)
    80003b18:	6442                	ld	s0,16(sp)
    80003b1a:	64a2                	ld	s1,8(sp)
    80003b1c:	6105                	addi	sp,sp,32
    80003b1e:	8082                	ret
    80003b20:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003b22:	00005517          	auipc	a0,0x5
    80003b26:	9ae50513          	addi	a0,a0,-1618 # 800084d0 <etext+0x4d0>
    80003b2a:	ffffd097          	auipc	ra,0xffffd
    80003b2e:	a36080e7          	jalr	-1482(ra) # 80000560 <panic>
    80003b32:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b34:	40dc                	lw	a5,4(s1)
    80003b36:	0047d79b          	srliw	a5,a5,0x4
    80003b3a:	00022597          	auipc	a1,0x22
    80003b3e:	0265a583          	lw	a1,38(a1) # 80025b60 <sb+0x18>
    80003b42:	9dbd                	addw	a1,a1,a5
    80003b44:	4088                	lw	a0,0(s1)
    80003b46:	fffff097          	auipc	ra,0xfffff
    80003b4a:	77a080e7          	jalr	1914(ra) # 800032c0 <bread>
    80003b4e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b50:	05850593          	addi	a1,a0,88
    80003b54:	40dc                	lw	a5,4(s1)
    80003b56:	8bbd                	andi	a5,a5,15
    80003b58:	079a                	slli	a5,a5,0x6
    80003b5a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b5c:	00059783          	lh	a5,0(a1)
    80003b60:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b64:	00259783          	lh	a5,2(a1)
    80003b68:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b6c:	00459783          	lh	a5,4(a1)
    80003b70:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b74:	00659783          	lh	a5,6(a1)
    80003b78:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b7c:	459c                	lw	a5,8(a1)
    80003b7e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b80:	03400613          	li	a2,52
    80003b84:	05b1                	addi	a1,a1,12
    80003b86:	05048513          	addi	a0,s1,80
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	206080e7          	jalr	518(ra) # 80000d90 <memmove>
    brelse(bp);
    80003b92:	854a                	mv	a0,s2
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	85c080e7          	jalr	-1956(ra) # 800033f0 <brelse>
    ip->valid = 1;
    80003b9c:	4785                	li	a5,1
    80003b9e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ba0:	04449783          	lh	a5,68(s1)
    80003ba4:	c399                	beqz	a5,80003baa <ilock+0xb6>
    80003ba6:	6902                	ld	s2,0(sp)
    80003ba8:	b7bd                	j	80003b16 <ilock+0x22>
      panic("ilock: no type");
    80003baa:	00005517          	auipc	a0,0x5
    80003bae:	92e50513          	addi	a0,a0,-1746 # 800084d8 <etext+0x4d8>
    80003bb2:	ffffd097          	auipc	ra,0xffffd
    80003bb6:	9ae080e7          	jalr	-1618(ra) # 80000560 <panic>

0000000080003bba <iunlock>:
{
    80003bba:	1101                	addi	sp,sp,-32
    80003bbc:	ec06                	sd	ra,24(sp)
    80003bbe:	e822                	sd	s0,16(sp)
    80003bc0:	e426                	sd	s1,8(sp)
    80003bc2:	e04a                	sd	s2,0(sp)
    80003bc4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bc6:	c905                	beqz	a0,80003bf6 <iunlock+0x3c>
    80003bc8:	84aa                	mv	s1,a0
    80003bca:	01050913          	addi	s2,a0,16
    80003bce:	854a                	mv	a0,s2
    80003bd0:	00001097          	auipc	ra,0x1
    80003bd4:	c82080e7          	jalr	-894(ra) # 80004852 <holdingsleep>
    80003bd8:	cd19                	beqz	a0,80003bf6 <iunlock+0x3c>
    80003bda:	449c                	lw	a5,8(s1)
    80003bdc:	00f05d63          	blez	a5,80003bf6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003be0:	854a                	mv	a0,s2
    80003be2:	00001097          	auipc	ra,0x1
    80003be6:	c2c080e7          	jalr	-980(ra) # 8000480e <releasesleep>
}
    80003bea:	60e2                	ld	ra,24(sp)
    80003bec:	6442                	ld	s0,16(sp)
    80003bee:	64a2                	ld	s1,8(sp)
    80003bf0:	6902                	ld	s2,0(sp)
    80003bf2:	6105                	addi	sp,sp,32
    80003bf4:	8082                	ret
    panic("iunlock");
    80003bf6:	00005517          	auipc	a0,0x5
    80003bfa:	8f250513          	addi	a0,a0,-1806 # 800084e8 <etext+0x4e8>
    80003bfe:	ffffd097          	auipc	ra,0xffffd
    80003c02:	962080e7          	jalr	-1694(ra) # 80000560 <panic>

0000000080003c06 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c06:	7179                	addi	sp,sp,-48
    80003c08:	f406                	sd	ra,40(sp)
    80003c0a:	f022                	sd	s0,32(sp)
    80003c0c:	ec26                	sd	s1,24(sp)
    80003c0e:	e84a                	sd	s2,16(sp)
    80003c10:	e44e                	sd	s3,8(sp)
    80003c12:	1800                	addi	s0,sp,48
    80003c14:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c16:	05050493          	addi	s1,a0,80
    80003c1a:	08050913          	addi	s2,a0,128
    80003c1e:	a021                	j	80003c26 <itrunc+0x20>
    80003c20:	0491                	addi	s1,s1,4
    80003c22:	01248d63          	beq	s1,s2,80003c3c <itrunc+0x36>
    if(ip->addrs[i]){
    80003c26:	408c                	lw	a1,0(s1)
    80003c28:	dde5                	beqz	a1,80003c20 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003c2a:	0009a503          	lw	a0,0(s3)
    80003c2e:	00000097          	auipc	ra,0x0
    80003c32:	8d6080e7          	jalr	-1834(ra) # 80003504 <bfree>
      ip->addrs[i] = 0;
    80003c36:	0004a023          	sw	zero,0(s1)
    80003c3a:	b7dd                	j	80003c20 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c3c:	0809a583          	lw	a1,128(s3)
    80003c40:	ed99                	bnez	a1,80003c5e <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c42:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c46:	854e                	mv	a0,s3
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	de0080e7          	jalr	-544(ra) # 80003a28 <iupdate>
}
    80003c50:	70a2                	ld	ra,40(sp)
    80003c52:	7402                	ld	s0,32(sp)
    80003c54:	64e2                	ld	s1,24(sp)
    80003c56:	6942                	ld	s2,16(sp)
    80003c58:	69a2                	ld	s3,8(sp)
    80003c5a:	6145                	addi	sp,sp,48
    80003c5c:	8082                	ret
    80003c5e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c60:	0009a503          	lw	a0,0(s3)
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	65c080e7          	jalr	1628(ra) # 800032c0 <bread>
    80003c6c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c6e:	05850493          	addi	s1,a0,88
    80003c72:	45850913          	addi	s2,a0,1112
    80003c76:	a021                	j	80003c7e <itrunc+0x78>
    80003c78:	0491                	addi	s1,s1,4
    80003c7a:	01248b63          	beq	s1,s2,80003c90 <itrunc+0x8a>
      if(a[j])
    80003c7e:	408c                	lw	a1,0(s1)
    80003c80:	dde5                	beqz	a1,80003c78 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003c82:	0009a503          	lw	a0,0(s3)
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	87e080e7          	jalr	-1922(ra) # 80003504 <bfree>
    80003c8e:	b7ed                	j	80003c78 <itrunc+0x72>
    brelse(bp);
    80003c90:	8552                	mv	a0,s4
    80003c92:	fffff097          	auipc	ra,0xfffff
    80003c96:	75e080e7          	jalr	1886(ra) # 800033f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c9a:	0809a583          	lw	a1,128(s3)
    80003c9e:	0009a503          	lw	a0,0(s3)
    80003ca2:	00000097          	auipc	ra,0x0
    80003ca6:	862080e7          	jalr	-1950(ra) # 80003504 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003caa:	0809a023          	sw	zero,128(s3)
    80003cae:	6a02                	ld	s4,0(sp)
    80003cb0:	bf49                	j	80003c42 <itrunc+0x3c>

0000000080003cb2 <iput>:
{
    80003cb2:	1101                	addi	sp,sp,-32
    80003cb4:	ec06                	sd	ra,24(sp)
    80003cb6:	e822                	sd	s0,16(sp)
    80003cb8:	e426                	sd	s1,8(sp)
    80003cba:	1000                	addi	s0,sp,32
    80003cbc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cbe:	00022517          	auipc	a0,0x22
    80003cc2:	eaa50513          	addi	a0,a0,-342 # 80025b68 <itable>
    80003cc6:	ffffd097          	auipc	ra,0xffffd
    80003cca:	f72080e7          	jalr	-142(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cce:	4498                	lw	a4,8(s1)
    80003cd0:	4785                	li	a5,1
    80003cd2:	02f70263          	beq	a4,a5,80003cf6 <iput+0x44>
  ip->ref--;
    80003cd6:	449c                	lw	a5,8(s1)
    80003cd8:	37fd                	addiw	a5,a5,-1
    80003cda:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cdc:	00022517          	auipc	a0,0x22
    80003ce0:	e8c50513          	addi	a0,a0,-372 # 80025b68 <itable>
    80003ce4:	ffffd097          	auipc	ra,0xffffd
    80003ce8:	008080e7          	jalr	8(ra) # 80000cec <release>
}
    80003cec:	60e2                	ld	ra,24(sp)
    80003cee:	6442                	ld	s0,16(sp)
    80003cf0:	64a2                	ld	s1,8(sp)
    80003cf2:	6105                	addi	sp,sp,32
    80003cf4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cf6:	40bc                	lw	a5,64(s1)
    80003cf8:	dff9                	beqz	a5,80003cd6 <iput+0x24>
    80003cfa:	04a49783          	lh	a5,74(s1)
    80003cfe:	ffe1                	bnez	a5,80003cd6 <iput+0x24>
    80003d00:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003d02:	01048913          	addi	s2,s1,16
    80003d06:	854a                	mv	a0,s2
    80003d08:	00001097          	auipc	ra,0x1
    80003d0c:	ab0080e7          	jalr	-1360(ra) # 800047b8 <acquiresleep>
    release(&itable.lock);
    80003d10:	00022517          	auipc	a0,0x22
    80003d14:	e5850513          	addi	a0,a0,-424 # 80025b68 <itable>
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	fd4080e7          	jalr	-44(ra) # 80000cec <release>
    itrunc(ip);
    80003d20:	8526                	mv	a0,s1
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	ee4080e7          	jalr	-284(ra) # 80003c06 <itrunc>
    ip->type = 0;
    80003d2a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	cf8080e7          	jalr	-776(ra) # 80003a28 <iupdate>
    ip->valid = 0;
    80003d38:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d3c:	854a                	mv	a0,s2
    80003d3e:	00001097          	auipc	ra,0x1
    80003d42:	ad0080e7          	jalr	-1328(ra) # 8000480e <releasesleep>
    acquire(&itable.lock);
    80003d46:	00022517          	auipc	a0,0x22
    80003d4a:	e2250513          	addi	a0,a0,-478 # 80025b68 <itable>
    80003d4e:	ffffd097          	auipc	ra,0xffffd
    80003d52:	eea080e7          	jalr	-278(ra) # 80000c38 <acquire>
    80003d56:	6902                	ld	s2,0(sp)
    80003d58:	bfbd                	j	80003cd6 <iput+0x24>

0000000080003d5a <iunlockput>:
{
    80003d5a:	1101                	addi	sp,sp,-32
    80003d5c:	ec06                	sd	ra,24(sp)
    80003d5e:	e822                	sd	s0,16(sp)
    80003d60:	e426                	sd	s1,8(sp)
    80003d62:	1000                	addi	s0,sp,32
    80003d64:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	e54080e7          	jalr	-428(ra) # 80003bba <iunlock>
  iput(ip);
    80003d6e:	8526                	mv	a0,s1
    80003d70:	00000097          	auipc	ra,0x0
    80003d74:	f42080e7          	jalr	-190(ra) # 80003cb2 <iput>
}
    80003d78:	60e2                	ld	ra,24(sp)
    80003d7a:	6442                	ld	s0,16(sp)
    80003d7c:	64a2                	ld	s1,8(sp)
    80003d7e:	6105                	addi	sp,sp,32
    80003d80:	8082                	ret

0000000080003d82 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d82:	1141                	addi	sp,sp,-16
    80003d84:	e422                	sd	s0,8(sp)
    80003d86:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d88:	411c                	lw	a5,0(a0)
    80003d8a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d8c:	415c                	lw	a5,4(a0)
    80003d8e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d90:	04451783          	lh	a5,68(a0)
    80003d94:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d98:	04a51783          	lh	a5,74(a0)
    80003d9c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003da0:	04c56783          	lwu	a5,76(a0)
    80003da4:	e99c                	sd	a5,16(a1)
}
    80003da6:	6422                	ld	s0,8(sp)
    80003da8:	0141                	addi	sp,sp,16
    80003daa:	8082                	ret

0000000080003dac <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dac:	457c                	lw	a5,76(a0)
    80003dae:	10d7e563          	bltu	a5,a3,80003eb8 <readi+0x10c>
{
    80003db2:	7159                	addi	sp,sp,-112
    80003db4:	f486                	sd	ra,104(sp)
    80003db6:	f0a2                	sd	s0,96(sp)
    80003db8:	eca6                	sd	s1,88(sp)
    80003dba:	e0d2                	sd	s4,64(sp)
    80003dbc:	fc56                	sd	s5,56(sp)
    80003dbe:	f85a                	sd	s6,48(sp)
    80003dc0:	f45e                	sd	s7,40(sp)
    80003dc2:	1880                	addi	s0,sp,112
    80003dc4:	8b2a                	mv	s6,a0
    80003dc6:	8bae                	mv	s7,a1
    80003dc8:	8a32                	mv	s4,a2
    80003dca:	84b6                	mv	s1,a3
    80003dcc:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003dce:	9f35                	addw	a4,a4,a3
    return 0;
    80003dd0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003dd2:	0cd76a63          	bltu	a4,a3,80003ea6 <readi+0xfa>
    80003dd6:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003dd8:	00e7f463          	bgeu	a5,a4,80003de0 <readi+0x34>
    n = ip->size - off;
    80003ddc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003de0:	0a0a8963          	beqz	s5,80003e92 <readi+0xe6>
    80003de4:	e8ca                	sd	s2,80(sp)
    80003de6:	f062                	sd	s8,32(sp)
    80003de8:	ec66                	sd	s9,24(sp)
    80003dea:	e86a                	sd	s10,16(sp)
    80003dec:	e46e                	sd	s11,8(sp)
    80003dee:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003df0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003df4:	5c7d                	li	s8,-1
    80003df6:	a82d                	j	80003e30 <readi+0x84>
    80003df8:	020d1d93          	slli	s11,s10,0x20
    80003dfc:	020ddd93          	srli	s11,s11,0x20
    80003e00:	05890613          	addi	a2,s2,88
    80003e04:	86ee                	mv	a3,s11
    80003e06:	963a                	add	a2,a2,a4
    80003e08:	85d2                	mv	a1,s4
    80003e0a:	855e                	mv	a0,s7
    80003e0c:	ffffe097          	auipc	ra,0xffffe
    80003e10:	72e080e7          	jalr	1838(ra) # 8000253a <either_copyout>
    80003e14:	05850d63          	beq	a0,s8,80003e6e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e18:	854a                	mv	a0,s2
    80003e1a:	fffff097          	auipc	ra,0xfffff
    80003e1e:	5d6080e7          	jalr	1494(ra) # 800033f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e22:	013d09bb          	addw	s3,s10,s3
    80003e26:	009d04bb          	addw	s1,s10,s1
    80003e2a:	9a6e                	add	s4,s4,s11
    80003e2c:	0559fd63          	bgeu	s3,s5,80003e86 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003e30:	00a4d59b          	srliw	a1,s1,0xa
    80003e34:	855a                	mv	a0,s6
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	88e080e7          	jalr	-1906(ra) # 800036c4 <bmap>
    80003e3e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e42:	c9b1                	beqz	a1,80003e96 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003e44:	000b2503          	lw	a0,0(s6)
    80003e48:	fffff097          	auipc	ra,0xfffff
    80003e4c:	478080e7          	jalr	1144(ra) # 800032c0 <bread>
    80003e50:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e52:	3ff4f713          	andi	a4,s1,1023
    80003e56:	40ec87bb          	subw	a5,s9,a4
    80003e5a:	413a86bb          	subw	a3,s5,s3
    80003e5e:	8d3e                	mv	s10,a5
    80003e60:	2781                	sext.w	a5,a5
    80003e62:	0006861b          	sext.w	a2,a3
    80003e66:	f8f679e3          	bgeu	a2,a5,80003df8 <readi+0x4c>
    80003e6a:	8d36                	mv	s10,a3
    80003e6c:	b771                	j	80003df8 <readi+0x4c>
      brelse(bp);
    80003e6e:	854a                	mv	a0,s2
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	580080e7          	jalr	1408(ra) # 800033f0 <brelse>
      tot = -1;
    80003e78:	59fd                	li	s3,-1
      break;
    80003e7a:	6946                	ld	s2,80(sp)
    80003e7c:	7c02                	ld	s8,32(sp)
    80003e7e:	6ce2                	ld	s9,24(sp)
    80003e80:	6d42                	ld	s10,16(sp)
    80003e82:	6da2                	ld	s11,8(sp)
    80003e84:	a831                	j	80003ea0 <readi+0xf4>
    80003e86:	6946                	ld	s2,80(sp)
    80003e88:	7c02                	ld	s8,32(sp)
    80003e8a:	6ce2                	ld	s9,24(sp)
    80003e8c:	6d42                	ld	s10,16(sp)
    80003e8e:	6da2                	ld	s11,8(sp)
    80003e90:	a801                	j	80003ea0 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e92:	89d6                	mv	s3,s5
    80003e94:	a031                	j	80003ea0 <readi+0xf4>
    80003e96:	6946                	ld	s2,80(sp)
    80003e98:	7c02                	ld	s8,32(sp)
    80003e9a:	6ce2                	ld	s9,24(sp)
    80003e9c:	6d42                	ld	s10,16(sp)
    80003e9e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003ea0:	0009851b          	sext.w	a0,s3
    80003ea4:	69a6                	ld	s3,72(sp)
}
    80003ea6:	70a6                	ld	ra,104(sp)
    80003ea8:	7406                	ld	s0,96(sp)
    80003eaa:	64e6                	ld	s1,88(sp)
    80003eac:	6a06                	ld	s4,64(sp)
    80003eae:	7ae2                	ld	s5,56(sp)
    80003eb0:	7b42                	ld	s6,48(sp)
    80003eb2:	7ba2                	ld	s7,40(sp)
    80003eb4:	6165                	addi	sp,sp,112
    80003eb6:	8082                	ret
    return 0;
    80003eb8:	4501                	li	a0,0
}
    80003eba:	8082                	ret

0000000080003ebc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ebc:	457c                	lw	a5,76(a0)
    80003ebe:	10d7ee63          	bltu	a5,a3,80003fda <writei+0x11e>
{
    80003ec2:	7159                	addi	sp,sp,-112
    80003ec4:	f486                	sd	ra,104(sp)
    80003ec6:	f0a2                	sd	s0,96(sp)
    80003ec8:	e8ca                	sd	s2,80(sp)
    80003eca:	e0d2                	sd	s4,64(sp)
    80003ecc:	fc56                	sd	s5,56(sp)
    80003ece:	f85a                	sd	s6,48(sp)
    80003ed0:	f45e                	sd	s7,40(sp)
    80003ed2:	1880                	addi	s0,sp,112
    80003ed4:	8aaa                	mv	s5,a0
    80003ed6:	8bae                	mv	s7,a1
    80003ed8:	8a32                	mv	s4,a2
    80003eda:	8936                	mv	s2,a3
    80003edc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ede:	00e687bb          	addw	a5,a3,a4
    80003ee2:	0ed7ee63          	bltu	a5,a3,80003fde <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ee6:	00043737          	lui	a4,0x43
    80003eea:	0ef76c63          	bltu	a4,a5,80003fe2 <writei+0x126>
    80003eee:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ef0:	0c0b0d63          	beqz	s6,80003fca <writei+0x10e>
    80003ef4:	eca6                	sd	s1,88(sp)
    80003ef6:	f062                	sd	s8,32(sp)
    80003ef8:	ec66                	sd	s9,24(sp)
    80003efa:	e86a                	sd	s10,16(sp)
    80003efc:	e46e                	sd	s11,8(sp)
    80003efe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f00:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f04:	5c7d                	li	s8,-1
    80003f06:	a091                	j	80003f4a <writei+0x8e>
    80003f08:	020d1d93          	slli	s11,s10,0x20
    80003f0c:	020ddd93          	srli	s11,s11,0x20
    80003f10:	05848513          	addi	a0,s1,88
    80003f14:	86ee                	mv	a3,s11
    80003f16:	8652                	mv	a2,s4
    80003f18:	85de                	mv	a1,s7
    80003f1a:	953a                	add	a0,a0,a4
    80003f1c:	ffffe097          	auipc	ra,0xffffe
    80003f20:	674080e7          	jalr	1652(ra) # 80002590 <either_copyin>
    80003f24:	07850263          	beq	a0,s8,80003f88 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	770080e7          	jalr	1904(ra) # 8000469a <log_write>
    brelse(bp);
    80003f32:	8526                	mv	a0,s1
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	4bc080e7          	jalr	1212(ra) # 800033f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f3c:	013d09bb          	addw	s3,s10,s3
    80003f40:	012d093b          	addw	s2,s10,s2
    80003f44:	9a6e                	add	s4,s4,s11
    80003f46:	0569f663          	bgeu	s3,s6,80003f92 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003f4a:	00a9559b          	srliw	a1,s2,0xa
    80003f4e:	8556                	mv	a0,s5
    80003f50:	fffff097          	auipc	ra,0xfffff
    80003f54:	774080e7          	jalr	1908(ra) # 800036c4 <bmap>
    80003f58:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f5c:	c99d                	beqz	a1,80003f92 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f5e:	000aa503          	lw	a0,0(s5)
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	35e080e7          	jalr	862(ra) # 800032c0 <bread>
    80003f6a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f6c:	3ff97713          	andi	a4,s2,1023
    80003f70:	40ec87bb          	subw	a5,s9,a4
    80003f74:	413b06bb          	subw	a3,s6,s3
    80003f78:	8d3e                	mv	s10,a5
    80003f7a:	2781                	sext.w	a5,a5
    80003f7c:	0006861b          	sext.w	a2,a3
    80003f80:	f8f674e3          	bgeu	a2,a5,80003f08 <writei+0x4c>
    80003f84:	8d36                	mv	s10,a3
    80003f86:	b749                	j	80003f08 <writei+0x4c>
      brelse(bp);
    80003f88:	8526                	mv	a0,s1
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	466080e7          	jalr	1126(ra) # 800033f0 <brelse>
  }

  if(off > ip->size)
    80003f92:	04caa783          	lw	a5,76(s5)
    80003f96:	0327fc63          	bgeu	a5,s2,80003fce <writei+0x112>
    ip->size = off;
    80003f9a:	052aa623          	sw	s2,76(s5)
    80003f9e:	64e6                	ld	s1,88(sp)
    80003fa0:	7c02                	ld	s8,32(sp)
    80003fa2:	6ce2                	ld	s9,24(sp)
    80003fa4:	6d42                	ld	s10,16(sp)
    80003fa6:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003fa8:	8556                	mv	a0,s5
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	a7e080e7          	jalr	-1410(ra) # 80003a28 <iupdate>

  return tot;
    80003fb2:	0009851b          	sext.w	a0,s3
    80003fb6:	69a6                	ld	s3,72(sp)
}
    80003fb8:	70a6                	ld	ra,104(sp)
    80003fba:	7406                	ld	s0,96(sp)
    80003fbc:	6946                	ld	s2,80(sp)
    80003fbe:	6a06                	ld	s4,64(sp)
    80003fc0:	7ae2                	ld	s5,56(sp)
    80003fc2:	7b42                	ld	s6,48(sp)
    80003fc4:	7ba2                	ld	s7,40(sp)
    80003fc6:	6165                	addi	sp,sp,112
    80003fc8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fca:	89da                	mv	s3,s6
    80003fcc:	bff1                	j	80003fa8 <writei+0xec>
    80003fce:	64e6                	ld	s1,88(sp)
    80003fd0:	7c02                	ld	s8,32(sp)
    80003fd2:	6ce2                	ld	s9,24(sp)
    80003fd4:	6d42                	ld	s10,16(sp)
    80003fd6:	6da2                	ld	s11,8(sp)
    80003fd8:	bfc1                	j	80003fa8 <writei+0xec>
    return -1;
    80003fda:	557d                	li	a0,-1
}
    80003fdc:	8082                	ret
    return -1;
    80003fde:	557d                	li	a0,-1
    80003fe0:	bfe1                	j	80003fb8 <writei+0xfc>
    return -1;
    80003fe2:	557d                	li	a0,-1
    80003fe4:	bfd1                	j	80003fb8 <writei+0xfc>

0000000080003fe6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003fe6:	1141                	addi	sp,sp,-16
    80003fe8:	e406                	sd	ra,8(sp)
    80003fea:	e022                	sd	s0,0(sp)
    80003fec:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fee:	4639                	li	a2,14
    80003ff0:	ffffd097          	auipc	ra,0xffffd
    80003ff4:	e14080e7          	jalr	-492(ra) # 80000e04 <strncmp>
}
    80003ff8:	60a2                	ld	ra,8(sp)
    80003ffa:	6402                	ld	s0,0(sp)
    80003ffc:	0141                	addi	sp,sp,16
    80003ffe:	8082                	ret

0000000080004000 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004000:	7139                	addi	sp,sp,-64
    80004002:	fc06                	sd	ra,56(sp)
    80004004:	f822                	sd	s0,48(sp)
    80004006:	f426                	sd	s1,40(sp)
    80004008:	f04a                	sd	s2,32(sp)
    8000400a:	ec4e                	sd	s3,24(sp)
    8000400c:	e852                	sd	s4,16(sp)
    8000400e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004010:	04451703          	lh	a4,68(a0)
    80004014:	4785                	li	a5,1
    80004016:	00f71a63          	bne	a4,a5,8000402a <dirlookup+0x2a>
    8000401a:	892a                	mv	s2,a0
    8000401c:	89ae                	mv	s3,a1
    8000401e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004020:	457c                	lw	a5,76(a0)
    80004022:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004024:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004026:	e79d                	bnez	a5,80004054 <dirlookup+0x54>
    80004028:	a8a5                	j	800040a0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000402a:	00004517          	auipc	a0,0x4
    8000402e:	4c650513          	addi	a0,a0,1222 # 800084f0 <etext+0x4f0>
    80004032:	ffffc097          	auipc	ra,0xffffc
    80004036:	52e080e7          	jalr	1326(ra) # 80000560 <panic>
      panic("dirlookup read");
    8000403a:	00004517          	auipc	a0,0x4
    8000403e:	4ce50513          	addi	a0,a0,1230 # 80008508 <etext+0x508>
    80004042:	ffffc097          	auipc	ra,0xffffc
    80004046:	51e080e7          	jalr	1310(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000404a:	24c1                	addiw	s1,s1,16
    8000404c:	04c92783          	lw	a5,76(s2)
    80004050:	04f4f763          	bgeu	s1,a5,8000409e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004054:	4741                	li	a4,16
    80004056:	86a6                	mv	a3,s1
    80004058:	fc040613          	addi	a2,s0,-64
    8000405c:	4581                	li	a1,0
    8000405e:	854a                	mv	a0,s2
    80004060:	00000097          	auipc	ra,0x0
    80004064:	d4c080e7          	jalr	-692(ra) # 80003dac <readi>
    80004068:	47c1                	li	a5,16
    8000406a:	fcf518e3          	bne	a0,a5,8000403a <dirlookup+0x3a>
    if(de.inum == 0)
    8000406e:	fc045783          	lhu	a5,-64(s0)
    80004072:	dfe1                	beqz	a5,8000404a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004074:	fc240593          	addi	a1,s0,-62
    80004078:	854e                	mv	a0,s3
    8000407a:	00000097          	auipc	ra,0x0
    8000407e:	f6c080e7          	jalr	-148(ra) # 80003fe6 <namecmp>
    80004082:	f561                	bnez	a0,8000404a <dirlookup+0x4a>
      if(poff)
    80004084:	000a0463          	beqz	s4,8000408c <dirlookup+0x8c>
        *poff = off;
    80004088:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000408c:	fc045583          	lhu	a1,-64(s0)
    80004090:	00092503          	lw	a0,0(s2)
    80004094:	fffff097          	auipc	ra,0xfffff
    80004098:	720080e7          	jalr	1824(ra) # 800037b4 <iget>
    8000409c:	a011                	j	800040a0 <dirlookup+0xa0>
  return 0;
    8000409e:	4501                	li	a0,0
}
    800040a0:	70e2                	ld	ra,56(sp)
    800040a2:	7442                	ld	s0,48(sp)
    800040a4:	74a2                	ld	s1,40(sp)
    800040a6:	7902                	ld	s2,32(sp)
    800040a8:	69e2                	ld	s3,24(sp)
    800040aa:	6a42                	ld	s4,16(sp)
    800040ac:	6121                	addi	sp,sp,64
    800040ae:	8082                	ret

00000000800040b0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040b0:	711d                	addi	sp,sp,-96
    800040b2:	ec86                	sd	ra,88(sp)
    800040b4:	e8a2                	sd	s0,80(sp)
    800040b6:	e4a6                	sd	s1,72(sp)
    800040b8:	e0ca                	sd	s2,64(sp)
    800040ba:	fc4e                	sd	s3,56(sp)
    800040bc:	f852                	sd	s4,48(sp)
    800040be:	f456                	sd	s5,40(sp)
    800040c0:	f05a                	sd	s6,32(sp)
    800040c2:	ec5e                	sd	s7,24(sp)
    800040c4:	e862                	sd	s8,16(sp)
    800040c6:	e466                	sd	s9,8(sp)
    800040c8:	1080                	addi	s0,sp,96
    800040ca:	84aa                	mv	s1,a0
    800040cc:	8b2e                	mv	s6,a1
    800040ce:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040d0:	00054703          	lbu	a4,0(a0)
    800040d4:	02f00793          	li	a5,47
    800040d8:	02f70263          	beq	a4,a5,800040fc <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040dc:	ffffe097          	auipc	ra,0xffffe
    800040e0:	966080e7          	jalr	-1690(ra) # 80001a42 <myproc>
    800040e4:	15053503          	ld	a0,336(a0)
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	9ce080e7          	jalr	-1586(ra) # 80003ab6 <idup>
    800040f0:	8a2a                	mv	s4,a0
  while(*path == '/')
    800040f2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800040f6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040f8:	4b85                	li	s7,1
    800040fa:	a875                	j	800041b6 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    800040fc:	4585                	li	a1,1
    800040fe:	4505                	li	a0,1
    80004100:	fffff097          	auipc	ra,0xfffff
    80004104:	6b4080e7          	jalr	1716(ra) # 800037b4 <iget>
    80004108:	8a2a                	mv	s4,a0
    8000410a:	b7e5                	j	800040f2 <namex+0x42>
      iunlockput(ip);
    8000410c:	8552                	mv	a0,s4
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	c4c080e7          	jalr	-948(ra) # 80003d5a <iunlockput>
      return 0;
    80004116:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004118:	8552                	mv	a0,s4
    8000411a:	60e6                	ld	ra,88(sp)
    8000411c:	6446                	ld	s0,80(sp)
    8000411e:	64a6                	ld	s1,72(sp)
    80004120:	6906                	ld	s2,64(sp)
    80004122:	79e2                	ld	s3,56(sp)
    80004124:	7a42                	ld	s4,48(sp)
    80004126:	7aa2                	ld	s5,40(sp)
    80004128:	7b02                	ld	s6,32(sp)
    8000412a:	6be2                	ld	s7,24(sp)
    8000412c:	6c42                	ld	s8,16(sp)
    8000412e:	6ca2                	ld	s9,8(sp)
    80004130:	6125                	addi	sp,sp,96
    80004132:	8082                	ret
      iunlock(ip);
    80004134:	8552                	mv	a0,s4
    80004136:	00000097          	auipc	ra,0x0
    8000413a:	a84080e7          	jalr	-1404(ra) # 80003bba <iunlock>
      return ip;
    8000413e:	bfe9                	j	80004118 <namex+0x68>
      iunlockput(ip);
    80004140:	8552                	mv	a0,s4
    80004142:	00000097          	auipc	ra,0x0
    80004146:	c18080e7          	jalr	-1000(ra) # 80003d5a <iunlockput>
      return 0;
    8000414a:	8a4e                	mv	s4,s3
    8000414c:	b7f1                	j	80004118 <namex+0x68>
  len = path - s;
    8000414e:	40998633          	sub	a2,s3,s1
    80004152:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004156:	099c5863          	bge	s8,s9,800041e6 <namex+0x136>
    memmove(name, s, DIRSIZ);
    8000415a:	4639                	li	a2,14
    8000415c:	85a6                	mv	a1,s1
    8000415e:	8556                	mv	a0,s5
    80004160:	ffffd097          	auipc	ra,0xffffd
    80004164:	c30080e7          	jalr	-976(ra) # 80000d90 <memmove>
    80004168:	84ce                	mv	s1,s3
  while(*path == '/')
    8000416a:	0004c783          	lbu	a5,0(s1)
    8000416e:	01279763          	bne	a5,s2,8000417c <namex+0xcc>
    path++;
    80004172:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004174:	0004c783          	lbu	a5,0(s1)
    80004178:	ff278de3          	beq	a5,s2,80004172 <namex+0xc2>
    ilock(ip);
    8000417c:	8552                	mv	a0,s4
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	976080e7          	jalr	-1674(ra) # 80003af4 <ilock>
    if(ip->type != T_DIR){
    80004186:	044a1783          	lh	a5,68(s4)
    8000418a:	f97791e3          	bne	a5,s7,8000410c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000418e:	000b0563          	beqz	s6,80004198 <namex+0xe8>
    80004192:	0004c783          	lbu	a5,0(s1)
    80004196:	dfd9                	beqz	a5,80004134 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004198:	4601                	li	a2,0
    8000419a:	85d6                	mv	a1,s5
    8000419c:	8552                	mv	a0,s4
    8000419e:	00000097          	auipc	ra,0x0
    800041a2:	e62080e7          	jalr	-414(ra) # 80004000 <dirlookup>
    800041a6:	89aa                	mv	s3,a0
    800041a8:	dd41                	beqz	a0,80004140 <namex+0x90>
    iunlockput(ip);
    800041aa:	8552                	mv	a0,s4
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	bae080e7          	jalr	-1106(ra) # 80003d5a <iunlockput>
    ip = next;
    800041b4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800041b6:	0004c783          	lbu	a5,0(s1)
    800041ba:	01279763          	bne	a5,s2,800041c8 <namex+0x118>
    path++;
    800041be:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041c0:	0004c783          	lbu	a5,0(s1)
    800041c4:	ff278de3          	beq	a5,s2,800041be <namex+0x10e>
  if(*path == 0)
    800041c8:	cb9d                	beqz	a5,800041fe <namex+0x14e>
  while(*path != '/' && *path != 0)
    800041ca:	0004c783          	lbu	a5,0(s1)
    800041ce:	89a6                	mv	s3,s1
  len = path - s;
    800041d0:	4c81                	li	s9,0
    800041d2:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800041d4:	01278963          	beq	a5,s2,800041e6 <namex+0x136>
    800041d8:	dbbd                	beqz	a5,8000414e <namex+0x9e>
    path++;
    800041da:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800041dc:	0009c783          	lbu	a5,0(s3)
    800041e0:	ff279ce3          	bne	a5,s2,800041d8 <namex+0x128>
    800041e4:	b7ad                	j	8000414e <namex+0x9e>
    memmove(name, s, len);
    800041e6:	2601                	sext.w	a2,a2
    800041e8:	85a6                	mv	a1,s1
    800041ea:	8556                	mv	a0,s5
    800041ec:	ffffd097          	auipc	ra,0xffffd
    800041f0:	ba4080e7          	jalr	-1116(ra) # 80000d90 <memmove>
    name[len] = 0;
    800041f4:	9cd6                	add	s9,s9,s5
    800041f6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800041fa:	84ce                	mv	s1,s3
    800041fc:	b7bd                	j	8000416a <namex+0xba>
  if(nameiparent){
    800041fe:	f00b0de3          	beqz	s6,80004118 <namex+0x68>
    iput(ip);
    80004202:	8552                	mv	a0,s4
    80004204:	00000097          	auipc	ra,0x0
    80004208:	aae080e7          	jalr	-1362(ra) # 80003cb2 <iput>
    return 0;
    8000420c:	4a01                	li	s4,0
    8000420e:	b729                	j	80004118 <namex+0x68>

0000000080004210 <dirlink>:
{
    80004210:	7139                	addi	sp,sp,-64
    80004212:	fc06                	sd	ra,56(sp)
    80004214:	f822                	sd	s0,48(sp)
    80004216:	f04a                	sd	s2,32(sp)
    80004218:	ec4e                	sd	s3,24(sp)
    8000421a:	e852                	sd	s4,16(sp)
    8000421c:	0080                	addi	s0,sp,64
    8000421e:	892a                	mv	s2,a0
    80004220:	8a2e                	mv	s4,a1
    80004222:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004224:	4601                	li	a2,0
    80004226:	00000097          	auipc	ra,0x0
    8000422a:	dda080e7          	jalr	-550(ra) # 80004000 <dirlookup>
    8000422e:	ed25                	bnez	a0,800042a6 <dirlink+0x96>
    80004230:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004232:	04c92483          	lw	s1,76(s2)
    80004236:	c49d                	beqz	s1,80004264 <dirlink+0x54>
    80004238:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000423a:	4741                	li	a4,16
    8000423c:	86a6                	mv	a3,s1
    8000423e:	fc040613          	addi	a2,s0,-64
    80004242:	4581                	li	a1,0
    80004244:	854a                	mv	a0,s2
    80004246:	00000097          	auipc	ra,0x0
    8000424a:	b66080e7          	jalr	-1178(ra) # 80003dac <readi>
    8000424e:	47c1                	li	a5,16
    80004250:	06f51163          	bne	a0,a5,800042b2 <dirlink+0xa2>
    if(de.inum == 0)
    80004254:	fc045783          	lhu	a5,-64(s0)
    80004258:	c791                	beqz	a5,80004264 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000425a:	24c1                	addiw	s1,s1,16
    8000425c:	04c92783          	lw	a5,76(s2)
    80004260:	fcf4ede3          	bltu	s1,a5,8000423a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004264:	4639                	li	a2,14
    80004266:	85d2                	mv	a1,s4
    80004268:	fc240513          	addi	a0,s0,-62
    8000426c:	ffffd097          	auipc	ra,0xffffd
    80004270:	bce080e7          	jalr	-1074(ra) # 80000e3a <strncpy>
  de.inum = inum;
    80004274:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004278:	4741                	li	a4,16
    8000427a:	86a6                	mv	a3,s1
    8000427c:	fc040613          	addi	a2,s0,-64
    80004280:	4581                	li	a1,0
    80004282:	854a                	mv	a0,s2
    80004284:	00000097          	auipc	ra,0x0
    80004288:	c38080e7          	jalr	-968(ra) # 80003ebc <writei>
    8000428c:	1541                	addi	a0,a0,-16
    8000428e:	00a03533          	snez	a0,a0
    80004292:	40a00533          	neg	a0,a0
    80004296:	74a2                	ld	s1,40(sp)
}
    80004298:	70e2                	ld	ra,56(sp)
    8000429a:	7442                	ld	s0,48(sp)
    8000429c:	7902                	ld	s2,32(sp)
    8000429e:	69e2                	ld	s3,24(sp)
    800042a0:	6a42                	ld	s4,16(sp)
    800042a2:	6121                	addi	sp,sp,64
    800042a4:	8082                	ret
    iput(ip);
    800042a6:	00000097          	auipc	ra,0x0
    800042aa:	a0c080e7          	jalr	-1524(ra) # 80003cb2 <iput>
    return -1;
    800042ae:	557d                	li	a0,-1
    800042b0:	b7e5                	j	80004298 <dirlink+0x88>
      panic("dirlink read");
    800042b2:	00004517          	auipc	a0,0x4
    800042b6:	26650513          	addi	a0,a0,614 # 80008518 <etext+0x518>
    800042ba:	ffffc097          	auipc	ra,0xffffc
    800042be:	2a6080e7          	jalr	678(ra) # 80000560 <panic>

00000000800042c2 <namei>:

struct inode*
namei(char *path)
{
    800042c2:	1101                	addi	sp,sp,-32
    800042c4:	ec06                	sd	ra,24(sp)
    800042c6:	e822                	sd	s0,16(sp)
    800042c8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042ca:	fe040613          	addi	a2,s0,-32
    800042ce:	4581                	li	a1,0
    800042d0:	00000097          	auipc	ra,0x0
    800042d4:	de0080e7          	jalr	-544(ra) # 800040b0 <namex>
}
    800042d8:	60e2                	ld	ra,24(sp)
    800042da:	6442                	ld	s0,16(sp)
    800042dc:	6105                	addi	sp,sp,32
    800042de:	8082                	ret

00000000800042e0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042e0:	1141                	addi	sp,sp,-16
    800042e2:	e406                	sd	ra,8(sp)
    800042e4:	e022                	sd	s0,0(sp)
    800042e6:	0800                	addi	s0,sp,16
    800042e8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042ea:	4585                	li	a1,1
    800042ec:	00000097          	auipc	ra,0x0
    800042f0:	dc4080e7          	jalr	-572(ra) # 800040b0 <namex>
}
    800042f4:	60a2                	ld	ra,8(sp)
    800042f6:	6402                	ld	s0,0(sp)
    800042f8:	0141                	addi	sp,sp,16
    800042fa:	8082                	ret

00000000800042fc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042fc:	1101                	addi	sp,sp,-32
    800042fe:	ec06                	sd	ra,24(sp)
    80004300:	e822                	sd	s0,16(sp)
    80004302:	e426                	sd	s1,8(sp)
    80004304:	e04a                	sd	s2,0(sp)
    80004306:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004308:	00023917          	auipc	s2,0x23
    8000430c:	30890913          	addi	s2,s2,776 # 80027610 <log>
    80004310:	01892583          	lw	a1,24(s2)
    80004314:	02892503          	lw	a0,40(s2)
    80004318:	fffff097          	auipc	ra,0xfffff
    8000431c:	fa8080e7          	jalr	-88(ra) # 800032c0 <bread>
    80004320:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004322:	02c92603          	lw	a2,44(s2)
    80004326:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004328:	00c05f63          	blez	a2,80004346 <write_head+0x4a>
    8000432c:	00023717          	auipc	a4,0x23
    80004330:	31470713          	addi	a4,a4,788 # 80027640 <log+0x30>
    80004334:	87aa                	mv	a5,a0
    80004336:	060a                	slli	a2,a2,0x2
    80004338:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000433a:	4314                	lw	a3,0(a4)
    8000433c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000433e:	0711                	addi	a4,a4,4
    80004340:	0791                	addi	a5,a5,4
    80004342:	fec79ce3          	bne	a5,a2,8000433a <write_head+0x3e>
  }
  bwrite(buf);
    80004346:	8526                	mv	a0,s1
    80004348:	fffff097          	auipc	ra,0xfffff
    8000434c:	06a080e7          	jalr	106(ra) # 800033b2 <bwrite>
  brelse(buf);
    80004350:	8526                	mv	a0,s1
    80004352:	fffff097          	auipc	ra,0xfffff
    80004356:	09e080e7          	jalr	158(ra) # 800033f0 <brelse>
}
    8000435a:	60e2                	ld	ra,24(sp)
    8000435c:	6442                	ld	s0,16(sp)
    8000435e:	64a2                	ld	s1,8(sp)
    80004360:	6902                	ld	s2,0(sp)
    80004362:	6105                	addi	sp,sp,32
    80004364:	8082                	ret

0000000080004366 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004366:	00023797          	auipc	a5,0x23
    8000436a:	2d67a783          	lw	a5,726(a5) # 8002763c <log+0x2c>
    8000436e:	0af05d63          	blez	a5,80004428 <install_trans+0xc2>
{
    80004372:	7139                	addi	sp,sp,-64
    80004374:	fc06                	sd	ra,56(sp)
    80004376:	f822                	sd	s0,48(sp)
    80004378:	f426                	sd	s1,40(sp)
    8000437a:	f04a                	sd	s2,32(sp)
    8000437c:	ec4e                	sd	s3,24(sp)
    8000437e:	e852                	sd	s4,16(sp)
    80004380:	e456                	sd	s5,8(sp)
    80004382:	e05a                	sd	s6,0(sp)
    80004384:	0080                	addi	s0,sp,64
    80004386:	8b2a                	mv	s6,a0
    80004388:	00023a97          	auipc	s5,0x23
    8000438c:	2b8a8a93          	addi	s5,s5,696 # 80027640 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004390:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004392:	00023997          	auipc	s3,0x23
    80004396:	27e98993          	addi	s3,s3,638 # 80027610 <log>
    8000439a:	a00d                	j	800043bc <install_trans+0x56>
    brelse(lbuf);
    8000439c:	854a                	mv	a0,s2
    8000439e:	fffff097          	auipc	ra,0xfffff
    800043a2:	052080e7          	jalr	82(ra) # 800033f0 <brelse>
    brelse(dbuf);
    800043a6:	8526                	mv	a0,s1
    800043a8:	fffff097          	auipc	ra,0xfffff
    800043ac:	048080e7          	jalr	72(ra) # 800033f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043b0:	2a05                	addiw	s4,s4,1
    800043b2:	0a91                	addi	s5,s5,4
    800043b4:	02c9a783          	lw	a5,44(s3)
    800043b8:	04fa5e63          	bge	s4,a5,80004414 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043bc:	0189a583          	lw	a1,24(s3)
    800043c0:	014585bb          	addw	a1,a1,s4
    800043c4:	2585                	addiw	a1,a1,1
    800043c6:	0289a503          	lw	a0,40(s3)
    800043ca:	fffff097          	auipc	ra,0xfffff
    800043ce:	ef6080e7          	jalr	-266(ra) # 800032c0 <bread>
    800043d2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043d4:	000aa583          	lw	a1,0(s5)
    800043d8:	0289a503          	lw	a0,40(s3)
    800043dc:	fffff097          	auipc	ra,0xfffff
    800043e0:	ee4080e7          	jalr	-284(ra) # 800032c0 <bread>
    800043e4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043e6:	40000613          	li	a2,1024
    800043ea:	05890593          	addi	a1,s2,88
    800043ee:	05850513          	addi	a0,a0,88
    800043f2:	ffffd097          	auipc	ra,0xffffd
    800043f6:	99e080e7          	jalr	-1634(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    800043fa:	8526                	mv	a0,s1
    800043fc:	fffff097          	auipc	ra,0xfffff
    80004400:	fb6080e7          	jalr	-74(ra) # 800033b2 <bwrite>
    if(recovering == 0)
    80004404:	f80b1ce3          	bnez	s6,8000439c <install_trans+0x36>
      bunpin(dbuf);
    80004408:	8526                	mv	a0,s1
    8000440a:	fffff097          	auipc	ra,0xfffff
    8000440e:	0be080e7          	jalr	190(ra) # 800034c8 <bunpin>
    80004412:	b769                	j	8000439c <install_trans+0x36>
}
    80004414:	70e2                	ld	ra,56(sp)
    80004416:	7442                	ld	s0,48(sp)
    80004418:	74a2                	ld	s1,40(sp)
    8000441a:	7902                	ld	s2,32(sp)
    8000441c:	69e2                	ld	s3,24(sp)
    8000441e:	6a42                	ld	s4,16(sp)
    80004420:	6aa2                	ld	s5,8(sp)
    80004422:	6b02                	ld	s6,0(sp)
    80004424:	6121                	addi	sp,sp,64
    80004426:	8082                	ret
    80004428:	8082                	ret

000000008000442a <initlog>:
{
    8000442a:	7179                	addi	sp,sp,-48
    8000442c:	f406                	sd	ra,40(sp)
    8000442e:	f022                	sd	s0,32(sp)
    80004430:	ec26                	sd	s1,24(sp)
    80004432:	e84a                	sd	s2,16(sp)
    80004434:	e44e                	sd	s3,8(sp)
    80004436:	1800                	addi	s0,sp,48
    80004438:	892a                	mv	s2,a0
    8000443a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000443c:	00023497          	auipc	s1,0x23
    80004440:	1d448493          	addi	s1,s1,468 # 80027610 <log>
    80004444:	00004597          	auipc	a1,0x4
    80004448:	0e458593          	addi	a1,a1,228 # 80008528 <etext+0x528>
    8000444c:	8526                	mv	a0,s1
    8000444e:	ffffc097          	auipc	ra,0xffffc
    80004452:	75a080e7          	jalr	1882(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    80004456:	0149a583          	lw	a1,20(s3)
    8000445a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000445c:	0109a783          	lw	a5,16(s3)
    80004460:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004462:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004466:	854a                	mv	a0,s2
    80004468:	fffff097          	auipc	ra,0xfffff
    8000446c:	e58080e7          	jalr	-424(ra) # 800032c0 <bread>
  log.lh.n = lh->n;
    80004470:	4d30                	lw	a2,88(a0)
    80004472:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004474:	00c05f63          	blez	a2,80004492 <initlog+0x68>
    80004478:	87aa                	mv	a5,a0
    8000447a:	00023717          	auipc	a4,0x23
    8000447e:	1c670713          	addi	a4,a4,454 # 80027640 <log+0x30>
    80004482:	060a                	slli	a2,a2,0x2
    80004484:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004486:	4ff4                	lw	a3,92(a5)
    80004488:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000448a:	0791                	addi	a5,a5,4
    8000448c:	0711                	addi	a4,a4,4
    8000448e:	fec79ce3          	bne	a5,a2,80004486 <initlog+0x5c>
  brelse(buf);
    80004492:	fffff097          	auipc	ra,0xfffff
    80004496:	f5e080e7          	jalr	-162(ra) # 800033f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000449a:	4505                	li	a0,1
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	eca080e7          	jalr	-310(ra) # 80004366 <install_trans>
  log.lh.n = 0;
    800044a4:	00023797          	auipc	a5,0x23
    800044a8:	1807ac23          	sw	zero,408(a5) # 8002763c <log+0x2c>
  write_head(); // clear the log
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	e50080e7          	jalr	-432(ra) # 800042fc <write_head>
}
    800044b4:	70a2                	ld	ra,40(sp)
    800044b6:	7402                	ld	s0,32(sp)
    800044b8:	64e2                	ld	s1,24(sp)
    800044ba:	6942                	ld	s2,16(sp)
    800044bc:	69a2                	ld	s3,8(sp)
    800044be:	6145                	addi	sp,sp,48
    800044c0:	8082                	ret

00000000800044c2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044c2:	1101                	addi	sp,sp,-32
    800044c4:	ec06                	sd	ra,24(sp)
    800044c6:	e822                	sd	s0,16(sp)
    800044c8:	e426                	sd	s1,8(sp)
    800044ca:	e04a                	sd	s2,0(sp)
    800044cc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044ce:	00023517          	auipc	a0,0x23
    800044d2:	14250513          	addi	a0,a0,322 # 80027610 <log>
    800044d6:	ffffc097          	auipc	ra,0xffffc
    800044da:	762080e7          	jalr	1890(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    800044de:	00023497          	auipc	s1,0x23
    800044e2:	13248493          	addi	s1,s1,306 # 80027610 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044e6:	4979                	li	s2,30
    800044e8:	a039                	j	800044f6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800044ea:	85a6                	mv	a1,s1
    800044ec:	8526                	mv	a0,s1
    800044ee:	ffffe097          	auipc	ra,0xffffe
    800044f2:	c38080e7          	jalr	-968(ra) # 80002126 <sleep>
    if(log.committing){
    800044f6:	50dc                	lw	a5,36(s1)
    800044f8:	fbed                	bnez	a5,800044ea <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044fa:	5098                	lw	a4,32(s1)
    800044fc:	2705                	addiw	a4,a4,1
    800044fe:	0027179b          	slliw	a5,a4,0x2
    80004502:	9fb9                	addw	a5,a5,a4
    80004504:	0017979b          	slliw	a5,a5,0x1
    80004508:	54d4                	lw	a3,44(s1)
    8000450a:	9fb5                	addw	a5,a5,a3
    8000450c:	00f95963          	bge	s2,a5,8000451e <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004510:	85a6                	mv	a1,s1
    80004512:	8526                	mv	a0,s1
    80004514:	ffffe097          	auipc	ra,0xffffe
    80004518:	c12080e7          	jalr	-1006(ra) # 80002126 <sleep>
    8000451c:	bfe9                	j	800044f6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000451e:	00023517          	auipc	a0,0x23
    80004522:	0f250513          	addi	a0,a0,242 # 80027610 <log>
    80004526:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	7c4080e7          	jalr	1988(ra) # 80000cec <release>
      break;
    }
  }
}
    80004530:	60e2                	ld	ra,24(sp)
    80004532:	6442                	ld	s0,16(sp)
    80004534:	64a2                	ld	s1,8(sp)
    80004536:	6902                	ld	s2,0(sp)
    80004538:	6105                	addi	sp,sp,32
    8000453a:	8082                	ret

000000008000453c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000453c:	7139                	addi	sp,sp,-64
    8000453e:	fc06                	sd	ra,56(sp)
    80004540:	f822                	sd	s0,48(sp)
    80004542:	f426                	sd	s1,40(sp)
    80004544:	f04a                	sd	s2,32(sp)
    80004546:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004548:	00023497          	auipc	s1,0x23
    8000454c:	0c848493          	addi	s1,s1,200 # 80027610 <log>
    80004550:	8526                	mv	a0,s1
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	6e6080e7          	jalr	1766(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    8000455a:	509c                	lw	a5,32(s1)
    8000455c:	37fd                	addiw	a5,a5,-1
    8000455e:	0007891b          	sext.w	s2,a5
    80004562:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004564:	50dc                	lw	a5,36(s1)
    80004566:	e7b9                	bnez	a5,800045b4 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004568:	06091163          	bnez	s2,800045ca <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000456c:	00023497          	auipc	s1,0x23
    80004570:	0a448493          	addi	s1,s1,164 # 80027610 <log>
    80004574:	4785                	li	a5,1
    80004576:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004578:	8526                	mv	a0,s1
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	772080e7          	jalr	1906(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004582:	54dc                	lw	a5,44(s1)
    80004584:	06f04763          	bgtz	a5,800045f2 <end_op+0xb6>
    acquire(&log.lock);
    80004588:	00023497          	auipc	s1,0x23
    8000458c:	08848493          	addi	s1,s1,136 # 80027610 <log>
    80004590:	8526                	mv	a0,s1
    80004592:	ffffc097          	auipc	ra,0xffffc
    80004596:	6a6080e7          	jalr	1702(ra) # 80000c38 <acquire>
    log.committing = 0;
    8000459a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000459e:	8526                	mv	a0,s1
    800045a0:	ffffe097          	auipc	ra,0xffffe
    800045a4:	bea080e7          	jalr	-1046(ra) # 8000218a <wakeup>
    release(&log.lock);
    800045a8:	8526                	mv	a0,s1
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	742080e7          	jalr	1858(ra) # 80000cec <release>
}
    800045b2:	a815                	j	800045e6 <end_op+0xaa>
    800045b4:	ec4e                	sd	s3,24(sp)
    800045b6:	e852                	sd	s4,16(sp)
    800045b8:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800045ba:	00004517          	auipc	a0,0x4
    800045be:	f7650513          	addi	a0,a0,-138 # 80008530 <etext+0x530>
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	f9e080e7          	jalr	-98(ra) # 80000560 <panic>
    wakeup(&log);
    800045ca:	00023497          	auipc	s1,0x23
    800045ce:	04648493          	addi	s1,s1,70 # 80027610 <log>
    800045d2:	8526                	mv	a0,s1
    800045d4:	ffffe097          	auipc	ra,0xffffe
    800045d8:	bb6080e7          	jalr	-1098(ra) # 8000218a <wakeup>
  release(&log.lock);
    800045dc:	8526                	mv	a0,s1
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	70e080e7          	jalr	1806(ra) # 80000cec <release>
}
    800045e6:	70e2                	ld	ra,56(sp)
    800045e8:	7442                	ld	s0,48(sp)
    800045ea:	74a2                	ld	s1,40(sp)
    800045ec:	7902                	ld	s2,32(sp)
    800045ee:	6121                	addi	sp,sp,64
    800045f0:	8082                	ret
    800045f2:	ec4e                	sd	s3,24(sp)
    800045f4:	e852                	sd	s4,16(sp)
    800045f6:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800045f8:	00023a97          	auipc	s5,0x23
    800045fc:	048a8a93          	addi	s5,s5,72 # 80027640 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004600:	00023a17          	auipc	s4,0x23
    80004604:	010a0a13          	addi	s4,s4,16 # 80027610 <log>
    80004608:	018a2583          	lw	a1,24(s4)
    8000460c:	012585bb          	addw	a1,a1,s2
    80004610:	2585                	addiw	a1,a1,1
    80004612:	028a2503          	lw	a0,40(s4)
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	caa080e7          	jalr	-854(ra) # 800032c0 <bread>
    8000461e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004620:	000aa583          	lw	a1,0(s5)
    80004624:	028a2503          	lw	a0,40(s4)
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	c98080e7          	jalr	-872(ra) # 800032c0 <bread>
    80004630:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004632:	40000613          	li	a2,1024
    80004636:	05850593          	addi	a1,a0,88
    8000463a:	05848513          	addi	a0,s1,88
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	752080e7          	jalr	1874(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    80004646:	8526                	mv	a0,s1
    80004648:	fffff097          	auipc	ra,0xfffff
    8000464c:	d6a080e7          	jalr	-662(ra) # 800033b2 <bwrite>
    brelse(from);
    80004650:	854e                	mv	a0,s3
    80004652:	fffff097          	auipc	ra,0xfffff
    80004656:	d9e080e7          	jalr	-610(ra) # 800033f0 <brelse>
    brelse(to);
    8000465a:	8526                	mv	a0,s1
    8000465c:	fffff097          	auipc	ra,0xfffff
    80004660:	d94080e7          	jalr	-620(ra) # 800033f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004664:	2905                	addiw	s2,s2,1
    80004666:	0a91                	addi	s5,s5,4
    80004668:	02ca2783          	lw	a5,44(s4)
    8000466c:	f8f94ee3          	blt	s2,a5,80004608 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004670:	00000097          	auipc	ra,0x0
    80004674:	c8c080e7          	jalr	-884(ra) # 800042fc <write_head>
    install_trans(0); // Now install writes to home locations
    80004678:	4501                	li	a0,0
    8000467a:	00000097          	auipc	ra,0x0
    8000467e:	cec080e7          	jalr	-788(ra) # 80004366 <install_trans>
    log.lh.n = 0;
    80004682:	00023797          	auipc	a5,0x23
    80004686:	fa07ad23          	sw	zero,-70(a5) # 8002763c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000468a:	00000097          	auipc	ra,0x0
    8000468e:	c72080e7          	jalr	-910(ra) # 800042fc <write_head>
    80004692:	69e2                	ld	s3,24(sp)
    80004694:	6a42                	ld	s4,16(sp)
    80004696:	6aa2                	ld	s5,8(sp)
    80004698:	bdc5                	j	80004588 <end_op+0x4c>

000000008000469a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000469a:	1101                	addi	sp,sp,-32
    8000469c:	ec06                	sd	ra,24(sp)
    8000469e:	e822                	sd	s0,16(sp)
    800046a0:	e426                	sd	s1,8(sp)
    800046a2:	e04a                	sd	s2,0(sp)
    800046a4:	1000                	addi	s0,sp,32
    800046a6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046a8:	00023917          	auipc	s2,0x23
    800046ac:	f6890913          	addi	s2,s2,-152 # 80027610 <log>
    800046b0:	854a                	mv	a0,s2
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	586080e7          	jalr	1414(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800046ba:	02c92603          	lw	a2,44(s2)
    800046be:	47f5                	li	a5,29
    800046c0:	06c7c563          	blt	a5,a2,8000472a <log_write+0x90>
    800046c4:	00023797          	auipc	a5,0x23
    800046c8:	f687a783          	lw	a5,-152(a5) # 8002762c <log+0x1c>
    800046cc:	37fd                	addiw	a5,a5,-1
    800046ce:	04f65e63          	bge	a2,a5,8000472a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046d2:	00023797          	auipc	a5,0x23
    800046d6:	f5e7a783          	lw	a5,-162(a5) # 80027630 <log+0x20>
    800046da:	06f05063          	blez	a5,8000473a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046de:	4781                	li	a5,0
    800046e0:	06c05563          	blez	a2,8000474a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046e4:	44cc                	lw	a1,12(s1)
    800046e6:	00023717          	auipc	a4,0x23
    800046ea:	f5a70713          	addi	a4,a4,-166 # 80027640 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046ee:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046f0:	4314                	lw	a3,0(a4)
    800046f2:	04b68c63          	beq	a3,a1,8000474a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800046f6:	2785                	addiw	a5,a5,1
    800046f8:	0711                	addi	a4,a4,4
    800046fa:	fef61be3          	bne	a2,a5,800046f0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046fe:	0621                	addi	a2,a2,8
    80004700:	060a                	slli	a2,a2,0x2
    80004702:	00023797          	auipc	a5,0x23
    80004706:	f0e78793          	addi	a5,a5,-242 # 80027610 <log>
    8000470a:	97b2                	add	a5,a5,a2
    8000470c:	44d8                	lw	a4,12(s1)
    8000470e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004710:	8526                	mv	a0,s1
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	d7a080e7          	jalr	-646(ra) # 8000348c <bpin>
    log.lh.n++;
    8000471a:	00023717          	auipc	a4,0x23
    8000471e:	ef670713          	addi	a4,a4,-266 # 80027610 <log>
    80004722:	575c                	lw	a5,44(a4)
    80004724:	2785                	addiw	a5,a5,1
    80004726:	d75c                	sw	a5,44(a4)
    80004728:	a82d                	j	80004762 <log_write+0xc8>
    panic("too big a transaction");
    8000472a:	00004517          	auipc	a0,0x4
    8000472e:	e1650513          	addi	a0,a0,-490 # 80008540 <etext+0x540>
    80004732:	ffffc097          	auipc	ra,0xffffc
    80004736:	e2e080e7          	jalr	-466(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    8000473a:	00004517          	auipc	a0,0x4
    8000473e:	e1e50513          	addi	a0,a0,-482 # 80008558 <etext+0x558>
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	e1e080e7          	jalr	-482(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    8000474a:	00878693          	addi	a3,a5,8
    8000474e:	068a                	slli	a3,a3,0x2
    80004750:	00023717          	auipc	a4,0x23
    80004754:	ec070713          	addi	a4,a4,-320 # 80027610 <log>
    80004758:	9736                	add	a4,a4,a3
    8000475a:	44d4                	lw	a3,12(s1)
    8000475c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000475e:	faf609e3          	beq	a2,a5,80004710 <log_write+0x76>
  }
  release(&log.lock);
    80004762:	00023517          	auipc	a0,0x23
    80004766:	eae50513          	addi	a0,a0,-338 # 80027610 <log>
    8000476a:	ffffc097          	auipc	ra,0xffffc
    8000476e:	582080e7          	jalr	1410(ra) # 80000cec <release>
}
    80004772:	60e2                	ld	ra,24(sp)
    80004774:	6442                	ld	s0,16(sp)
    80004776:	64a2                	ld	s1,8(sp)
    80004778:	6902                	ld	s2,0(sp)
    8000477a:	6105                	addi	sp,sp,32
    8000477c:	8082                	ret

000000008000477e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000477e:	1101                	addi	sp,sp,-32
    80004780:	ec06                	sd	ra,24(sp)
    80004782:	e822                	sd	s0,16(sp)
    80004784:	e426                	sd	s1,8(sp)
    80004786:	e04a                	sd	s2,0(sp)
    80004788:	1000                	addi	s0,sp,32
    8000478a:	84aa                	mv	s1,a0
    8000478c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000478e:	00004597          	auipc	a1,0x4
    80004792:	dea58593          	addi	a1,a1,-534 # 80008578 <etext+0x578>
    80004796:	0521                	addi	a0,a0,8
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	410080e7          	jalr	1040(ra) # 80000ba8 <initlock>
  lk->name = name;
    800047a0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047a8:	0204a423          	sw	zero,40(s1)
}
    800047ac:	60e2                	ld	ra,24(sp)
    800047ae:	6442                	ld	s0,16(sp)
    800047b0:	64a2                	ld	s1,8(sp)
    800047b2:	6902                	ld	s2,0(sp)
    800047b4:	6105                	addi	sp,sp,32
    800047b6:	8082                	ret

00000000800047b8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800047b8:	1101                	addi	sp,sp,-32
    800047ba:	ec06                	sd	ra,24(sp)
    800047bc:	e822                	sd	s0,16(sp)
    800047be:	e426                	sd	s1,8(sp)
    800047c0:	e04a                	sd	s2,0(sp)
    800047c2:	1000                	addi	s0,sp,32
    800047c4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047c6:	00850913          	addi	s2,a0,8
    800047ca:	854a                	mv	a0,s2
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	46c080e7          	jalr	1132(ra) # 80000c38 <acquire>
  while (lk->locked) {
    800047d4:	409c                	lw	a5,0(s1)
    800047d6:	cb89                	beqz	a5,800047e8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047d8:	85ca                	mv	a1,s2
    800047da:	8526                	mv	a0,s1
    800047dc:	ffffe097          	auipc	ra,0xffffe
    800047e0:	94a080e7          	jalr	-1718(ra) # 80002126 <sleep>
  while (lk->locked) {
    800047e4:	409c                	lw	a5,0(s1)
    800047e6:	fbed                	bnez	a5,800047d8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047e8:	4785                	li	a5,1
    800047ea:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047ec:	ffffd097          	auipc	ra,0xffffd
    800047f0:	256080e7          	jalr	598(ra) # 80001a42 <myproc>
    800047f4:	591c                	lw	a5,48(a0)
    800047f6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047f8:	854a                	mv	a0,s2
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	4f2080e7          	jalr	1266(ra) # 80000cec <release>
}
    80004802:	60e2                	ld	ra,24(sp)
    80004804:	6442                	ld	s0,16(sp)
    80004806:	64a2                	ld	s1,8(sp)
    80004808:	6902                	ld	s2,0(sp)
    8000480a:	6105                	addi	sp,sp,32
    8000480c:	8082                	ret

000000008000480e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000480e:	1101                	addi	sp,sp,-32
    80004810:	ec06                	sd	ra,24(sp)
    80004812:	e822                	sd	s0,16(sp)
    80004814:	e426                	sd	s1,8(sp)
    80004816:	e04a                	sd	s2,0(sp)
    80004818:	1000                	addi	s0,sp,32
    8000481a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000481c:	00850913          	addi	s2,a0,8
    80004820:	854a                	mv	a0,s2
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	416080e7          	jalr	1046(ra) # 80000c38 <acquire>
  lk->locked = 0;
    8000482a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000482e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004832:	8526                	mv	a0,s1
    80004834:	ffffe097          	auipc	ra,0xffffe
    80004838:	956080e7          	jalr	-1706(ra) # 8000218a <wakeup>
  release(&lk->lk);
    8000483c:	854a                	mv	a0,s2
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	4ae080e7          	jalr	1198(ra) # 80000cec <release>
}
    80004846:	60e2                	ld	ra,24(sp)
    80004848:	6442                	ld	s0,16(sp)
    8000484a:	64a2                	ld	s1,8(sp)
    8000484c:	6902                	ld	s2,0(sp)
    8000484e:	6105                	addi	sp,sp,32
    80004850:	8082                	ret

0000000080004852 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004852:	7179                	addi	sp,sp,-48
    80004854:	f406                	sd	ra,40(sp)
    80004856:	f022                	sd	s0,32(sp)
    80004858:	ec26                	sd	s1,24(sp)
    8000485a:	e84a                	sd	s2,16(sp)
    8000485c:	1800                	addi	s0,sp,48
    8000485e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004860:	00850913          	addi	s2,a0,8
    80004864:	854a                	mv	a0,s2
    80004866:	ffffc097          	auipc	ra,0xffffc
    8000486a:	3d2080e7          	jalr	978(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000486e:	409c                	lw	a5,0(s1)
    80004870:	ef91                	bnez	a5,8000488c <holdingsleep+0x3a>
    80004872:	4481                	li	s1,0
  release(&lk->lk);
    80004874:	854a                	mv	a0,s2
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	476080e7          	jalr	1142(ra) # 80000cec <release>
  return r;
}
    8000487e:	8526                	mv	a0,s1
    80004880:	70a2                	ld	ra,40(sp)
    80004882:	7402                	ld	s0,32(sp)
    80004884:	64e2                	ld	s1,24(sp)
    80004886:	6942                	ld	s2,16(sp)
    80004888:	6145                	addi	sp,sp,48
    8000488a:	8082                	ret
    8000488c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000488e:	0284a983          	lw	s3,40(s1)
    80004892:	ffffd097          	auipc	ra,0xffffd
    80004896:	1b0080e7          	jalr	432(ra) # 80001a42 <myproc>
    8000489a:	5904                	lw	s1,48(a0)
    8000489c:	413484b3          	sub	s1,s1,s3
    800048a0:	0014b493          	seqz	s1,s1
    800048a4:	69a2                	ld	s3,8(sp)
    800048a6:	b7f9                	j	80004874 <holdingsleep+0x22>

00000000800048a8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048a8:	1141                	addi	sp,sp,-16
    800048aa:	e406                	sd	ra,8(sp)
    800048ac:	e022                	sd	s0,0(sp)
    800048ae:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048b0:	00004597          	auipc	a1,0x4
    800048b4:	cd858593          	addi	a1,a1,-808 # 80008588 <etext+0x588>
    800048b8:	00023517          	auipc	a0,0x23
    800048bc:	ea050513          	addi	a0,a0,-352 # 80027758 <ftable>
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	2e8080e7          	jalr	744(ra) # 80000ba8 <initlock>
}
    800048c8:	60a2                	ld	ra,8(sp)
    800048ca:	6402                	ld	s0,0(sp)
    800048cc:	0141                	addi	sp,sp,16
    800048ce:	8082                	ret

00000000800048d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048d0:	1101                	addi	sp,sp,-32
    800048d2:	ec06                	sd	ra,24(sp)
    800048d4:	e822                	sd	s0,16(sp)
    800048d6:	e426                	sd	s1,8(sp)
    800048d8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048da:	00023517          	auipc	a0,0x23
    800048de:	e7e50513          	addi	a0,a0,-386 # 80027758 <ftable>
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	356080e7          	jalr	854(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048ea:	00023497          	auipc	s1,0x23
    800048ee:	e8648493          	addi	s1,s1,-378 # 80027770 <ftable+0x18>
    800048f2:	00024717          	auipc	a4,0x24
    800048f6:	e1e70713          	addi	a4,a4,-482 # 80028710 <disk>
    if(f->ref == 0){
    800048fa:	40dc                	lw	a5,4(s1)
    800048fc:	cf99                	beqz	a5,8000491a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048fe:	02848493          	addi	s1,s1,40
    80004902:	fee49ce3          	bne	s1,a4,800048fa <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004906:	00023517          	auipc	a0,0x23
    8000490a:	e5250513          	addi	a0,a0,-430 # 80027758 <ftable>
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	3de080e7          	jalr	990(ra) # 80000cec <release>
  return 0;
    80004916:	4481                	li	s1,0
    80004918:	a819                	j	8000492e <filealloc+0x5e>
      f->ref = 1;
    8000491a:	4785                	li	a5,1
    8000491c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000491e:	00023517          	auipc	a0,0x23
    80004922:	e3a50513          	addi	a0,a0,-454 # 80027758 <ftable>
    80004926:	ffffc097          	auipc	ra,0xffffc
    8000492a:	3c6080e7          	jalr	966(ra) # 80000cec <release>
}
    8000492e:	8526                	mv	a0,s1
    80004930:	60e2                	ld	ra,24(sp)
    80004932:	6442                	ld	s0,16(sp)
    80004934:	64a2                	ld	s1,8(sp)
    80004936:	6105                	addi	sp,sp,32
    80004938:	8082                	ret

000000008000493a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000493a:	1101                	addi	sp,sp,-32
    8000493c:	ec06                	sd	ra,24(sp)
    8000493e:	e822                	sd	s0,16(sp)
    80004940:	e426                	sd	s1,8(sp)
    80004942:	1000                	addi	s0,sp,32
    80004944:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004946:	00023517          	auipc	a0,0x23
    8000494a:	e1250513          	addi	a0,a0,-494 # 80027758 <ftable>
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	2ea080e7          	jalr	746(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004956:	40dc                	lw	a5,4(s1)
    80004958:	02f05263          	blez	a5,8000497c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000495c:	2785                	addiw	a5,a5,1
    8000495e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004960:	00023517          	auipc	a0,0x23
    80004964:	df850513          	addi	a0,a0,-520 # 80027758 <ftable>
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	384080e7          	jalr	900(ra) # 80000cec <release>
  return f;
}
    80004970:	8526                	mv	a0,s1
    80004972:	60e2                	ld	ra,24(sp)
    80004974:	6442                	ld	s0,16(sp)
    80004976:	64a2                	ld	s1,8(sp)
    80004978:	6105                	addi	sp,sp,32
    8000497a:	8082                	ret
    panic("filedup");
    8000497c:	00004517          	auipc	a0,0x4
    80004980:	c1450513          	addi	a0,a0,-1004 # 80008590 <etext+0x590>
    80004984:	ffffc097          	auipc	ra,0xffffc
    80004988:	bdc080e7          	jalr	-1060(ra) # 80000560 <panic>

000000008000498c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000498c:	7139                	addi	sp,sp,-64
    8000498e:	fc06                	sd	ra,56(sp)
    80004990:	f822                	sd	s0,48(sp)
    80004992:	f426                	sd	s1,40(sp)
    80004994:	0080                	addi	s0,sp,64
    80004996:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004998:	00023517          	auipc	a0,0x23
    8000499c:	dc050513          	addi	a0,a0,-576 # 80027758 <ftable>
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	298080e7          	jalr	664(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    800049a8:	40dc                	lw	a5,4(s1)
    800049aa:	04f05c63          	blez	a5,80004a02 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    800049ae:	37fd                	addiw	a5,a5,-1
    800049b0:	0007871b          	sext.w	a4,a5
    800049b4:	c0dc                	sw	a5,4(s1)
    800049b6:	06e04263          	bgtz	a4,80004a1a <fileclose+0x8e>
    800049ba:	f04a                	sd	s2,32(sp)
    800049bc:	ec4e                	sd	s3,24(sp)
    800049be:	e852                	sd	s4,16(sp)
    800049c0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049c2:	0004a903          	lw	s2,0(s1)
    800049c6:	0094ca83          	lbu	s5,9(s1)
    800049ca:	0104ba03          	ld	s4,16(s1)
    800049ce:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049d2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049d6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049da:	00023517          	auipc	a0,0x23
    800049de:	d7e50513          	addi	a0,a0,-642 # 80027758 <ftable>
    800049e2:	ffffc097          	auipc	ra,0xffffc
    800049e6:	30a080e7          	jalr	778(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    800049ea:	4785                	li	a5,1
    800049ec:	04f90463          	beq	s2,a5,80004a34 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049f0:	3979                	addiw	s2,s2,-2
    800049f2:	4785                	li	a5,1
    800049f4:	0527fb63          	bgeu	a5,s2,80004a4a <fileclose+0xbe>
    800049f8:	7902                	ld	s2,32(sp)
    800049fa:	69e2                	ld	s3,24(sp)
    800049fc:	6a42                	ld	s4,16(sp)
    800049fe:	6aa2                	ld	s5,8(sp)
    80004a00:	a02d                	j	80004a2a <fileclose+0x9e>
    80004a02:	f04a                	sd	s2,32(sp)
    80004a04:	ec4e                	sd	s3,24(sp)
    80004a06:	e852                	sd	s4,16(sp)
    80004a08:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004a0a:	00004517          	auipc	a0,0x4
    80004a0e:	b8e50513          	addi	a0,a0,-1138 # 80008598 <etext+0x598>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	b4e080e7          	jalr	-1202(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004a1a:	00023517          	auipc	a0,0x23
    80004a1e:	d3e50513          	addi	a0,a0,-706 # 80027758 <ftable>
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	2ca080e7          	jalr	714(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004a2a:	70e2                	ld	ra,56(sp)
    80004a2c:	7442                	ld	s0,48(sp)
    80004a2e:	74a2                	ld	s1,40(sp)
    80004a30:	6121                	addi	sp,sp,64
    80004a32:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a34:	85d6                	mv	a1,s5
    80004a36:	8552                	mv	a0,s4
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	3a2080e7          	jalr	930(ra) # 80004dda <pipeclose>
    80004a40:	7902                	ld	s2,32(sp)
    80004a42:	69e2                	ld	s3,24(sp)
    80004a44:	6a42                	ld	s4,16(sp)
    80004a46:	6aa2                	ld	s5,8(sp)
    80004a48:	b7cd                	j	80004a2a <fileclose+0x9e>
    begin_op();
    80004a4a:	00000097          	auipc	ra,0x0
    80004a4e:	a78080e7          	jalr	-1416(ra) # 800044c2 <begin_op>
    iput(ff.ip);
    80004a52:	854e                	mv	a0,s3
    80004a54:	fffff097          	auipc	ra,0xfffff
    80004a58:	25e080e7          	jalr	606(ra) # 80003cb2 <iput>
    end_op();
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	ae0080e7          	jalr	-1312(ra) # 8000453c <end_op>
    80004a64:	7902                	ld	s2,32(sp)
    80004a66:	69e2                	ld	s3,24(sp)
    80004a68:	6a42                	ld	s4,16(sp)
    80004a6a:	6aa2                	ld	s5,8(sp)
    80004a6c:	bf7d                	j	80004a2a <fileclose+0x9e>

0000000080004a6e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a6e:	715d                	addi	sp,sp,-80
    80004a70:	e486                	sd	ra,72(sp)
    80004a72:	e0a2                	sd	s0,64(sp)
    80004a74:	fc26                	sd	s1,56(sp)
    80004a76:	f44e                	sd	s3,40(sp)
    80004a78:	0880                	addi	s0,sp,80
    80004a7a:	84aa                	mv	s1,a0
    80004a7c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a7e:	ffffd097          	auipc	ra,0xffffd
    80004a82:	fc4080e7          	jalr	-60(ra) # 80001a42 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a86:	409c                	lw	a5,0(s1)
    80004a88:	37f9                	addiw	a5,a5,-2
    80004a8a:	4705                	li	a4,1
    80004a8c:	04f76863          	bltu	a4,a5,80004adc <filestat+0x6e>
    80004a90:	f84a                	sd	s2,48(sp)
    80004a92:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a94:	6c88                	ld	a0,24(s1)
    80004a96:	fffff097          	auipc	ra,0xfffff
    80004a9a:	05e080e7          	jalr	94(ra) # 80003af4 <ilock>
    stati(f->ip, &st);
    80004a9e:	fb840593          	addi	a1,s0,-72
    80004aa2:	6c88                	ld	a0,24(s1)
    80004aa4:	fffff097          	auipc	ra,0xfffff
    80004aa8:	2de080e7          	jalr	734(ra) # 80003d82 <stati>
    iunlock(f->ip);
    80004aac:	6c88                	ld	a0,24(s1)
    80004aae:	fffff097          	auipc	ra,0xfffff
    80004ab2:	10c080e7          	jalr	268(ra) # 80003bba <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ab6:	46e1                	li	a3,24
    80004ab8:	fb840613          	addi	a2,s0,-72
    80004abc:	85ce                	mv	a1,s3
    80004abe:	05093503          	ld	a0,80(s2)
    80004ac2:	ffffd097          	auipc	ra,0xffffd
    80004ac6:	c20080e7          	jalr	-992(ra) # 800016e2 <copyout>
    80004aca:	41f5551b          	sraiw	a0,a0,0x1f
    80004ace:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004ad0:	60a6                	ld	ra,72(sp)
    80004ad2:	6406                	ld	s0,64(sp)
    80004ad4:	74e2                	ld	s1,56(sp)
    80004ad6:	79a2                	ld	s3,40(sp)
    80004ad8:	6161                	addi	sp,sp,80
    80004ada:	8082                	ret
  return -1;
    80004adc:	557d                	li	a0,-1
    80004ade:	bfcd                	j	80004ad0 <filestat+0x62>

0000000080004ae0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ae0:	7179                	addi	sp,sp,-48
    80004ae2:	f406                	sd	ra,40(sp)
    80004ae4:	f022                	sd	s0,32(sp)
    80004ae6:	e84a                	sd	s2,16(sp)
    80004ae8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004aea:	00854783          	lbu	a5,8(a0)
    80004aee:	cbc5                	beqz	a5,80004b9e <fileread+0xbe>
    80004af0:	ec26                	sd	s1,24(sp)
    80004af2:	e44e                	sd	s3,8(sp)
    80004af4:	84aa                	mv	s1,a0
    80004af6:	89ae                	mv	s3,a1
    80004af8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004afa:	411c                	lw	a5,0(a0)
    80004afc:	4705                	li	a4,1
    80004afe:	04e78963          	beq	a5,a4,80004b50 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b02:	470d                	li	a4,3
    80004b04:	04e78f63          	beq	a5,a4,80004b62 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b08:	4709                	li	a4,2
    80004b0a:	08e79263          	bne	a5,a4,80004b8e <fileread+0xae>
    ilock(f->ip);
    80004b0e:	6d08                	ld	a0,24(a0)
    80004b10:	fffff097          	auipc	ra,0xfffff
    80004b14:	fe4080e7          	jalr	-28(ra) # 80003af4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b18:	874a                	mv	a4,s2
    80004b1a:	5094                	lw	a3,32(s1)
    80004b1c:	864e                	mv	a2,s3
    80004b1e:	4585                	li	a1,1
    80004b20:	6c88                	ld	a0,24(s1)
    80004b22:	fffff097          	auipc	ra,0xfffff
    80004b26:	28a080e7          	jalr	650(ra) # 80003dac <readi>
    80004b2a:	892a                	mv	s2,a0
    80004b2c:	00a05563          	blez	a0,80004b36 <fileread+0x56>
      f->off += r;
    80004b30:	509c                	lw	a5,32(s1)
    80004b32:	9fa9                	addw	a5,a5,a0
    80004b34:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b36:	6c88                	ld	a0,24(s1)
    80004b38:	fffff097          	auipc	ra,0xfffff
    80004b3c:	082080e7          	jalr	130(ra) # 80003bba <iunlock>
    80004b40:	64e2                	ld	s1,24(sp)
    80004b42:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004b44:	854a                	mv	a0,s2
    80004b46:	70a2                	ld	ra,40(sp)
    80004b48:	7402                	ld	s0,32(sp)
    80004b4a:	6942                	ld	s2,16(sp)
    80004b4c:	6145                	addi	sp,sp,48
    80004b4e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b50:	6908                	ld	a0,16(a0)
    80004b52:	00000097          	auipc	ra,0x0
    80004b56:	400080e7          	jalr	1024(ra) # 80004f52 <piperead>
    80004b5a:	892a                	mv	s2,a0
    80004b5c:	64e2                	ld	s1,24(sp)
    80004b5e:	69a2                	ld	s3,8(sp)
    80004b60:	b7d5                	j	80004b44 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b62:	02451783          	lh	a5,36(a0)
    80004b66:	03079693          	slli	a3,a5,0x30
    80004b6a:	92c1                	srli	a3,a3,0x30
    80004b6c:	4725                	li	a4,9
    80004b6e:	02d76a63          	bltu	a4,a3,80004ba2 <fileread+0xc2>
    80004b72:	0792                	slli	a5,a5,0x4
    80004b74:	00023717          	auipc	a4,0x23
    80004b78:	b4470713          	addi	a4,a4,-1212 # 800276b8 <devsw>
    80004b7c:	97ba                	add	a5,a5,a4
    80004b7e:	639c                	ld	a5,0(a5)
    80004b80:	c78d                	beqz	a5,80004baa <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004b82:	4505                	li	a0,1
    80004b84:	9782                	jalr	a5
    80004b86:	892a                	mv	s2,a0
    80004b88:	64e2                	ld	s1,24(sp)
    80004b8a:	69a2                	ld	s3,8(sp)
    80004b8c:	bf65                	j	80004b44 <fileread+0x64>
    panic("fileread");
    80004b8e:	00004517          	auipc	a0,0x4
    80004b92:	a1a50513          	addi	a0,a0,-1510 # 800085a8 <etext+0x5a8>
    80004b96:	ffffc097          	auipc	ra,0xffffc
    80004b9a:	9ca080e7          	jalr	-1590(ra) # 80000560 <panic>
    return -1;
    80004b9e:	597d                	li	s2,-1
    80004ba0:	b755                	j	80004b44 <fileread+0x64>
      return -1;
    80004ba2:	597d                	li	s2,-1
    80004ba4:	64e2                	ld	s1,24(sp)
    80004ba6:	69a2                	ld	s3,8(sp)
    80004ba8:	bf71                	j	80004b44 <fileread+0x64>
    80004baa:	597d                	li	s2,-1
    80004bac:	64e2                	ld	s1,24(sp)
    80004bae:	69a2                	ld	s3,8(sp)
    80004bb0:	bf51                	j	80004b44 <fileread+0x64>

0000000080004bb2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004bb2:	00954783          	lbu	a5,9(a0)
    80004bb6:	12078963          	beqz	a5,80004ce8 <filewrite+0x136>
{
    80004bba:	715d                	addi	sp,sp,-80
    80004bbc:	e486                	sd	ra,72(sp)
    80004bbe:	e0a2                	sd	s0,64(sp)
    80004bc0:	f84a                	sd	s2,48(sp)
    80004bc2:	f052                	sd	s4,32(sp)
    80004bc4:	e85a                	sd	s6,16(sp)
    80004bc6:	0880                	addi	s0,sp,80
    80004bc8:	892a                	mv	s2,a0
    80004bca:	8b2e                	mv	s6,a1
    80004bcc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bce:	411c                	lw	a5,0(a0)
    80004bd0:	4705                	li	a4,1
    80004bd2:	02e78763          	beq	a5,a4,80004c00 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bd6:	470d                	li	a4,3
    80004bd8:	02e78a63          	beq	a5,a4,80004c0c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bdc:	4709                	li	a4,2
    80004bde:	0ee79863          	bne	a5,a4,80004cce <filewrite+0x11c>
    80004be2:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004be4:	0cc05463          	blez	a2,80004cac <filewrite+0xfa>
    80004be8:	fc26                	sd	s1,56(sp)
    80004bea:	ec56                	sd	s5,24(sp)
    80004bec:	e45e                	sd	s7,8(sp)
    80004bee:	e062                	sd	s8,0(sp)
    int i = 0;
    80004bf0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004bf2:	6b85                	lui	s7,0x1
    80004bf4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004bf8:	6c05                	lui	s8,0x1
    80004bfa:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004bfe:	a851                	j	80004c92 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004c00:	6908                	ld	a0,16(a0)
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	248080e7          	jalr	584(ra) # 80004e4a <pipewrite>
    80004c0a:	a85d                	j	80004cc0 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c0c:	02451783          	lh	a5,36(a0)
    80004c10:	03079693          	slli	a3,a5,0x30
    80004c14:	92c1                	srli	a3,a3,0x30
    80004c16:	4725                	li	a4,9
    80004c18:	0cd76a63          	bltu	a4,a3,80004cec <filewrite+0x13a>
    80004c1c:	0792                	slli	a5,a5,0x4
    80004c1e:	00023717          	auipc	a4,0x23
    80004c22:	a9a70713          	addi	a4,a4,-1382 # 800276b8 <devsw>
    80004c26:	97ba                	add	a5,a5,a4
    80004c28:	679c                	ld	a5,8(a5)
    80004c2a:	c3f9                	beqz	a5,80004cf0 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004c2c:	4505                	li	a0,1
    80004c2e:	9782                	jalr	a5
    80004c30:	a841                	j	80004cc0 <filewrite+0x10e>
      if(n1 > max)
    80004c32:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004c36:	00000097          	auipc	ra,0x0
    80004c3a:	88c080e7          	jalr	-1908(ra) # 800044c2 <begin_op>
      ilock(f->ip);
    80004c3e:	01893503          	ld	a0,24(s2)
    80004c42:	fffff097          	auipc	ra,0xfffff
    80004c46:	eb2080e7          	jalr	-334(ra) # 80003af4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c4a:	8756                	mv	a4,s5
    80004c4c:	02092683          	lw	a3,32(s2)
    80004c50:	01698633          	add	a2,s3,s6
    80004c54:	4585                	li	a1,1
    80004c56:	01893503          	ld	a0,24(s2)
    80004c5a:	fffff097          	auipc	ra,0xfffff
    80004c5e:	262080e7          	jalr	610(ra) # 80003ebc <writei>
    80004c62:	84aa                	mv	s1,a0
    80004c64:	00a05763          	blez	a0,80004c72 <filewrite+0xc0>
        f->off += r;
    80004c68:	02092783          	lw	a5,32(s2)
    80004c6c:	9fa9                	addw	a5,a5,a0
    80004c6e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c72:	01893503          	ld	a0,24(s2)
    80004c76:	fffff097          	auipc	ra,0xfffff
    80004c7a:	f44080e7          	jalr	-188(ra) # 80003bba <iunlock>
      end_op();
    80004c7e:	00000097          	auipc	ra,0x0
    80004c82:	8be080e7          	jalr	-1858(ra) # 8000453c <end_op>

      if(r != n1){
    80004c86:	029a9563          	bne	s5,s1,80004cb0 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004c8a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c8e:	0149da63          	bge	s3,s4,80004ca2 <filewrite+0xf0>
      int n1 = n - i;
    80004c92:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004c96:	0004879b          	sext.w	a5,s1
    80004c9a:	f8fbdce3          	bge	s7,a5,80004c32 <filewrite+0x80>
    80004c9e:	84e2                	mv	s1,s8
    80004ca0:	bf49                	j	80004c32 <filewrite+0x80>
    80004ca2:	74e2                	ld	s1,56(sp)
    80004ca4:	6ae2                	ld	s5,24(sp)
    80004ca6:	6ba2                	ld	s7,8(sp)
    80004ca8:	6c02                	ld	s8,0(sp)
    80004caa:	a039                	j	80004cb8 <filewrite+0x106>
    int i = 0;
    80004cac:	4981                	li	s3,0
    80004cae:	a029                	j	80004cb8 <filewrite+0x106>
    80004cb0:	74e2                	ld	s1,56(sp)
    80004cb2:	6ae2                	ld	s5,24(sp)
    80004cb4:	6ba2                	ld	s7,8(sp)
    80004cb6:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004cb8:	033a1e63          	bne	s4,s3,80004cf4 <filewrite+0x142>
    80004cbc:	8552                	mv	a0,s4
    80004cbe:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004cc0:	60a6                	ld	ra,72(sp)
    80004cc2:	6406                	ld	s0,64(sp)
    80004cc4:	7942                	ld	s2,48(sp)
    80004cc6:	7a02                	ld	s4,32(sp)
    80004cc8:	6b42                	ld	s6,16(sp)
    80004cca:	6161                	addi	sp,sp,80
    80004ccc:	8082                	ret
    80004cce:	fc26                	sd	s1,56(sp)
    80004cd0:	f44e                	sd	s3,40(sp)
    80004cd2:	ec56                	sd	s5,24(sp)
    80004cd4:	e45e                	sd	s7,8(sp)
    80004cd6:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004cd8:	00004517          	auipc	a0,0x4
    80004cdc:	8e050513          	addi	a0,a0,-1824 # 800085b8 <etext+0x5b8>
    80004ce0:	ffffc097          	auipc	ra,0xffffc
    80004ce4:	880080e7          	jalr	-1920(ra) # 80000560 <panic>
    return -1;
    80004ce8:	557d                	li	a0,-1
}
    80004cea:	8082                	ret
      return -1;
    80004cec:	557d                	li	a0,-1
    80004cee:	bfc9                	j	80004cc0 <filewrite+0x10e>
    80004cf0:	557d                	li	a0,-1
    80004cf2:	b7f9                	j	80004cc0 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004cf4:	557d                	li	a0,-1
    80004cf6:	79a2                	ld	s3,40(sp)
    80004cf8:	b7e1                	j	80004cc0 <filewrite+0x10e>

0000000080004cfa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cfa:	7179                	addi	sp,sp,-48
    80004cfc:	f406                	sd	ra,40(sp)
    80004cfe:	f022                	sd	s0,32(sp)
    80004d00:	ec26                	sd	s1,24(sp)
    80004d02:	e052                	sd	s4,0(sp)
    80004d04:	1800                	addi	s0,sp,48
    80004d06:	84aa                	mv	s1,a0
    80004d08:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d0a:	0005b023          	sd	zero,0(a1)
    80004d0e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d12:	00000097          	auipc	ra,0x0
    80004d16:	bbe080e7          	jalr	-1090(ra) # 800048d0 <filealloc>
    80004d1a:	e088                	sd	a0,0(s1)
    80004d1c:	cd49                	beqz	a0,80004db6 <pipealloc+0xbc>
    80004d1e:	00000097          	auipc	ra,0x0
    80004d22:	bb2080e7          	jalr	-1102(ra) # 800048d0 <filealloc>
    80004d26:	00aa3023          	sd	a0,0(s4)
    80004d2a:	c141                	beqz	a0,80004daa <pipealloc+0xb0>
    80004d2c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d2e:	ffffc097          	auipc	ra,0xffffc
    80004d32:	e1a080e7          	jalr	-486(ra) # 80000b48 <kalloc>
    80004d36:	892a                	mv	s2,a0
    80004d38:	c13d                	beqz	a0,80004d9e <pipealloc+0xa4>
    80004d3a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004d3c:	4985                	li	s3,1
    80004d3e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d42:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d46:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d4a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d4e:	00004597          	auipc	a1,0x4
    80004d52:	87a58593          	addi	a1,a1,-1926 # 800085c8 <etext+0x5c8>
    80004d56:	ffffc097          	auipc	ra,0xffffc
    80004d5a:	e52080e7          	jalr	-430(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004d5e:	609c                	ld	a5,0(s1)
    80004d60:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d64:	609c                	ld	a5,0(s1)
    80004d66:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d6a:	609c                	ld	a5,0(s1)
    80004d6c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d70:	609c                	ld	a5,0(s1)
    80004d72:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d76:	000a3783          	ld	a5,0(s4)
    80004d7a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d7e:	000a3783          	ld	a5,0(s4)
    80004d82:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d86:	000a3783          	ld	a5,0(s4)
    80004d8a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d8e:	000a3783          	ld	a5,0(s4)
    80004d92:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d96:	4501                	li	a0,0
    80004d98:	6942                	ld	s2,16(sp)
    80004d9a:	69a2                	ld	s3,8(sp)
    80004d9c:	a03d                	j	80004dca <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d9e:	6088                	ld	a0,0(s1)
    80004da0:	c119                	beqz	a0,80004da6 <pipealloc+0xac>
    80004da2:	6942                	ld	s2,16(sp)
    80004da4:	a029                	j	80004dae <pipealloc+0xb4>
    80004da6:	6942                	ld	s2,16(sp)
    80004da8:	a039                	j	80004db6 <pipealloc+0xbc>
    80004daa:	6088                	ld	a0,0(s1)
    80004dac:	c50d                	beqz	a0,80004dd6 <pipealloc+0xdc>
    fileclose(*f0);
    80004dae:	00000097          	auipc	ra,0x0
    80004db2:	bde080e7          	jalr	-1058(ra) # 8000498c <fileclose>
  if(*f1)
    80004db6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004dba:	557d                	li	a0,-1
  if(*f1)
    80004dbc:	c799                	beqz	a5,80004dca <pipealloc+0xd0>
    fileclose(*f1);
    80004dbe:	853e                	mv	a0,a5
    80004dc0:	00000097          	auipc	ra,0x0
    80004dc4:	bcc080e7          	jalr	-1076(ra) # 8000498c <fileclose>
  return -1;
    80004dc8:	557d                	li	a0,-1
}
    80004dca:	70a2                	ld	ra,40(sp)
    80004dcc:	7402                	ld	s0,32(sp)
    80004dce:	64e2                	ld	s1,24(sp)
    80004dd0:	6a02                	ld	s4,0(sp)
    80004dd2:	6145                	addi	sp,sp,48
    80004dd4:	8082                	ret
  return -1;
    80004dd6:	557d                	li	a0,-1
    80004dd8:	bfcd                	j	80004dca <pipealloc+0xd0>

0000000080004dda <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dda:	1101                	addi	sp,sp,-32
    80004ddc:	ec06                	sd	ra,24(sp)
    80004dde:	e822                	sd	s0,16(sp)
    80004de0:	e426                	sd	s1,8(sp)
    80004de2:	e04a                	sd	s2,0(sp)
    80004de4:	1000                	addi	s0,sp,32
    80004de6:	84aa                	mv	s1,a0
    80004de8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004dea:	ffffc097          	auipc	ra,0xffffc
    80004dee:	e4e080e7          	jalr	-434(ra) # 80000c38 <acquire>
  if(writable){
    80004df2:	02090d63          	beqz	s2,80004e2c <pipeclose+0x52>
    pi->writeopen = 0;
    80004df6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004dfa:	21848513          	addi	a0,s1,536
    80004dfe:	ffffd097          	auipc	ra,0xffffd
    80004e02:	38c080e7          	jalr	908(ra) # 8000218a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e06:	2204b783          	ld	a5,544(s1)
    80004e0a:	eb95                	bnez	a5,80004e3e <pipeclose+0x64>
    release(&pi->lock);
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	ede080e7          	jalr	-290(ra) # 80000cec <release>
    kfree((char*)pi);
    80004e16:	8526                	mv	a0,s1
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	c32080e7          	jalr	-974(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004e20:	60e2                	ld	ra,24(sp)
    80004e22:	6442                	ld	s0,16(sp)
    80004e24:	64a2                	ld	s1,8(sp)
    80004e26:	6902                	ld	s2,0(sp)
    80004e28:	6105                	addi	sp,sp,32
    80004e2a:	8082                	ret
    pi->readopen = 0;
    80004e2c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e30:	21c48513          	addi	a0,s1,540
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	356080e7          	jalr	854(ra) # 8000218a <wakeup>
    80004e3c:	b7e9                	j	80004e06 <pipeclose+0x2c>
    release(&pi->lock);
    80004e3e:	8526                	mv	a0,s1
    80004e40:	ffffc097          	auipc	ra,0xffffc
    80004e44:	eac080e7          	jalr	-340(ra) # 80000cec <release>
}
    80004e48:	bfe1                	j	80004e20 <pipeclose+0x46>

0000000080004e4a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e4a:	711d                	addi	sp,sp,-96
    80004e4c:	ec86                	sd	ra,88(sp)
    80004e4e:	e8a2                	sd	s0,80(sp)
    80004e50:	e4a6                	sd	s1,72(sp)
    80004e52:	e0ca                	sd	s2,64(sp)
    80004e54:	fc4e                	sd	s3,56(sp)
    80004e56:	f852                	sd	s4,48(sp)
    80004e58:	f456                	sd	s5,40(sp)
    80004e5a:	1080                	addi	s0,sp,96
    80004e5c:	84aa                	mv	s1,a0
    80004e5e:	8aae                	mv	s5,a1
    80004e60:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e62:	ffffd097          	auipc	ra,0xffffd
    80004e66:	be0080e7          	jalr	-1056(ra) # 80001a42 <myproc>
    80004e6a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	ffffc097          	auipc	ra,0xffffc
    80004e72:	dca080e7          	jalr	-566(ra) # 80000c38 <acquire>
  while(i < n){
    80004e76:	0d405863          	blez	s4,80004f46 <pipewrite+0xfc>
    80004e7a:	f05a                	sd	s6,32(sp)
    80004e7c:	ec5e                	sd	s7,24(sp)
    80004e7e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004e80:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e82:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e84:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e88:	21c48b93          	addi	s7,s1,540
    80004e8c:	a089                	j	80004ece <pipewrite+0x84>
      release(&pi->lock);
    80004e8e:	8526                	mv	a0,s1
    80004e90:	ffffc097          	auipc	ra,0xffffc
    80004e94:	e5c080e7          	jalr	-420(ra) # 80000cec <release>
      return -1;
    80004e98:	597d                	li	s2,-1
    80004e9a:	7b02                	ld	s6,32(sp)
    80004e9c:	6be2                	ld	s7,24(sp)
    80004e9e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ea0:	854a                	mv	a0,s2
    80004ea2:	60e6                	ld	ra,88(sp)
    80004ea4:	6446                	ld	s0,80(sp)
    80004ea6:	64a6                	ld	s1,72(sp)
    80004ea8:	6906                	ld	s2,64(sp)
    80004eaa:	79e2                	ld	s3,56(sp)
    80004eac:	7a42                	ld	s4,48(sp)
    80004eae:	7aa2                	ld	s5,40(sp)
    80004eb0:	6125                	addi	sp,sp,96
    80004eb2:	8082                	ret
      wakeup(&pi->nread);
    80004eb4:	8562                	mv	a0,s8
    80004eb6:	ffffd097          	auipc	ra,0xffffd
    80004eba:	2d4080e7          	jalr	724(ra) # 8000218a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ebe:	85a6                	mv	a1,s1
    80004ec0:	855e                	mv	a0,s7
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	264080e7          	jalr	612(ra) # 80002126 <sleep>
  while(i < n){
    80004eca:	05495f63          	bge	s2,s4,80004f28 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004ece:	2204a783          	lw	a5,544(s1)
    80004ed2:	dfd5                	beqz	a5,80004e8e <pipewrite+0x44>
    80004ed4:	854e                	mv	a0,s3
    80004ed6:	ffffd097          	auipc	ra,0xffffd
    80004eda:	504080e7          	jalr	1284(ra) # 800023da <killed>
    80004ede:	f945                	bnez	a0,80004e8e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ee0:	2184a783          	lw	a5,536(s1)
    80004ee4:	21c4a703          	lw	a4,540(s1)
    80004ee8:	2007879b          	addiw	a5,a5,512
    80004eec:	fcf704e3          	beq	a4,a5,80004eb4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ef0:	4685                	li	a3,1
    80004ef2:	01590633          	add	a2,s2,s5
    80004ef6:	faf40593          	addi	a1,s0,-81
    80004efa:	0509b503          	ld	a0,80(s3)
    80004efe:	ffffd097          	auipc	ra,0xffffd
    80004f02:	870080e7          	jalr	-1936(ra) # 8000176e <copyin>
    80004f06:	05650263          	beq	a0,s6,80004f4a <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f0a:	21c4a783          	lw	a5,540(s1)
    80004f0e:	0017871b          	addiw	a4,a5,1
    80004f12:	20e4ae23          	sw	a4,540(s1)
    80004f16:	1ff7f793          	andi	a5,a5,511
    80004f1a:	97a6                	add	a5,a5,s1
    80004f1c:	faf44703          	lbu	a4,-81(s0)
    80004f20:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f24:	2905                	addiw	s2,s2,1
    80004f26:	b755                	j	80004eca <pipewrite+0x80>
    80004f28:	7b02                	ld	s6,32(sp)
    80004f2a:	6be2                	ld	s7,24(sp)
    80004f2c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004f2e:	21848513          	addi	a0,s1,536
    80004f32:	ffffd097          	auipc	ra,0xffffd
    80004f36:	258080e7          	jalr	600(ra) # 8000218a <wakeup>
  release(&pi->lock);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	ffffc097          	auipc	ra,0xffffc
    80004f40:	db0080e7          	jalr	-592(ra) # 80000cec <release>
  return i;
    80004f44:	bfb1                	j	80004ea0 <pipewrite+0x56>
  int i = 0;
    80004f46:	4901                	li	s2,0
    80004f48:	b7dd                	j	80004f2e <pipewrite+0xe4>
    80004f4a:	7b02                	ld	s6,32(sp)
    80004f4c:	6be2                	ld	s7,24(sp)
    80004f4e:	6c42                	ld	s8,16(sp)
    80004f50:	bff9                	j	80004f2e <pipewrite+0xe4>

0000000080004f52 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f52:	715d                	addi	sp,sp,-80
    80004f54:	e486                	sd	ra,72(sp)
    80004f56:	e0a2                	sd	s0,64(sp)
    80004f58:	fc26                	sd	s1,56(sp)
    80004f5a:	f84a                	sd	s2,48(sp)
    80004f5c:	f44e                	sd	s3,40(sp)
    80004f5e:	f052                	sd	s4,32(sp)
    80004f60:	ec56                	sd	s5,24(sp)
    80004f62:	0880                	addi	s0,sp,80
    80004f64:	84aa                	mv	s1,a0
    80004f66:	892e                	mv	s2,a1
    80004f68:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f6a:	ffffd097          	auipc	ra,0xffffd
    80004f6e:	ad8080e7          	jalr	-1320(ra) # 80001a42 <myproc>
    80004f72:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f74:	8526                	mv	a0,s1
    80004f76:	ffffc097          	auipc	ra,0xffffc
    80004f7a:	cc2080e7          	jalr	-830(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f7e:	2184a703          	lw	a4,536(s1)
    80004f82:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f86:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f8a:	02f71963          	bne	a4,a5,80004fbc <piperead+0x6a>
    80004f8e:	2244a783          	lw	a5,548(s1)
    80004f92:	cf95                	beqz	a5,80004fce <piperead+0x7c>
    if(killed(pr)){
    80004f94:	8552                	mv	a0,s4
    80004f96:	ffffd097          	auipc	ra,0xffffd
    80004f9a:	444080e7          	jalr	1092(ra) # 800023da <killed>
    80004f9e:	e10d                	bnez	a0,80004fc0 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fa0:	85a6                	mv	a1,s1
    80004fa2:	854e                	mv	a0,s3
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	182080e7          	jalr	386(ra) # 80002126 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fac:	2184a703          	lw	a4,536(s1)
    80004fb0:	21c4a783          	lw	a5,540(s1)
    80004fb4:	fcf70de3          	beq	a4,a5,80004f8e <piperead+0x3c>
    80004fb8:	e85a                	sd	s6,16(sp)
    80004fba:	a819                	j	80004fd0 <piperead+0x7e>
    80004fbc:	e85a                	sd	s6,16(sp)
    80004fbe:	a809                	j	80004fd0 <piperead+0x7e>
      release(&pi->lock);
    80004fc0:	8526                	mv	a0,s1
    80004fc2:	ffffc097          	auipc	ra,0xffffc
    80004fc6:	d2a080e7          	jalr	-726(ra) # 80000cec <release>
      return -1;
    80004fca:	59fd                	li	s3,-1
    80004fcc:	a0a5                	j	80005034 <piperead+0xe2>
    80004fce:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fd0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fd2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fd4:	05505463          	blez	s5,8000501c <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004fd8:	2184a783          	lw	a5,536(s1)
    80004fdc:	21c4a703          	lw	a4,540(s1)
    80004fe0:	02f70e63          	beq	a4,a5,8000501c <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fe4:	0017871b          	addiw	a4,a5,1
    80004fe8:	20e4ac23          	sw	a4,536(s1)
    80004fec:	1ff7f793          	andi	a5,a5,511
    80004ff0:	97a6                	add	a5,a5,s1
    80004ff2:	0187c783          	lbu	a5,24(a5)
    80004ff6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ffa:	4685                	li	a3,1
    80004ffc:	fbf40613          	addi	a2,s0,-65
    80005000:	85ca                	mv	a1,s2
    80005002:	050a3503          	ld	a0,80(s4)
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	6dc080e7          	jalr	1756(ra) # 800016e2 <copyout>
    8000500e:	01650763          	beq	a0,s6,8000501c <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005012:	2985                	addiw	s3,s3,1
    80005014:	0905                	addi	s2,s2,1
    80005016:	fd3a91e3          	bne	s5,s3,80004fd8 <piperead+0x86>
    8000501a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000501c:	21c48513          	addi	a0,s1,540
    80005020:	ffffd097          	auipc	ra,0xffffd
    80005024:	16a080e7          	jalr	362(ra) # 8000218a <wakeup>
  release(&pi->lock);
    80005028:	8526                	mv	a0,s1
    8000502a:	ffffc097          	auipc	ra,0xffffc
    8000502e:	cc2080e7          	jalr	-830(ra) # 80000cec <release>
    80005032:	6b42                	ld	s6,16(sp)
  return i;
}
    80005034:	854e                	mv	a0,s3
    80005036:	60a6                	ld	ra,72(sp)
    80005038:	6406                	ld	s0,64(sp)
    8000503a:	74e2                	ld	s1,56(sp)
    8000503c:	7942                	ld	s2,48(sp)
    8000503e:	79a2                	ld	s3,40(sp)
    80005040:	7a02                	ld	s4,32(sp)
    80005042:	6ae2                	ld	s5,24(sp)
    80005044:	6161                	addi	sp,sp,80
    80005046:	8082                	ret

0000000080005048 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005048:	1141                	addi	sp,sp,-16
    8000504a:	e422                	sd	s0,8(sp)
    8000504c:	0800                	addi	s0,sp,16
    8000504e:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80005050:	8905                	andi	a0,a0,1
    80005052:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80005054:	8b89                	andi	a5,a5,2
    80005056:	c399                	beqz	a5,8000505c <flags2perm+0x14>
    perm |= PTE_W;
    80005058:	00456513          	ori	a0,a0,4
  return perm;
}
    8000505c:	6422                	ld	s0,8(sp)
    8000505e:	0141                	addi	sp,sp,16
    80005060:	8082                	ret

0000000080005062 <exec>:

int exec(char *path, char **argv)
{
    80005062:	df010113          	addi	sp,sp,-528
    80005066:	20113423          	sd	ra,520(sp)
    8000506a:	20813023          	sd	s0,512(sp)
    8000506e:	ffa6                	sd	s1,504(sp)
    80005070:	fbca                	sd	s2,496(sp)
    80005072:	0c00                	addi	s0,sp,528
    80005074:	892a                	mv	s2,a0
    80005076:	dea43c23          	sd	a0,-520(s0)
    8000507a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000507e:	ffffd097          	auipc	ra,0xffffd
    80005082:	9c4080e7          	jalr	-1596(ra) # 80001a42 <myproc>
    80005086:	84aa                	mv	s1,a0

  begin_op();
    80005088:	fffff097          	auipc	ra,0xfffff
    8000508c:	43a080e7          	jalr	1082(ra) # 800044c2 <begin_op>

  if ((ip = namei(path)) == 0)
    80005090:	854a                	mv	a0,s2
    80005092:	fffff097          	auipc	ra,0xfffff
    80005096:	230080e7          	jalr	560(ra) # 800042c2 <namei>
    8000509a:	c135                	beqz	a0,800050fe <exec+0x9c>
    8000509c:	f3d2                	sd	s4,480(sp)
    8000509e:	8a2a                	mv	s4,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	a54080e7          	jalr	-1452(ra) # 80003af4 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050a8:	04000713          	li	a4,64
    800050ac:	4681                	li	a3,0
    800050ae:	e5040613          	addi	a2,s0,-432
    800050b2:	4581                	li	a1,0
    800050b4:	8552                	mv	a0,s4
    800050b6:	fffff097          	auipc	ra,0xfffff
    800050ba:	cf6080e7          	jalr	-778(ra) # 80003dac <readi>
    800050be:	04000793          	li	a5,64
    800050c2:	00f51a63          	bne	a0,a5,800050d6 <exec+0x74>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    800050c6:	e5042703          	lw	a4,-432(s0)
    800050ca:	464c47b7          	lui	a5,0x464c4
    800050ce:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050d2:	02f70c63          	beq	a4,a5,8000510a <exec+0xa8>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    800050d6:	8552                	mv	a0,s4
    800050d8:	fffff097          	auipc	ra,0xfffff
    800050dc:	c82080e7          	jalr	-894(ra) # 80003d5a <iunlockput>
    end_op();
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	45c080e7          	jalr	1116(ra) # 8000453c <end_op>
  }
  return -1;
    800050e8:	557d                	li	a0,-1
    800050ea:	7a1e                	ld	s4,480(sp)
}
    800050ec:	20813083          	ld	ra,520(sp)
    800050f0:	20013403          	ld	s0,512(sp)
    800050f4:	74fe                	ld	s1,504(sp)
    800050f6:	795e                	ld	s2,496(sp)
    800050f8:	21010113          	addi	sp,sp,528
    800050fc:	8082                	ret
    end_op();
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	43e080e7          	jalr	1086(ra) # 8000453c <end_op>
    return -1;
    80005106:	557d                	li	a0,-1
    80005108:	b7d5                	j	800050ec <exec+0x8a>
    8000510a:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    8000510c:	8526                	mv	a0,s1
    8000510e:	ffffd097          	auipc	ra,0xffffd
    80005112:	9f8080e7          	jalr	-1544(ra) # 80001b06 <proc_pagetable>
    80005116:	8b2a                	mv	s6,a0
    80005118:	30050f63          	beqz	a0,80005436 <exec+0x3d4>
    8000511c:	f7ce                	sd	s3,488(sp)
    8000511e:	efd6                	sd	s5,472(sp)
    80005120:	e7de                	sd	s7,456(sp)
    80005122:	e3e2                	sd	s8,448(sp)
    80005124:	ff66                	sd	s9,440(sp)
    80005126:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005128:	e7042d03          	lw	s10,-400(s0)
    8000512c:	e8845783          	lhu	a5,-376(s0)
    80005130:	14078d63          	beqz	a5,8000528a <exec+0x228>
    80005134:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005136:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005138:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    8000513a:	6c85                	lui	s9,0x1
    8000513c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005140:	def43823          	sd	a5,-528(s0)
  for (i = 0; i < sz; i += PGSIZE)
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80005144:	6a85                	lui	s5,0x1
    80005146:	a0b5                	j	800051b2 <exec+0x150>
      panic("loadseg: address should exist");
    80005148:	00003517          	auipc	a0,0x3
    8000514c:	48850513          	addi	a0,a0,1160 # 800085d0 <etext+0x5d0>
    80005150:	ffffb097          	auipc	ra,0xffffb
    80005154:	410080e7          	jalr	1040(ra) # 80000560 <panic>
    if (sz - i < PGSIZE)
    80005158:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    8000515a:	8726                	mv	a4,s1
    8000515c:	012c06bb          	addw	a3,s8,s2
    80005160:	4581                	li	a1,0
    80005162:	8552                	mv	a0,s4
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	c48080e7          	jalr	-952(ra) # 80003dac <readi>
    8000516c:	2501                	sext.w	a0,a0
    8000516e:	28a49863          	bne	s1,a0,800053fe <exec+0x39c>
  for (i = 0; i < sz; i += PGSIZE)
    80005172:	012a893b          	addw	s2,s5,s2
    80005176:	03397563          	bgeu	s2,s3,800051a0 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    8000517a:	02091593          	slli	a1,s2,0x20
    8000517e:	9181                	srli	a1,a1,0x20
    80005180:	95de                	add	a1,a1,s7
    80005182:	855a                	mv	a0,s6
    80005184:	ffffc097          	auipc	ra,0xffffc
    80005188:	f32080e7          	jalr	-206(ra) # 800010b6 <walkaddr>
    8000518c:	862a                	mv	a2,a0
    if (pa == 0)
    8000518e:	dd4d                	beqz	a0,80005148 <exec+0xe6>
    if (sz - i < PGSIZE)
    80005190:	412984bb          	subw	s1,s3,s2
    80005194:	0004879b          	sext.w	a5,s1
    80005198:	fcfcf0e3          	bgeu	s9,a5,80005158 <exec+0xf6>
    8000519c:	84d6                	mv	s1,s5
    8000519e:	bf6d                	j	80005158 <exec+0xf6>
    sz = sz1;
    800051a0:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800051a4:	2d85                	addiw	s11,s11,1
    800051a6:	038d0d1b          	addiw	s10,s10,56
    800051aa:	e8845783          	lhu	a5,-376(s0)
    800051ae:	08fdd663          	bge	s11,a5,8000523a <exec+0x1d8>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051b2:	2d01                	sext.w	s10,s10
    800051b4:	03800713          	li	a4,56
    800051b8:	86ea                	mv	a3,s10
    800051ba:	e1840613          	addi	a2,s0,-488
    800051be:	4581                	li	a1,0
    800051c0:	8552                	mv	a0,s4
    800051c2:	fffff097          	auipc	ra,0xfffff
    800051c6:	bea080e7          	jalr	-1046(ra) # 80003dac <readi>
    800051ca:	03800793          	li	a5,56
    800051ce:	20f51063          	bne	a0,a5,800053ce <exec+0x36c>
    if (ph.type != ELF_PROG_LOAD)
    800051d2:	e1842783          	lw	a5,-488(s0)
    800051d6:	4705                	li	a4,1
    800051d8:	fce796e3          	bne	a5,a4,800051a4 <exec+0x142>
    if (ph.memsz < ph.filesz)
    800051dc:	e4043483          	ld	s1,-448(s0)
    800051e0:	e3843783          	ld	a5,-456(s0)
    800051e4:	1ef4e963          	bltu	s1,a5,800053d6 <exec+0x374>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800051e8:	e2843783          	ld	a5,-472(s0)
    800051ec:	94be                	add	s1,s1,a5
    800051ee:	1ef4e863          	bltu	s1,a5,800053de <exec+0x37c>
    if (ph.vaddr % PGSIZE != 0)
    800051f2:	df043703          	ld	a4,-528(s0)
    800051f6:	8ff9                	and	a5,a5,a4
    800051f8:	1e079763          	bnez	a5,800053e6 <exec+0x384>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051fc:	e1c42503          	lw	a0,-484(s0)
    80005200:	00000097          	auipc	ra,0x0
    80005204:	e48080e7          	jalr	-440(ra) # 80005048 <flags2perm>
    80005208:	86aa                	mv	a3,a0
    8000520a:	8626                	mv	a2,s1
    8000520c:	85ca                	mv	a1,s2
    8000520e:	855a                	mv	a0,s6
    80005210:	ffffc097          	auipc	ra,0xffffc
    80005214:	26a080e7          	jalr	618(ra) # 8000147a <uvmalloc>
    80005218:	e0a43423          	sd	a0,-504(s0)
    8000521c:	1c050963          	beqz	a0,800053ee <exec+0x38c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005220:	e2843b83          	ld	s7,-472(s0)
    80005224:	e2042c03          	lw	s8,-480(s0)
    80005228:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    8000522c:	00098463          	beqz	s3,80005234 <exec+0x1d2>
    80005230:	4901                	li	s2,0
    80005232:	b7a1                	j	8000517a <exec+0x118>
    sz = sz1;
    80005234:	e0843903          	ld	s2,-504(s0)
    80005238:	b7b5                	j	800051a4 <exec+0x142>
    8000523a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000523c:	8552                	mv	a0,s4
    8000523e:	fffff097          	auipc	ra,0xfffff
    80005242:	b1c080e7          	jalr	-1252(ra) # 80003d5a <iunlockput>
  end_op();
    80005246:	fffff097          	auipc	ra,0xfffff
    8000524a:	2f6080e7          	jalr	758(ra) # 8000453c <end_op>
  p = myproc();
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	7f4080e7          	jalr	2036(ra) # 80001a42 <myproc>
    80005256:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005258:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000525c:	6985                	lui	s3,0x1
    8000525e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005260:	99ca                	add	s3,s3,s2
    80005262:	77fd                	lui	a5,0xfffff
    80005264:	00f9f9b3          	and	s3,s3,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    80005268:	4691                	li	a3,4
    8000526a:	6609                	lui	a2,0x2
    8000526c:	964e                	add	a2,a2,s3
    8000526e:	85ce                	mv	a1,s3
    80005270:	855a                	mv	a0,s6
    80005272:	ffffc097          	auipc	ra,0xffffc
    80005276:	208080e7          	jalr	520(ra) # 8000147a <uvmalloc>
    8000527a:	892a                	mv	s2,a0
    8000527c:	e0a43423          	sd	a0,-504(s0)
    80005280:	e519                	bnez	a0,8000528e <exec+0x22c>
  if (pagetable)
    80005282:	e1343423          	sd	s3,-504(s0)
    80005286:	4a01                	li	s4,0
    80005288:	aaa5                	j	80005400 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000528a:	4901                	li	s2,0
    8000528c:	bf45                	j	8000523c <exec+0x1da>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    8000528e:	75f9                	lui	a1,0xffffe
    80005290:	95aa                	add	a1,a1,a0
    80005292:	855a                	mv	a0,s6
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	41c080e7          	jalr	1052(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    8000529c:	7bfd                	lui	s7,0xfffff
    8000529e:	9bca                	add	s7,s7,s2
  for (argc = 0; argv[argc]; argc++)
    800052a0:	e0043783          	ld	a5,-512(s0)
    800052a4:	6388                	ld	a0,0(a5)
    800052a6:	c52d                	beqz	a0,80005310 <exec+0x2ae>
    800052a8:	e9040993          	addi	s3,s0,-368
    800052ac:	f9040c13          	addi	s8,s0,-112
    800052b0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052b2:	ffffc097          	auipc	ra,0xffffc
    800052b6:	bf6080e7          	jalr	-1034(ra) # 80000ea8 <strlen>
    800052ba:	0015079b          	addiw	a5,a0,1
    800052be:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052c2:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    800052c6:	13796863          	bltu	s2,s7,800053f6 <exec+0x394>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052ca:	e0043d03          	ld	s10,-512(s0)
    800052ce:	000d3a03          	ld	s4,0(s10)
    800052d2:	8552                	mv	a0,s4
    800052d4:	ffffc097          	auipc	ra,0xffffc
    800052d8:	bd4080e7          	jalr	-1068(ra) # 80000ea8 <strlen>
    800052dc:	0015069b          	addiw	a3,a0,1
    800052e0:	8652                	mv	a2,s4
    800052e2:	85ca                	mv	a1,s2
    800052e4:	855a                	mv	a0,s6
    800052e6:	ffffc097          	auipc	ra,0xffffc
    800052ea:	3fc080e7          	jalr	1020(ra) # 800016e2 <copyout>
    800052ee:	10054663          	bltz	a0,800053fa <exec+0x398>
    ustack[argc] = sp;
    800052f2:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    800052f6:	0485                	addi	s1,s1,1
    800052f8:	008d0793          	addi	a5,s10,8
    800052fc:	e0f43023          	sd	a5,-512(s0)
    80005300:	008d3503          	ld	a0,8(s10)
    80005304:	c909                	beqz	a0,80005316 <exec+0x2b4>
    if (argc >= MAXARG)
    80005306:	09a1                	addi	s3,s3,8
    80005308:	fb8995e3          	bne	s3,s8,800052b2 <exec+0x250>
  ip = 0;
    8000530c:	4a01                	li	s4,0
    8000530e:	a8cd                	j	80005400 <exec+0x39e>
  sp = sz;
    80005310:	e0843903          	ld	s2,-504(s0)
  for (argc = 0; argv[argc]; argc++)
    80005314:	4481                	li	s1,0
  ustack[argc] = 0;
    80005316:	00349793          	slli	a5,s1,0x3
    8000531a:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd6740>
    8000531e:	97a2                	add	a5,a5,s0
    80005320:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005324:	00148693          	addi	a3,s1,1
    80005328:	068e                	slli	a3,a3,0x3
    8000532a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000532e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005332:	e0843983          	ld	s3,-504(s0)
  if (sp < stackbase)
    80005336:	f57966e3          	bltu	s2,s7,80005282 <exec+0x220>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    8000533a:	e9040613          	addi	a2,s0,-368
    8000533e:	85ca                	mv	a1,s2
    80005340:	855a                	mv	a0,s6
    80005342:	ffffc097          	auipc	ra,0xffffc
    80005346:	3a0080e7          	jalr	928(ra) # 800016e2 <copyout>
    8000534a:	0e054863          	bltz	a0,8000543a <exec+0x3d8>
  p->trapframe->a1 = sp;
    8000534e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005352:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005356:	df843783          	ld	a5,-520(s0)
    8000535a:	0007c703          	lbu	a4,0(a5)
    8000535e:	cf11                	beqz	a4,8000537a <exec+0x318>
    80005360:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005362:	02f00693          	li	a3,47
    80005366:	a039                	j	80005374 <exec+0x312>
      last = s + 1;
    80005368:	def43c23          	sd	a5,-520(s0)
  for (last = s = path; *s; s++)
    8000536c:	0785                	addi	a5,a5,1
    8000536e:	fff7c703          	lbu	a4,-1(a5)
    80005372:	c701                	beqz	a4,8000537a <exec+0x318>
    if (*s == '/')
    80005374:	fed71ce3          	bne	a4,a3,8000536c <exec+0x30a>
    80005378:	bfc5                	j	80005368 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    8000537a:	4641                	li	a2,16
    8000537c:	df843583          	ld	a1,-520(s0)
    80005380:	158a8513          	addi	a0,s5,344
    80005384:	ffffc097          	auipc	ra,0xffffc
    80005388:	af2080e7          	jalr	-1294(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    8000538c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005390:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005394:	e0843783          	ld	a5,-504(s0)
    80005398:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry; // initial program counter = main
    8000539c:	058ab783          	ld	a5,88(s5)
    800053a0:	e6843703          	ld	a4,-408(s0)
    800053a4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    800053a6:	058ab783          	ld	a5,88(s5)
    800053aa:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053ae:	85e6                	mv	a1,s9
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	7f2080e7          	jalr	2034(ra) # 80001ba2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053b8:	0004851b          	sext.w	a0,s1
    800053bc:	79be                	ld	s3,488(sp)
    800053be:	7a1e                	ld	s4,480(sp)
    800053c0:	6afe                	ld	s5,472(sp)
    800053c2:	6b5e                	ld	s6,464(sp)
    800053c4:	6bbe                	ld	s7,456(sp)
    800053c6:	6c1e                	ld	s8,448(sp)
    800053c8:	7cfa                	ld	s9,440(sp)
    800053ca:	7d5a                	ld	s10,432(sp)
    800053cc:	b305                	j	800050ec <exec+0x8a>
    800053ce:	e1243423          	sd	s2,-504(s0)
    800053d2:	7dba                	ld	s11,424(sp)
    800053d4:	a035                	j	80005400 <exec+0x39e>
    800053d6:	e1243423          	sd	s2,-504(s0)
    800053da:	7dba                	ld	s11,424(sp)
    800053dc:	a015                	j	80005400 <exec+0x39e>
    800053de:	e1243423          	sd	s2,-504(s0)
    800053e2:	7dba                	ld	s11,424(sp)
    800053e4:	a831                	j	80005400 <exec+0x39e>
    800053e6:	e1243423          	sd	s2,-504(s0)
    800053ea:	7dba                	ld	s11,424(sp)
    800053ec:	a811                	j	80005400 <exec+0x39e>
    800053ee:	e1243423          	sd	s2,-504(s0)
    800053f2:	7dba                	ld	s11,424(sp)
    800053f4:	a031                	j	80005400 <exec+0x39e>
  ip = 0;
    800053f6:	4a01                	li	s4,0
    800053f8:	a021                	j	80005400 <exec+0x39e>
    800053fa:	4a01                	li	s4,0
  if (pagetable)
    800053fc:	a011                	j	80005400 <exec+0x39e>
    800053fe:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005400:	e0843583          	ld	a1,-504(s0)
    80005404:	855a                	mv	a0,s6
    80005406:	ffffc097          	auipc	ra,0xffffc
    8000540a:	79c080e7          	jalr	1948(ra) # 80001ba2 <proc_freepagetable>
  return -1;
    8000540e:	557d                	li	a0,-1
  if (ip)
    80005410:	000a1b63          	bnez	s4,80005426 <exec+0x3c4>
    80005414:	79be                	ld	s3,488(sp)
    80005416:	7a1e                	ld	s4,480(sp)
    80005418:	6afe                	ld	s5,472(sp)
    8000541a:	6b5e                	ld	s6,464(sp)
    8000541c:	6bbe                	ld	s7,456(sp)
    8000541e:	6c1e                	ld	s8,448(sp)
    80005420:	7cfa                	ld	s9,440(sp)
    80005422:	7d5a                	ld	s10,432(sp)
    80005424:	b1e1                	j	800050ec <exec+0x8a>
    80005426:	79be                	ld	s3,488(sp)
    80005428:	6afe                	ld	s5,472(sp)
    8000542a:	6b5e                	ld	s6,464(sp)
    8000542c:	6bbe                	ld	s7,456(sp)
    8000542e:	6c1e                	ld	s8,448(sp)
    80005430:	7cfa                	ld	s9,440(sp)
    80005432:	7d5a                	ld	s10,432(sp)
    80005434:	b14d                	j	800050d6 <exec+0x74>
    80005436:	6b5e                	ld	s6,464(sp)
    80005438:	b979                	j	800050d6 <exec+0x74>
  sz = sz1;
    8000543a:	e0843983          	ld	s3,-504(s0)
    8000543e:	b591                	j	80005282 <exec+0x220>

0000000080005440 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005440:	7179                	addi	sp,sp,-48
    80005442:	f406                	sd	ra,40(sp)
    80005444:	f022                	sd	s0,32(sp)
    80005446:	ec26                	sd	s1,24(sp)
    80005448:	e84a                	sd	s2,16(sp)
    8000544a:	1800                	addi	s0,sp,48
    8000544c:	892e                	mv	s2,a1
    8000544e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005450:	fdc40593          	addi	a1,s0,-36
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	974080e7          	jalr	-1676(ra) # 80002dc8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000545c:	fdc42703          	lw	a4,-36(s0)
    80005460:	47bd                	li	a5,15
    80005462:	02e7eb63          	bltu	a5,a4,80005498 <argfd+0x58>
    80005466:	ffffc097          	auipc	ra,0xffffc
    8000546a:	5dc080e7          	jalr	1500(ra) # 80001a42 <myproc>
    8000546e:	fdc42703          	lw	a4,-36(s0)
    80005472:	01a70793          	addi	a5,a4,26
    80005476:	078e                	slli	a5,a5,0x3
    80005478:	953e                	add	a0,a0,a5
    8000547a:	611c                	ld	a5,0(a0)
    8000547c:	c385                	beqz	a5,8000549c <argfd+0x5c>
    return -1;
  if(pfd)
    8000547e:	00090463          	beqz	s2,80005486 <argfd+0x46>
    *pfd = fd;
    80005482:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005486:	4501                	li	a0,0
  if(pf)
    80005488:	c091                	beqz	s1,8000548c <argfd+0x4c>
    *pf = f;
    8000548a:	e09c                	sd	a5,0(s1)
}
    8000548c:	70a2                	ld	ra,40(sp)
    8000548e:	7402                	ld	s0,32(sp)
    80005490:	64e2                	ld	s1,24(sp)
    80005492:	6942                	ld	s2,16(sp)
    80005494:	6145                	addi	sp,sp,48
    80005496:	8082                	ret
    return -1;
    80005498:	557d                	li	a0,-1
    8000549a:	bfcd                	j	8000548c <argfd+0x4c>
    8000549c:	557d                	li	a0,-1
    8000549e:	b7fd                	j	8000548c <argfd+0x4c>

00000000800054a0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800054a0:	1101                	addi	sp,sp,-32
    800054a2:	ec06                	sd	ra,24(sp)
    800054a4:	e822                	sd	s0,16(sp)
    800054a6:	e426                	sd	s1,8(sp)
    800054a8:	1000                	addi	s0,sp,32
    800054aa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800054ac:	ffffc097          	auipc	ra,0xffffc
    800054b0:	596080e7          	jalr	1430(ra) # 80001a42 <myproc>
    800054b4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800054b6:	0d050793          	addi	a5,a0,208
    800054ba:	4501                	li	a0,0
    800054bc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054be:	6398                	ld	a4,0(a5)
    800054c0:	cb19                	beqz	a4,800054d6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800054c2:	2505                	addiw	a0,a0,1
    800054c4:	07a1                	addi	a5,a5,8
    800054c6:	fed51ce3          	bne	a0,a3,800054be <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054ca:	557d                	li	a0,-1
}
    800054cc:	60e2                	ld	ra,24(sp)
    800054ce:	6442                	ld	s0,16(sp)
    800054d0:	64a2                	ld	s1,8(sp)
    800054d2:	6105                	addi	sp,sp,32
    800054d4:	8082                	ret
      p->ofile[fd] = f;
    800054d6:	01a50793          	addi	a5,a0,26
    800054da:	078e                	slli	a5,a5,0x3
    800054dc:	963e                	add	a2,a2,a5
    800054de:	e204                	sd	s1,0(a2)
      return fd;
    800054e0:	b7f5                	j	800054cc <fdalloc+0x2c>

00000000800054e2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054e2:	715d                	addi	sp,sp,-80
    800054e4:	e486                	sd	ra,72(sp)
    800054e6:	e0a2                	sd	s0,64(sp)
    800054e8:	fc26                	sd	s1,56(sp)
    800054ea:	f84a                	sd	s2,48(sp)
    800054ec:	f44e                	sd	s3,40(sp)
    800054ee:	ec56                	sd	s5,24(sp)
    800054f0:	e85a                	sd	s6,16(sp)
    800054f2:	0880                	addi	s0,sp,80
    800054f4:	8b2e                	mv	s6,a1
    800054f6:	89b2                	mv	s3,a2
    800054f8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800054fa:	fb040593          	addi	a1,s0,-80
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	de2080e7          	jalr	-542(ra) # 800042e0 <nameiparent>
    80005506:	84aa                	mv	s1,a0
    80005508:	14050e63          	beqz	a0,80005664 <create+0x182>
    return 0;

  ilock(dp);
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	5e8080e7          	jalr	1512(ra) # 80003af4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005514:	4601                	li	a2,0
    80005516:	fb040593          	addi	a1,s0,-80
    8000551a:	8526                	mv	a0,s1
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	ae4080e7          	jalr	-1308(ra) # 80004000 <dirlookup>
    80005524:	8aaa                	mv	s5,a0
    80005526:	c539                	beqz	a0,80005574 <create+0x92>
    iunlockput(dp);
    80005528:	8526                	mv	a0,s1
    8000552a:	fffff097          	auipc	ra,0xfffff
    8000552e:	830080e7          	jalr	-2000(ra) # 80003d5a <iunlockput>
    ilock(ip);
    80005532:	8556                	mv	a0,s5
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	5c0080e7          	jalr	1472(ra) # 80003af4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000553c:	4789                	li	a5,2
    8000553e:	02fb1463          	bne	s6,a5,80005566 <create+0x84>
    80005542:	044ad783          	lhu	a5,68(s5)
    80005546:	37f9                	addiw	a5,a5,-2
    80005548:	17c2                	slli	a5,a5,0x30
    8000554a:	93c1                	srli	a5,a5,0x30
    8000554c:	4705                	li	a4,1
    8000554e:	00f76c63          	bltu	a4,a5,80005566 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005552:	8556                	mv	a0,s5
    80005554:	60a6                	ld	ra,72(sp)
    80005556:	6406                	ld	s0,64(sp)
    80005558:	74e2                	ld	s1,56(sp)
    8000555a:	7942                	ld	s2,48(sp)
    8000555c:	79a2                	ld	s3,40(sp)
    8000555e:	6ae2                	ld	s5,24(sp)
    80005560:	6b42                	ld	s6,16(sp)
    80005562:	6161                	addi	sp,sp,80
    80005564:	8082                	ret
    iunlockput(ip);
    80005566:	8556                	mv	a0,s5
    80005568:	ffffe097          	auipc	ra,0xffffe
    8000556c:	7f2080e7          	jalr	2034(ra) # 80003d5a <iunlockput>
    return 0;
    80005570:	4a81                	li	s5,0
    80005572:	b7c5                	j	80005552 <create+0x70>
    80005574:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005576:	85da                	mv	a1,s6
    80005578:	4088                	lw	a0,0(s1)
    8000557a:	ffffe097          	auipc	ra,0xffffe
    8000557e:	3d6080e7          	jalr	982(ra) # 80003950 <ialloc>
    80005582:	8a2a                	mv	s4,a0
    80005584:	c531                	beqz	a0,800055d0 <create+0xee>
  ilock(ip);
    80005586:	ffffe097          	auipc	ra,0xffffe
    8000558a:	56e080e7          	jalr	1390(ra) # 80003af4 <ilock>
  ip->major = major;
    8000558e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005592:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005596:	4905                	li	s2,1
    80005598:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000559c:	8552                	mv	a0,s4
    8000559e:	ffffe097          	auipc	ra,0xffffe
    800055a2:	48a080e7          	jalr	1162(ra) # 80003a28 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055a6:	032b0d63          	beq	s6,s2,800055e0 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800055aa:	004a2603          	lw	a2,4(s4)
    800055ae:	fb040593          	addi	a1,s0,-80
    800055b2:	8526                	mv	a0,s1
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	c5c080e7          	jalr	-932(ra) # 80004210 <dirlink>
    800055bc:	08054163          	bltz	a0,8000563e <create+0x15c>
  iunlockput(dp);
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	798080e7          	jalr	1944(ra) # 80003d5a <iunlockput>
  return ip;
    800055ca:	8ad2                	mv	s5,s4
    800055cc:	7a02                	ld	s4,32(sp)
    800055ce:	b751                	j	80005552 <create+0x70>
    iunlockput(dp);
    800055d0:	8526                	mv	a0,s1
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	788080e7          	jalr	1928(ra) # 80003d5a <iunlockput>
    return 0;
    800055da:	8ad2                	mv	s5,s4
    800055dc:	7a02                	ld	s4,32(sp)
    800055de:	bf95                	j	80005552 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055e0:	004a2603          	lw	a2,4(s4)
    800055e4:	00003597          	auipc	a1,0x3
    800055e8:	00c58593          	addi	a1,a1,12 # 800085f0 <etext+0x5f0>
    800055ec:	8552                	mv	a0,s4
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	c22080e7          	jalr	-990(ra) # 80004210 <dirlink>
    800055f6:	04054463          	bltz	a0,8000563e <create+0x15c>
    800055fa:	40d0                	lw	a2,4(s1)
    800055fc:	00003597          	auipc	a1,0x3
    80005600:	ffc58593          	addi	a1,a1,-4 # 800085f8 <etext+0x5f8>
    80005604:	8552                	mv	a0,s4
    80005606:	fffff097          	auipc	ra,0xfffff
    8000560a:	c0a080e7          	jalr	-1014(ra) # 80004210 <dirlink>
    8000560e:	02054863          	bltz	a0,8000563e <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005612:	004a2603          	lw	a2,4(s4)
    80005616:	fb040593          	addi	a1,s0,-80
    8000561a:	8526                	mv	a0,s1
    8000561c:	fffff097          	auipc	ra,0xfffff
    80005620:	bf4080e7          	jalr	-1036(ra) # 80004210 <dirlink>
    80005624:	00054d63          	bltz	a0,8000563e <create+0x15c>
    dp->nlink++;  // for ".."
    80005628:	04a4d783          	lhu	a5,74(s1)
    8000562c:	2785                	addiw	a5,a5,1
    8000562e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005632:	8526                	mv	a0,s1
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	3f4080e7          	jalr	1012(ra) # 80003a28 <iupdate>
    8000563c:	b751                	j	800055c0 <create+0xde>
  ip->nlink = 0;
    8000563e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005642:	8552                	mv	a0,s4
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	3e4080e7          	jalr	996(ra) # 80003a28 <iupdate>
  iunlockput(ip);
    8000564c:	8552                	mv	a0,s4
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	70c080e7          	jalr	1804(ra) # 80003d5a <iunlockput>
  iunlockput(dp);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	702080e7          	jalr	1794(ra) # 80003d5a <iunlockput>
  return 0;
    80005660:	7a02                	ld	s4,32(sp)
    80005662:	bdc5                	j	80005552 <create+0x70>
    return 0;
    80005664:	8aaa                	mv	s5,a0
    80005666:	b5f5                	j	80005552 <create+0x70>

0000000080005668 <sys_dup>:
{
    80005668:	7179                	addi	sp,sp,-48
    8000566a:	f406                	sd	ra,40(sp)
    8000566c:	f022                	sd	s0,32(sp)
    8000566e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005670:	fd840613          	addi	a2,s0,-40
    80005674:	4581                	li	a1,0
    80005676:	4501                	li	a0,0
    80005678:	00000097          	auipc	ra,0x0
    8000567c:	dc8080e7          	jalr	-568(ra) # 80005440 <argfd>
    return -1;
    80005680:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005682:	02054763          	bltz	a0,800056b0 <sys_dup+0x48>
    80005686:	ec26                	sd	s1,24(sp)
    80005688:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000568a:	fd843903          	ld	s2,-40(s0)
    8000568e:	854a                	mv	a0,s2
    80005690:	00000097          	auipc	ra,0x0
    80005694:	e10080e7          	jalr	-496(ra) # 800054a0 <fdalloc>
    80005698:	84aa                	mv	s1,a0
    return -1;
    8000569a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000569c:	00054f63          	bltz	a0,800056ba <sys_dup+0x52>
  filedup(f);
    800056a0:	854a                	mv	a0,s2
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	298080e7          	jalr	664(ra) # 8000493a <filedup>
  return fd;
    800056aa:	87a6                	mv	a5,s1
    800056ac:	64e2                	ld	s1,24(sp)
    800056ae:	6942                	ld	s2,16(sp)
}
    800056b0:	853e                	mv	a0,a5
    800056b2:	70a2                	ld	ra,40(sp)
    800056b4:	7402                	ld	s0,32(sp)
    800056b6:	6145                	addi	sp,sp,48
    800056b8:	8082                	ret
    800056ba:	64e2                	ld	s1,24(sp)
    800056bc:	6942                	ld	s2,16(sp)
    800056be:	bfcd                	j	800056b0 <sys_dup+0x48>

00000000800056c0 <sys_read>:
{
    800056c0:	7179                	addi	sp,sp,-48
    800056c2:	f406                	sd	ra,40(sp)
    800056c4:	f022                	sd	s0,32(sp)
    800056c6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056c8:	fd840593          	addi	a1,s0,-40
    800056cc:	4505                	li	a0,1
    800056ce:	ffffd097          	auipc	ra,0xffffd
    800056d2:	71a080e7          	jalr	1818(ra) # 80002de8 <argaddr>
  argint(2, &n);
    800056d6:	fe440593          	addi	a1,s0,-28
    800056da:	4509                	li	a0,2
    800056dc:	ffffd097          	auipc	ra,0xffffd
    800056e0:	6ec080e7          	jalr	1772(ra) # 80002dc8 <argint>
  if(argfd(0, 0, &f) < 0)
    800056e4:	fe840613          	addi	a2,s0,-24
    800056e8:	4581                	li	a1,0
    800056ea:	4501                	li	a0,0
    800056ec:	00000097          	auipc	ra,0x0
    800056f0:	d54080e7          	jalr	-684(ra) # 80005440 <argfd>
    800056f4:	87aa                	mv	a5,a0
    return -1;
    800056f6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056f8:	0007cc63          	bltz	a5,80005710 <sys_read+0x50>
  return fileread(f, p, n);
    800056fc:	fe442603          	lw	a2,-28(s0)
    80005700:	fd843583          	ld	a1,-40(s0)
    80005704:	fe843503          	ld	a0,-24(s0)
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	3d8080e7          	jalr	984(ra) # 80004ae0 <fileread>
}
    80005710:	70a2                	ld	ra,40(sp)
    80005712:	7402                	ld	s0,32(sp)
    80005714:	6145                	addi	sp,sp,48
    80005716:	8082                	ret

0000000080005718 <sys_write>:
{
    80005718:	7179                	addi	sp,sp,-48
    8000571a:	f406                	sd	ra,40(sp)
    8000571c:	f022                	sd	s0,32(sp)
    8000571e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005720:	fd840593          	addi	a1,s0,-40
    80005724:	4505                	li	a0,1
    80005726:	ffffd097          	auipc	ra,0xffffd
    8000572a:	6c2080e7          	jalr	1730(ra) # 80002de8 <argaddr>
  argint(2, &n);
    8000572e:	fe440593          	addi	a1,s0,-28
    80005732:	4509                	li	a0,2
    80005734:	ffffd097          	auipc	ra,0xffffd
    80005738:	694080e7          	jalr	1684(ra) # 80002dc8 <argint>
  if(argfd(0, 0, &f) < 0)
    8000573c:	fe840613          	addi	a2,s0,-24
    80005740:	4581                	li	a1,0
    80005742:	4501                	li	a0,0
    80005744:	00000097          	auipc	ra,0x0
    80005748:	cfc080e7          	jalr	-772(ra) # 80005440 <argfd>
    8000574c:	87aa                	mv	a5,a0
    return -1;
    8000574e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005750:	0007cc63          	bltz	a5,80005768 <sys_write+0x50>
  return filewrite(f, p, n);
    80005754:	fe442603          	lw	a2,-28(s0)
    80005758:	fd843583          	ld	a1,-40(s0)
    8000575c:	fe843503          	ld	a0,-24(s0)
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	452080e7          	jalr	1106(ra) # 80004bb2 <filewrite>
}
    80005768:	70a2                	ld	ra,40(sp)
    8000576a:	7402                	ld	s0,32(sp)
    8000576c:	6145                	addi	sp,sp,48
    8000576e:	8082                	ret

0000000080005770 <sys_close>:
{
    80005770:	1101                	addi	sp,sp,-32
    80005772:	ec06                	sd	ra,24(sp)
    80005774:	e822                	sd	s0,16(sp)
    80005776:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005778:	fe040613          	addi	a2,s0,-32
    8000577c:	fec40593          	addi	a1,s0,-20
    80005780:	4501                	li	a0,0
    80005782:	00000097          	auipc	ra,0x0
    80005786:	cbe080e7          	jalr	-834(ra) # 80005440 <argfd>
    return -1;
    8000578a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000578c:	02054463          	bltz	a0,800057b4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005790:	ffffc097          	auipc	ra,0xffffc
    80005794:	2b2080e7          	jalr	690(ra) # 80001a42 <myproc>
    80005798:	fec42783          	lw	a5,-20(s0)
    8000579c:	07e9                	addi	a5,a5,26
    8000579e:	078e                	slli	a5,a5,0x3
    800057a0:	953e                	add	a0,a0,a5
    800057a2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800057a6:	fe043503          	ld	a0,-32(s0)
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	1e2080e7          	jalr	482(ra) # 8000498c <fileclose>
  return 0;
    800057b2:	4781                	li	a5,0
}
    800057b4:	853e                	mv	a0,a5
    800057b6:	60e2                	ld	ra,24(sp)
    800057b8:	6442                	ld	s0,16(sp)
    800057ba:	6105                	addi	sp,sp,32
    800057bc:	8082                	ret

00000000800057be <sys_fstat>:
{
    800057be:	1101                	addi	sp,sp,-32
    800057c0:	ec06                	sd	ra,24(sp)
    800057c2:	e822                	sd	s0,16(sp)
    800057c4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057c6:	fe040593          	addi	a1,s0,-32
    800057ca:	4505                	li	a0,1
    800057cc:	ffffd097          	auipc	ra,0xffffd
    800057d0:	61c080e7          	jalr	1564(ra) # 80002de8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057d4:	fe840613          	addi	a2,s0,-24
    800057d8:	4581                	li	a1,0
    800057da:	4501                	li	a0,0
    800057dc:	00000097          	auipc	ra,0x0
    800057e0:	c64080e7          	jalr	-924(ra) # 80005440 <argfd>
    800057e4:	87aa                	mv	a5,a0
    return -1;
    800057e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057e8:	0007ca63          	bltz	a5,800057fc <sys_fstat+0x3e>
  return filestat(f, st);
    800057ec:	fe043583          	ld	a1,-32(s0)
    800057f0:	fe843503          	ld	a0,-24(s0)
    800057f4:	fffff097          	auipc	ra,0xfffff
    800057f8:	27a080e7          	jalr	634(ra) # 80004a6e <filestat>
}
    800057fc:	60e2                	ld	ra,24(sp)
    800057fe:	6442                	ld	s0,16(sp)
    80005800:	6105                	addi	sp,sp,32
    80005802:	8082                	ret

0000000080005804 <sys_link>:
{
    80005804:	7169                	addi	sp,sp,-304
    80005806:	f606                	sd	ra,296(sp)
    80005808:	f222                	sd	s0,288(sp)
    8000580a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000580c:	08000613          	li	a2,128
    80005810:	ed040593          	addi	a1,s0,-304
    80005814:	4501                	li	a0,0
    80005816:	ffffd097          	auipc	ra,0xffffd
    8000581a:	5f2080e7          	jalr	1522(ra) # 80002e08 <argstr>
    return -1;
    8000581e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005820:	12054663          	bltz	a0,8000594c <sys_link+0x148>
    80005824:	08000613          	li	a2,128
    80005828:	f5040593          	addi	a1,s0,-176
    8000582c:	4505                	li	a0,1
    8000582e:	ffffd097          	auipc	ra,0xffffd
    80005832:	5da080e7          	jalr	1498(ra) # 80002e08 <argstr>
    return -1;
    80005836:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005838:	10054a63          	bltz	a0,8000594c <sys_link+0x148>
    8000583c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	c84080e7          	jalr	-892(ra) # 800044c2 <begin_op>
  if((ip = namei(old)) == 0){
    80005846:	ed040513          	addi	a0,s0,-304
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	a78080e7          	jalr	-1416(ra) # 800042c2 <namei>
    80005852:	84aa                	mv	s1,a0
    80005854:	c949                	beqz	a0,800058e6 <sys_link+0xe2>
  ilock(ip);
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	29e080e7          	jalr	670(ra) # 80003af4 <ilock>
  if(ip->type == T_DIR){
    8000585e:	04449703          	lh	a4,68(s1)
    80005862:	4785                	li	a5,1
    80005864:	08f70863          	beq	a4,a5,800058f4 <sys_link+0xf0>
    80005868:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000586a:	04a4d783          	lhu	a5,74(s1)
    8000586e:	2785                	addiw	a5,a5,1
    80005870:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005874:	8526                	mv	a0,s1
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	1b2080e7          	jalr	434(ra) # 80003a28 <iupdate>
  iunlock(ip);
    8000587e:	8526                	mv	a0,s1
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	33a080e7          	jalr	826(ra) # 80003bba <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005888:	fd040593          	addi	a1,s0,-48
    8000588c:	f5040513          	addi	a0,s0,-176
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	a50080e7          	jalr	-1456(ra) # 800042e0 <nameiparent>
    80005898:	892a                	mv	s2,a0
    8000589a:	cd35                	beqz	a0,80005916 <sys_link+0x112>
  ilock(dp);
    8000589c:	ffffe097          	auipc	ra,0xffffe
    800058a0:	258080e7          	jalr	600(ra) # 80003af4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800058a4:	00092703          	lw	a4,0(s2)
    800058a8:	409c                	lw	a5,0(s1)
    800058aa:	06f71163          	bne	a4,a5,8000590c <sys_link+0x108>
    800058ae:	40d0                	lw	a2,4(s1)
    800058b0:	fd040593          	addi	a1,s0,-48
    800058b4:	854a                	mv	a0,s2
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	95a080e7          	jalr	-1702(ra) # 80004210 <dirlink>
    800058be:	04054763          	bltz	a0,8000590c <sys_link+0x108>
  iunlockput(dp);
    800058c2:	854a                	mv	a0,s2
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	496080e7          	jalr	1174(ra) # 80003d5a <iunlockput>
  iput(ip);
    800058cc:	8526                	mv	a0,s1
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	3e4080e7          	jalr	996(ra) # 80003cb2 <iput>
  end_op();
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	c66080e7          	jalr	-922(ra) # 8000453c <end_op>
  return 0;
    800058de:	4781                	li	a5,0
    800058e0:	64f2                	ld	s1,280(sp)
    800058e2:	6952                	ld	s2,272(sp)
    800058e4:	a0a5                	j	8000594c <sys_link+0x148>
    end_op();
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	c56080e7          	jalr	-938(ra) # 8000453c <end_op>
    return -1;
    800058ee:	57fd                	li	a5,-1
    800058f0:	64f2                	ld	s1,280(sp)
    800058f2:	a8a9                	j	8000594c <sys_link+0x148>
    iunlockput(ip);
    800058f4:	8526                	mv	a0,s1
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	464080e7          	jalr	1124(ra) # 80003d5a <iunlockput>
    end_op();
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	c3e080e7          	jalr	-962(ra) # 8000453c <end_op>
    return -1;
    80005906:	57fd                	li	a5,-1
    80005908:	64f2                	ld	s1,280(sp)
    8000590a:	a089                	j	8000594c <sys_link+0x148>
    iunlockput(dp);
    8000590c:	854a                	mv	a0,s2
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	44c080e7          	jalr	1100(ra) # 80003d5a <iunlockput>
  ilock(ip);
    80005916:	8526                	mv	a0,s1
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	1dc080e7          	jalr	476(ra) # 80003af4 <ilock>
  ip->nlink--;
    80005920:	04a4d783          	lhu	a5,74(s1)
    80005924:	37fd                	addiw	a5,a5,-1
    80005926:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000592a:	8526                	mv	a0,s1
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	0fc080e7          	jalr	252(ra) # 80003a28 <iupdate>
  iunlockput(ip);
    80005934:	8526                	mv	a0,s1
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	424080e7          	jalr	1060(ra) # 80003d5a <iunlockput>
  end_op();
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	bfe080e7          	jalr	-1026(ra) # 8000453c <end_op>
  return -1;
    80005946:	57fd                	li	a5,-1
    80005948:	64f2                	ld	s1,280(sp)
    8000594a:	6952                	ld	s2,272(sp)
}
    8000594c:	853e                	mv	a0,a5
    8000594e:	70b2                	ld	ra,296(sp)
    80005950:	7412                	ld	s0,288(sp)
    80005952:	6155                	addi	sp,sp,304
    80005954:	8082                	ret

0000000080005956 <sys_unlink>:
{
    80005956:	7151                	addi	sp,sp,-240
    80005958:	f586                	sd	ra,232(sp)
    8000595a:	f1a2                	sd	s0,224(sp)
    8000595c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000595e:	08000613          	li	a2,128
    80005962:	f3040593          	addi	a1,s0,-208
    80005966:	4501                	li	a0,0
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	4a0080e7          	jalr	1184(ra) # 80002e08 <argstr>
    80005970:	1a054a63          	bltz	a0,80005b24 <sys_unlink+0x1ce>
    80005974:	eda6                	sd	s1,216(sp)
  begin_op();
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	b4c080e7          	jalr	-1204(ra) # 800044c2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000597e:	fb040593          	addi	a1,s0,-80
    80005982:	f3040513          	addi	a0,s0,-208
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	95a080e7          	jalr	-1702(ra) # 800042e0 <nameiparent>
    8000598e:	84aa                	mv	s1,a0
    80005990:	cd71                	beqz	a0,80005a6c <sys_unlink+0x116>
  ilock(dp);
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	162080e7          	jalr	354(ra) # 80003af4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000599a:	00003597          	auipc	a1,0x3
    8000599e:	c5658593          	addi	a1,a1,-938 # 800085f0 <etext+0x5f0>
    800059a2:	fb040513          	addi	a0,s0,-80
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	640080e7          	jalr	1600(ra) # 80003fe6 <namecmp>
    800059ae:	14050c63          	beqz	a0,80005b06 <sys_unlink+0x1b0>
    800059b2:	00003597          	auipc	a1,0x3
    800059b6:	c4658593          	addi	a1,a1,-954 # 800085f8 <etext+0x5f8>
    800059ba:	fb040513          	addi	a0,s0,-80
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	628080e7          	jalr	1576(ra) # 80003fe6 <namecmp>
    800059c6:	14050063          	beqz	a0,80005b06 <sys_unlink+0x1b0>
    800059ca:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059cc:	f2c40613          	addi	a2,s0,-212
    800059d0:	fb040593          	addi	a1,s0,-80
    800059d4:	8526                	mv	a0,s1
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	62a080e7          	jalr	1578(ra) # 80004000 <dirlookup>
    800059de:	892a                	mv	s2,a0
    800059e0:	12050263          	beqz	a0,80005b04 <sys_unlink+0x1ae>
  ilock(ip);
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	110080e7          	jalr	272(ra) # 80003af4 <ilock>
  if(ip->nlink < 1)
    800059ec:	04a91783          	lh	a5,74(s2)
    800059f0:	08f05563          	blez	a5,80005a7a <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059f4:	04491703          	lh	a4,68(s2)
    800059f8:	4785                	li	a5,1
    800059fa:	08f70963          	beq	a4,a5,80005a8c <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800059fe:	4641                	li	a2,16
    80005a00:	4581                	li	a1,0
    80005a02:	fc040513          	addi	a0,s0,-64
    80005a06:	ffffb097          	auipc	ra,0xffffb
    80005a0a:	32e080e7          	jalr	814(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a0e:	4741                	li	a4,16
    80005a10:	f2c42683          	lw	a3,-212(s0)
    80005a14:	fc040613          	addi	a2,s0,-64
    80005a18:	4581                	li	a1,0
    80005a1a:	8526                	mv	a0,s1
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	4a0080e7          	jalr	1184(ra) # 80003ebc <writei>
    80005a24:	47c1                	li	a5,16
    80005a26:	0af51b63          	bne	a0,a5,80005adc <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005a2a:	04491703          	lh	a4,68(s2)
    80005a2e:	4785                	li	a5,1
    80005a30:	0af70f63          	beq	a4,a5,80005aee <sys_unlink+0x198>
  iunlockput(dp);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	324080e7          	jalr	804(ra) # 80003d5a <iunlockput>
  ip->nlink--;
    80005a3e:	04a95783          	lhu	a5,74(s2)
    80005a42:	37fd                	addiw	a5,a5,-1
    80005a44:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a48:	854a                	mv	a0,s2
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	fde080e7          	jalr	-34(ra) # 80003a28 <iupdate>
  iunlockput(ip);
    80005a52:	854a                	mv	a0,s2
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	306080e7          	jalr	774(ra) # 80003d5a <iunlockput>
  end_op();
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	ae0080e7          	jalr	-1312(ra) # 8000453c <end_op>
  return 0;
    80005a64:	4501                	li	a0,0
    80005a66:	64ee                	ld	s1,216(sp)
    80005a68:	694e                	ld	s2,208(sp)
    80005a6a:	a84d                	j	80005b1c <sys_unlink+0x1c6>
    end_op();
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	ad0080e7          	jalr	-1328(ra) # 8000453c <end_op>
    return -1;
    80005a74:	557d                	li	a0,-1
    80005a76:	64ee                	ld	s1,216(sp)
    80005a78:	a055                	j	80005b1c <sys_unlink+0x1c6>
    80005a7a:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005a7c:	00003517          	auipc	a0,0x3
    80005a80:	b8450513          	addi	a0,a0,-1148 # 80008600 <etext+0x600>
    80005a84:	ffffb097          	auipc	ra,0xffffb
    80005a88:	adc080e7          	jalr	-1316(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a8c:	04c92703          	lw	a4,76(s2)
    80005a90:	02000793          	li	a5,32
    80005a94:	f6e7f5e3          	bgeu	a5,a4,800059fe <sys_unlink+0xa8>
    80005a98:	e5ce                	sd	s3,200(sp)
    80005a9a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a9e:	4741                	li	a4,16
    80005aa0:	86ce                	mv	a3,s3
    80005aa2:	f1840613          	addi	a2,s0,-232
    80005aa6:	4581                	li	a1,0
    80005aa8:	854a                	mv	a0,s2
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	302080e7          	jalr	770(ra) # 80003dac <readi>
    80005ab2:	47c1                	li	a5,16
    80005ab4:	00f51c63          	bne	a0,a5,80005acc <sys_unlink+0x176>
    if(de.inum != 0)
    80005ab8:	f1845783          	lhu	a5,-232(s0)
    80005abc:	e7b5                	bnez	a5,80005b28 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005abe:	29c1                	addiw	s3,s3,16
    80005ac0:	04c92783          	lw	a5,76(s2)
    80005ac4:	fcf9ede3          	bltu	s3,a5,80005a9e <sys_unlink+0x148>
    80005ac8:	69ae                	ld	s3,200(sp)
    80005aca:	bf15                	j	800059fe <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005acc:	00003517          	auipc	a0,0x3
    80005ad0:	b4c50513          	addi	a0,a0,-1204 # 80008618 <etext+0x618>
    80005ad4:	ffffb097          	auipc	ra,0xffffb
    80005ad8:	a8c080e7          	jalr	-1396(ra) # 80000560 <panic>
    80005adc:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005ade:	00003517          	auipc	a0,0x3
    80005ae2:	b5250513          	addi	a0,a0,-1198 # 80008630 <etext+0x630>
    80005ae6:	ffffb097          	auipc	ra,0xffffb
    80005aea:	a7a080e7          	jalr	-1414(ra) # 80000560 <panic>
    dp->nlink--;
    80005aee:	04a4d783          	lhu	a5,74(s1)
    80005af2:	37fd                	addiw	a5,a5,-1
    80005af4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005af8:	8526                	mv	a0,s1
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	f2e080e7          	jalr	-210(ra) # 80003a28 <iupdate>
    80005b02:	bf0d                	j	80005a34 <sys_unlink+0xde>
    80005b04:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005b06:	8526                	mv	a0,s1
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	252080e7          	jalr	594(ra) # 80003d5a <iunlockput>
  end_op();
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	a2c080e7          	jalr	-1492(ra) # 8000453c <end_op>
  return -1;
    80005b18:	557d                	li	a0,-1
    80005b1a:	64ee                	ld	s1,216(sp)
}
    80005b1c:	70ae                	ld	ra,232(sp)
    80005b1e:	740e                	ld	s0,224(sp)
    80005b20:	616d                	addi	sp,sp,240
    80005b22:	8082                	ret
    return -1;
    80005b24:	557d                	li	a0,-1
    80005b26:	bfdd                	j	80005b1c <sys_unlink+0x1c6>
    iunlockput(ip);
    80005b28:	854a                	mv	a0,s2
    80005b2a:	ffffe097          	auipc	ra,0xffffe
    80005b2e:	230080e7          	jalr	560(ra) # 80003d5a <iunlockput>
    goto bad;
    80005b32:	694e                	ld	s2,208(sp)
    80005b34:	69ae                	ld	s3,200(sp)
    80005b36:	bfc1                	j	80005b06 <sys_unlink+0x1b0>

0000000080005b38 <sys_open>:

uint64
sys_open(void)
{
    80005b38:	7131                	addi	sp,sp,-192
    80005b3a:	fd06                	sd	ra,184(sp)
    80005b3c:	f922                	sd	s0,176(sp)
    80005b3e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b40:	f4c40593          	addi	a1,s0,-180
    80005b44:	4505                	li	a0,1
    80005b46:	ffffd097          	auipc	ra,0xffffd
    80005b4a:	282080e7          	jalr	642(ra) # 80002dc8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b4e:	08000613          	li	a2,128
    80005b52:	f5040593          	addi	a1,s0,-176
    80005b56:	4501                	li	a0,0
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	2b0080e7          	jalr	688(ra) # 80002e08 <argstr>
    80005b60:	87aa                	mv	a5,a0
    return -1;
    80005b62:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b64:	0a07ce63          	bltz	a5,80005c20 <sys_open+0xe8>
    80005b68:	f526                	sd	s1,168(sp)

  begin_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	958080e7          	jalr	-1704(ra) # 800044c2 <begin_op>

  if(omode & O_CREATE){
    80005b72:	f4c42783          	lw	a5,-180(s0)
    80005b76:	2007f793          	andi	a5,a5,512
    80005b7a:	cfd5                	beqz	a5,80005c36 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b7c:	4681                	li	a3,0
    80005b7e:	4601                	li	a2,0
    80005b80:	4589                	li	a1,2
    80005b82:	f5040513          	addi	a0,s0,-176
    80005b86:	00000097          	auipc	ra,0x0
    80005b8a:	95c080e7          	jalr	-1700(ra) # 800054e2 <create>
    80005b8e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b90:	cd41                	beqz	a0,80005c28 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b92:	04449703          	lh	a4,68(s1)
    80005b96:	478d                	li	a5,3
    80005b98:	00f71763          	bne	a4,a5,80005ba6 <sys_open+0x6e>
    80005b9c:	0464d703          	lhu	a4,70(s1)
    80005ba0:	47a5                	li	a5,9
    80005ba2:	0ee7e163          	bltu	a5,a4,80005c84 <sys_open+0x14c>
    80005ba6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	d28080e7          	jalr	-728(ra) # 800048d0 <filealloc>
    80005bb0:	892a                	mv	s2,a0
    80005bb2:	c97d                	beqz	a0,80005ca8 <sys_open+0x170>
    80005bb4:	ed4e                	sd	s3,152(sp)
    80005bb6:	00000097          	auipc	ra,0x0
    80005bba:	8ea080e7          	jalr	-1814(ra) # 800054a0 <fdalloc>
    80005bbe:	89aa                	mv	s3,a0
    80005bc0:	0c054e63          	bltz	a0,80005c9c <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005bc4:	04449703          	lh	a4,68(s1)
    80005bc8:	478d                	li	a5,3
    80005bca:	0ef70c63          	beq	a4,a5,80005cc2 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005bce:	4789                	li	a5,2
    80005bd0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005bd4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005bd8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005bdc:	f4c42783          	lw	a5,-180(s0)
    80005be0:	0017c713          	xori	a4,a5,1
    80005be4:	8b05                	andi	a4,a4,1
    80005be6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005bea:	0037f713          	andi	a4,a5,3
    80005bee:	00e03733          	snez	a4,a4
    80005bf2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005bf6:	4007f793          	andi	a5,a5,1024
    80005bfa:	c791                	beqz	a5,80005c06 <sys_open+0xce>
    80005bfc:	04449703          	lh	a4,68(s1)
    80005c00:	4789                	li	a5,2
    80005c02:	0cf70763          	beq	a4,a5,80005cd0 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005c06:	8526                	mv	a0,s1
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	fb2080e7          	jalr	-78(ra) # 80003bba <iunlock>
  end_op();
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	92c080e7          	jalr	-1748(ra) # 8000453c <end_op>

  return fd;
    80005c18:	854e                	mv	a0,s3
    80005c1a:	74aa                	ld	s1,168(sp)
    80005c1c:	790a                	ld	s2,160(sp)
    80005c1e:	69ea                	ld	s3,152(sp)
}
    80005c20:	70ea                	ld	ra,184(sp)
    80005c22:	744a                	ld	s0,176(sp)
    80005c24:	6129                	addi	sp,sp,192
    80005c26:	8082                	ret
      end_op();
    80005c28:	fffff097          	auipc	ra,0xfffff
    80005c2c:	914080e7          	jalr	-1772(ra) # 8000453c <end_op>
      return -1;
    80005c30:	557d                	li	a0,-1
    80005c32:	74aa                	ld	s1,168(sp)
    80005c34:	b7f5                	j	80005c20 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005c36:	f5040513          	addi	a0,s0,-176
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	688080e7          	jalr	1672(ra) # 800042c2 <namei>
    80005c42:	84aa                	mv	s1,a0
    80005c44:	c90d                	beqz	a0,80005c76 <sys_open+0x13e>
    ilock(ip);
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	eae080e7          	jalr	-338(ra) # 80003af4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c4e:	04449703          	lh	a4,68(s1)
    80005c52:	4785                	li	a5,1
    80005c54:	f2f71fe3          	bne	a4,a5,80005b92 <sys_open+0x5a>
    80005c58:	f4c42783          	lw	a5,-180(s0)
    80005c5c:	d7a9                	beqz	a5,80005ba6 <sys_open+0x6e>
      iunlockput(ip);
    80005c5e:	8526                	mv	a0,s1
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	0fa080e7          	jalr	250(ra) # 80003d5a <iunlockput>
      end_op();
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	8d4080e7          	jalr	-1836(ra) # 8000453c <end_op>
      return -1;
    80005c70:	557d                	li	a0,-1
    80005c72:	74aa                	ld	s1,168(sp)
    80005c74:	b775                	j	80005c20 <sys_open+0xe8>
      end_op();
    80005c76:	fffff097          	auipc	ra,0xfffff
    80005c7a:	8c6080e7          	jalr	-1850(ra) # 8000453c <end_op>
      return -1;
    80005c7e:	557d                	li	a0,-1
    80005c80:	74aa                	ld	s1,168(sp)
    80005c82:	bf79                	j	80005c20 <sys_open+0xe8>
    iunlockput(ip);
    80005c84:	8526                	mv	a0,s1
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	0d4080e7          	jalr	212(ra) # 80003d5a <iunlockput>
    end_op();
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	8ae080e7          	jalr	-1874(ra) # 8000453c <end_op>
    return -1;
    80005c96:	557d                	li	a0,-1
    80005c98:	74aa                	ld	s1,168(sp)
    80005c9a:	b759                	j	80005c20 <sys_open+0xe8>
      fileclose(f);
    80005c9c:	854a                	mv	a0,s2
    80005c9e:	fffff097          	auipc	ra,0xfffff
    80005ca2:	cee080e7          	jalr	-786(ra) # 8000498c <fileclose>
    80005ca6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005ca8:	8526                	mv	a0,s1
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	0b0080e7          	jalr	176(ra) # 80003d5a <iunlockput>
    end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	88a080e7          	jalr	-1910(ra) # 8000453c <end_op>
    return -1;
    80005cba:	557d                	li	a0,-1
    80005cbc:	74aa                	ld	s1,168(sp)
    80005cbe:	790a                	ld	s2,160(sp)
    80005cc0:	b785                	j	80005c20 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005cc2:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005cc6:	04649783          	lh	a5,70(s1)
    80005cca:	02f91223          	sh	a5,36(s2)
    80005cce:	b729                	j	80005bd8 <sys_open+0xa0>
    itrunc(ip);
    80005cd0:	8526                	mv	a0,s1
    80005cd2:	ffffe097          	auipc	ra,0xffffe
    80005cd6:	f34080e7          	jalr	-204(ra) # 80003c06 <itrunc>
    80005cda:	b735                	j	80005c06 <sys_open+0xce>

0000000080005cdc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005cdc:	7175                	addi	sp,sp,-144
    80005cde:	e506                	sd	ra,136(sp)
    80005ce0:	e122                	sd	s0,128(sp)
    80005ce2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	7de080e7          	jalr	2014(ra) # 800044c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005cec:	08000613          	li	a2,128
    80005cf0:	f7040593          	addi	a1,s0,-144
    80005cf4:	4501                	li	a0,0
    80005cf6:	ffffd097          	auipc	ra,0xffffd
    80005cfa:	112080e7          	jalr	274(ra) # 80002e08 <argstr>
    80005cfe:	02054963          	bltz	a0,80005d30 <sys_mkdir+0x54>
    80005d02:	4681                	li	a3,0
    80005d04:	4601                	li	a2,0
    80005d06:	4585                	li	a1,1
    80005d08:	f7040513          	addi	a0,s0,-144
    80005d0c:	fffff097          	auipc	ra,0xfffff
    80005d10:	7d6080e7          	jalr	2006(ra) # 800054e2 <create>
    80005d14:	cd11                	beqz	a0,80005d30 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d16:	ffffe097          	auipc	ra,0xffffe
    80005d1a:	044080e7          	jalr	68(ra) # 80003d5a <iunlockput>
  end_op();
    80005d1e:	fffff097          	auipc	ra,0xfffff
    80005d22:	81e080e7          	jalr	-2018(ra) # 8000453c <end_op>
  return 0;
    80005d26:	4501                	li	a0,0
}
    80005d28:	60aa                	ld	ra,136(sp)
    80005d2a:	640a                	ld	s0,128(sp)
    80005d2c:	6149                	addi	sp,sp,144
    80005d2e:	8082                	ret
    end_op();
    80005d30:	fffff097          	auipc	ra,0xfffff
    80005d34:	80c080e7          	jalr	-2036(ra) # 8000453c <end_op>
    return -1;
    80005d38:	557d                	li	a0,-1
    80005d3a:	b7fd                	j	80005d28 <sys_mkdir+0x4c>

0000000080005d3c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d3c:	7135                	addi	sp,sp,-160
    80005d3e:	ed06                	sd	ra,152(sp)
    80005d40:	e922                	sd	s0,144(sp)
    80005d42:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	77e080e7          	jalr	1918(ra) # 800044c2 <begin_op>
  argint(1, &major);
    80005d4c:	f6c40593          	addi	a1,s0,-148
    80005d50:	4505                	li	a0,1
    80005d52:	ffffd097          	auipc	ra,0xffffd
    80005d56:	076080e7          	jalr	118(ra) # 80002dc8 <argint>
  argint(2, &minor);
    80005d5a:	f6840593          	addi	a1,s0,-152
    80005d5e:	4509                	li	a0,2
    80005d60:	ffffd097          	auipc	ra,0xffffd
    80005d64:	068080e7          	jalr	104(ra) # 80002dc8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d68:	08000613          	li	a2,128
    80005d6c:	f7040593          	addi	a1,s0,-144
    80005d70:	4501                	li	a0,0
    80005d72:	ffffd097          	auipc	ra,0xffffd
    80005d76:	096080e7          	jalr	150(ra) # 80002e08 <argstr>
    80005d7a:	02054b63          	bltz	a0,80005db0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d7e:	f6841683          	lh	a3,-152(s0)
    80005d82:	f6c41603          	lh	a2,-148(s0)
    80005d86:	458d                	li	a1,3
    80005d88:	f7040513          	addi	a0,s0,-144
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	756080e7          	jalr	1878(ra) # 800054e2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d94:	cd11                	beqz	a0,80005db0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	fc4080e7          	jalr	-60(ra) # 80003d5a <iunlockput>
  end_op();
    80005d9e:	ffffe097          	auipc	ra,0xffffe
    80005da2:	79e080e7          	jalr	1950(ra) # 8000453c <end_op>
  return 0;
    80005da6:	4501                	li	a0,0
}
    80005da8:	60ea                	ld	ra,152(sp)
    80005daa:	644a                	ld	s0,144(sp)
    80005dac:	610d                	addi	sp,sp,160
    80005dae:	8082                	ret
    end_op();
    80005db0:	ffffe097          	auipc	ra,0xffffe
    80005db4:	78c080e7          	jalr	1932(ra) # 8000453c <end_op>
    return -1;
    80005db8:	557d                	li	a0,-1
    80005dba:	b7fd                	j	80005da8 <sys_mknod+0x6c>

0000000080005dbc <sys_chdir>:

uint64
sys_chdir(void)
{
    80005dbc:	7135                	addi	sp,sp,-160
    80005dbe:	ed06                	sd	ra,152(sp)
    80005dc0:	e922                	sd	s0,144(sp)
    80005dc2:	e14a                	sd	s2,128(sp)
    80005dc4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005dc6:	ffffc097          	auipc	ra,0xffffc
    80005dca:	c7c080e7          	jalr	-900(ra) # 80001a42 <myproc>
    80005dce:	892a                	mv	s2,a0
  
  begin_op();
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	6f2080e7          	jalr	1778(ra) # 800044c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005dd8:	08000613          	li	a2,128
    80005ddc:	f6040593          	addi	a1,s0,-160
    80005de0:	4501                	li	a0,0
    80005de2:	ffffd097          	auipc	ra,0xffffd
    80005de6:	026080e7          	jalr	38(ra) # 80002e08 <argstr>
    80005dea:	04054d63          	bltz	a0,80005e44 <sys_chdir+0x88>
    80005dee:	e526                	sd	s1,136(sp)
    80005df0:	f6040513          	addi	a0,s0,-160
    80005df4:	ffffe097          	auipc	ra,0xffffe
    80005df8:	4ce080e7          	jalr	1230(ra) # 800042c2 <namei>
    80005dfc:	84aa                	mv	s1,a0
    80005dfe:	c131                	beqz	a0,80005e42 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e00:	ffffe097          	auipc	ra,0xffffe
    80005e04:	cf4080e7          	jalr	-780(ra) # 80003af4 <ilock>
  if(ip->type != T_DIR){
    80005e08:	04449703          	lh	a4,68(s1)
    80005e0c:	4785                	li	a5,1
    80005e0e:	04f71163          	bne	a4,a5,80005e50 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e12:	8526                	mv	a0,s1
    80005e14:	ffffe097          	auipc	ra,0xffffe
    80005e18:	da6080e7          	jalr	-602(ra) # 80003bba <iunlock>
  iput(p->cwd);
    80005e1c:	15093503          	ld	a0,336(s2)
    80005e20:	ffffe097          	auipc	ra,0xffffe
    80005e24:	e92080e7          	jalr	-366(ra) # 80003cb2 <iput>
  end_op();
    80005e28:	ffffe097          	auipc	ra,0xffffe
    80005e2c:	714080e7          	jalr	1812(ra) # 8000453c <end_op>
  p->cwd = ip;
    80005e30:	14993823          	sd	s1,336(s2)
  return 0;
    80005e34:	4501                	li	a0,0
    80005e36:	64aa                	ld	s1,136(sp)
}
    80005e38:	60ea                	ld	ra,152(sp)
    80005e3a:	644a                	ld	s0,144(sp)
    80005e3c:	690a                	ld	s2,128(sp)
    80005e3e:	610d                	addi	sp,sp,160
    80005e40:	8082                	ret
    80005e42:	64aa                	ld	s1,136(sp)
    end_op();
    80005e44:	ffffe097          	auipc	ra,0xffffe
    80005e48:	6f8080e7          	jalr	1784(ra) # 8000453c <end_op>
    return -1;
    80005e4c:	557d                	li	a0,-1
    80005e4e:	b7ed                	j	80005e38 <sys_chdir+0x7c>
    iunlockput(ip);
    80005e50:	8526                	mv	a0,s1
    80005e52:	ffffe097          	auipc	ra,0xffffe
    80005e56:	f08080e7          	jalr	-248(ra) # 80003d5a <iunlockput>
    end_op();
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	6e2080e7          	jalr	1762(ra) # 8000453c <end_op>
    return -1;
    80005e62:	557d                	li	a0,-1
    80005e64:	64aa                	ld	s1,136(sp)
    80005e66:	bfc9                	j	80005e38 <sys_chdir+0x7c>

0000000080005e68 <sys_exec>:

uint64
sys_exec(void)
{
    80005e68:	7121                	addi	sp,sp,-448
    80005e6a:	ff06                	sd	ra,440(sp)
    80005e6c:	fb22                	sd	s0,432(sp)
    80005e6e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e70:	e4840593          	addi	a1,s0,-440
    80005e74:	4505                	li	a0,1
    80005e76:	ffffd097          	auipc	ra,0xffffd
    80005e7a:	f72080e7          	jalr	-142(ra) # 80002de8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e7e:	08000613          	li	a2,128
    80005e82:	f5040593          	addi	a1,s0,-176
    80005e86:	4501                	li	a0,0
    80005e88:	ffffd097          	auipc	ra,0xffffd
    80005e8c:	f80080e7          	jalr	-128(ra) # 80002e08 <argstr>
    80005e90:	87aa                	mv	a5,a0
    return -1;
    80005e92:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e94:	0e07c263          	bltz	a5,80005f78 <sys_exec+0x110>
    80005e98:	f726                	sd	s1,424(sp)
    80005e9a:	f34a                	sd	s2,416(sp)
    80005e9c:	ef4e                	sd	s3,408(sp)
    80005e9e:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005ea0:	10000613          	li	a2,256
    80005ea4:	4581                	li	a1,0
    80005ea6:	e5040513          	addi	a0,s0,-432
    80005eaa:	ffffb097          	auipc	ra,0xffffb
    80005eae:	e8a080e7          	jalr	-374(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005eb2:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005eb6:	89a6                	mv	s3,s1
    80005eb8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005eba:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ebe:	00391513          	slli	a0,s2,0x3
    80005ec2:	e4040593          	addi	a1,s0,-448
    80005ec6:	e4843783          	ld	a5,-440(s0)
    80005eca:	953e                	add	a0,a0,a5
    80005ecc:	ffffd097          	auipc	ra,0xffffd
    80005ed0:	e5e080e7          	jalr	-418(ra) # 80002d2a <fetchaddr>
    80005ed4:	02054a63          	bltz	a0,80005f08 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005ed8:	e4043783          	ld	a5,-448(s0)
    80005edc:	c7b9                	beqz	a5,80005f2a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ede:	ffffb097          	auipc	ra,0xffffb
    80005ee2:	c6a080e7          	jalr	-918(ra) # 80000b48 <kalloc>
    80005ee6:	85aa                	mv	a1,a0
    80005ee8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005eec:	cd11                	beqz	a0,80005f08 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005eee:	6605                	lui	a2,0x1
    80005ef0:	e4043503          	ld	a0,-448(s0)
    80005ef4:	ffffd097          	auipc	ra,0xffffd
    80005ef8:	e88080e7          	jalr	-376(ra) # 80002d7c <fetchstr>
    80005efc:	00054663          	bltz	a0,80005f08 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005f00:	0905                	addi	s2,s2,1
    80005f02:	09a1                	addi	s3,s3,8
    80005f04:	fb491de3          	bne	s2,s4,80005ebe <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f08:	f5040913          	addi	s2,s0,-176
    80005f0c:	6088                	ld	a0,0(s1)
    80005f0e:	c125                	beqz	a0,80005f6e <sys_exec+0x106>
    kfree(argv[i]);
    80005f10:	ffffb097          	auipc	ra,0xffffb
    80005f14:	b3a080e7          	jalr	-1222(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f18:	04a1                	addi	s1,s1,8
    80005f1a:	ff2499e3          	bne	s1,s2,80005f0c <sys_exec+0xa4>
  return -1;
    80005f1e:	557d                	li	a0,-1
    80005f20:	74ba                	ld	s1,424(sp)
    80005f22:	791a                	ld	s2,416(sp)
    80005f24:	69fa                	ld	s3,408(sp)
    80005f26:	6a5a                	ld	s4,400(sp)
    80005f28:	a881                	j	80005f78 <sys_exec+0x110>
      argv[i] = 0;
    80005f2a:	0009079b          	sext.w	a5,s2
    80005f2e:	078e                	slli	a5,a5,0x3
    80005f30:	fd078793          	addi	a5,a5,-48
    80005f34:	97a2                	add	a5,a5,s0
    80005f36:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005f3a:	e5040593          	addi	a1,s0,-432
    80005f3e:	f5040513          	addi	a0,s0,-176
    80005f42:	fffff097          	auipc	ra,0xfffff
    80005f46:	120080e7          	jalr	288(ra) # 80005062 <exec>
    80005f4a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f4c:	f5040993          	addi	s3,s0,-176
    80005f50:	6088                	ld	a0,0(s1)
    80005f52:	c901                	beqz	a0,80005f62 <sys_exec+0xfa>
    kfree(argv[i]);
    80005f54:	ffffb097          	auipc	ra,0xffffb
    80005f58:	af6080e7          	jalr	-1290(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f5c:	04a1                	addi	s1,s1,8
    80005f5e:	ff3499e3          	bne	s1,s3,80005f50 <sys_exec+0xe8>
  return ret;
    80005f62:	854a                	mv	a0,s2
    80005f64:	74ba                	ld	s1,424(sp)
    80005f66:	791a                	ld	s2,416(sp)
    80005f68:	69fa                	ld	s3,408(sp)
    80005f6a:	6a5a                	ld	s4,400(sp)
    80005f6c:	a031                	j	80005f78 <sys_exec+0x110>
  return -1;
    80005f6e:	557d                	li	a0,-1
    80005f70:	74ba                	ld	s1,424(sp)
    80005f72:	791a                	ld	s2,416(sp)
    80005f74:	69fa                	ld	s3,408(sp)
    80005f76:	6a5a                	ld	s4,400(sp)
}
    80005f78:	70fa                	ld	ra,440(sp)
    80005f7a:	745a                	ld	s0,432(sp)
    80005f7c:	6139                	addi	sp,sp,448
    80005f7e:	8082                	ret

0000000080005f80 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f80:	7139                	addi	sp,sp,-64
    80005f82:	fc06                	sd	ra,56(sp)
    80005f84:	f822                	sd	s0,48(sp)
    80005f86:	f426                	sd	s1,40(sp)
    80005f88:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f8a:	ffffc097          	auipc	ra,0xffffc
    80005f8e:	ab8080e7          	jalr	-1352(ra) # 80001a42 <myproc>
    80005f92:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f94:	fd840593          	addi	a1,s0,-40
    80005f98:	4501                	li	a0,0
    80005f9a:	ffffd097          	auipc	ra,0xffffd
    80005f9e:	e4e080e7          	jalr	-434(ra) # 80002de8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005fa2:	fc840593          	addi	a1,s0,-56
    80005fa6:	fd040513          	addi	a0,s0,-48
    80005faa:	fffff097          	auipc	ra,0xfffff
    80005fae:	d50080e7          	jalr	-688(ra) # 80004cfa <pipealloc>
    return -1;
    80005fb2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005fb4:	0c054463          	bltz	a0,8000607c <sys_pipe+0xfc>
  fd0 = -1;
    80005fb8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fbc:	fd043503          	ld	a0,-48(s0)
    80005fc0:	fffff097          	auipc	ra,0xfffff
    80005fc4:	4e0080e7          	jalr	1248(ra) # 800054a0 <fdalloc>
    80005fc8:	fca42223          	sw	a0,-60(s0)
    80005fcc:	08054b63          	bltz	a0,80006062 <sys_pipe+0xe2>
    80005fd0:	fc843503          	ld	a0,-56(s0)
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	4cc080e7          	jalr	1228(ra) # 800054a0 <fdalloc>
    80005fdc:	fca42023          	sw	a0,-64(s0)
    80005fe0:	06054863          	bltz	a0,80006050 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fe4:	4691                	li	a3,4
    80005fe6:	fc440613          	addi	a2,s0,-60
    80005fea:	fd843583          	ld	a1,-40(s0)
    80005fee:	68a8                	ld	a0,80(s1)
    80005ff0:	ffffb097          	auipc	ra,0xffffb
    80005ff4:	6f2080e7          	jalr	1778(ra) # 800016e2 <copyout>
    80005ff8:	02054063          	bltz	a0,80006018 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ffc:	4691                	li	a3,4
    80005ffe:	fc040613          	addi	a2,s0,-64
    80006002:	fd843583          	ld	a1,-40(s0)
    80006006:	0591                	addi	a1,a1,4
    80006008:	68a8                	ld	a0,80(s1)
    8000600a:	ffffb097          	auipc	ra,0xffffb
    8000600e:	6d8080e7          	jalr	1752(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006012:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006014:	06055463          	bgez	a0,8000607c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006018:	fc442783          	lw	a5,-60(s0)
    8000601c:	07e9                	addi	a5,a5,26
    8000601e:	078e                	slli	a5,a5,0x3
    80006020:	97a6                	add	a5,a5,s1
    80006022:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006026:	fc042783          	lw	a5,-64(s0)
    8000602a:	07e9                	addi	a5,a5,26
    8000602c:	078e                	slli	a5,a5,0x3
    8000602e:	94be                	add	s1,s1,a5
    80006030:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006034:	fd043503          	ld	a0,-48(s0)
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	954080e7          	jalr	-1708(ra) # 8000498c <fileclose>
    fileclose(wf);
    80006040:	fc843503          	ld	a0,-56(s0)
    80006044:	fffff097          	auipc	ra,0xfffff
    80006048:	948080e7          	jalr	-1720(ra) # 8000498c <fileclose>
    return -1;
    8000604c:	57fd                	li	a5,-1
    8000604e:	a03d                	j	8000607c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006050:	fc442783          	lw	a5,-60(s0)
    80006054:	0007c763          	bltz	a5,80006062 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006058:	07e9                	addi	a5,a5,26
    8000605a:	078e                	slli	a5,a5,0x3
    8000605c:	97a6                	add	a5,a5,s1
    8000605e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006062:	fd043503          	ld	a0,-48(s0)
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	926080e7          	jalr	-1754(ra) # 8000498c <fileclose>
    fileclose(wf);
    8000606e:	fc843503          	ld	a0,-56(s0)
    80006072:	fffff097          	auipc	ra,0xfffff
    80006076:	91a080e7          	jalr	-1766(ra) # 8000498c <fileclose>
    return -1;
    8000607a:	57fd                	li	a5,-1
}
    8000607c:	853e                	mv	a0,a5
    8000607e:	70e2                	ld	ra,56(sp)
    80006080:	7442                	ld	s0,48(sp)
    80006082:	74a2                	ld	s1,40(sp)
    80006084:	6121                	addi	sp,sp,64
    80006086:	8082                	ret
	...

0000000080006090 <kernelvec>:
    80006090:	7111                	addi	sp,sp,-256
    80006092:	e006                	sd	ra,0(sp)
    80006094:	e40a                	sd	sp,8(sp)
    80006096:	e80e                	sd	gp,16(sp)
    80006098:	ec12                	sd	tp,24(sp)
    8000609a:	f016                	sd	t0,32(sp)
    8000609c:	f41a                	sd	t1,40(sp)
    8000609e:	f81e                	sd	t2,48(sp)
    800060a0:	fc22                	sd	s0,56(sp)
    800060a2:	e0a6                	sd	s1,64(sp)
    800060a4:	e4aa                	sd	a0,72(sp)
    800060a6:	e8ae                	sd	a1,80(sp)
    800060a8:	ecb2                	sd	a2,88(sp)
    800060aa:	f0b6                	sd	a3,96(sp)
    800060ac:	f4ba                	sd	a4,104(sp)
    800060ae:	f8be                	sd	a5,112(sp)
    800060b0:	fcc2                	sd	a6,120(sp)
    800060b2:	e146                	sd	a7,128(sp)
    800060b4:	e54a                	sd	s2,136(sp)
    800060b6:	e94e                	sd	s3,144(sp)
    800060b8:	ed52                	sd	s4,152(sp)
    800060ba:	f156                	sd	s5,160(sp)
    800060bc:	f55a                	sd	s6,168(sp)
    800060be:	f95e                	sd	s7,176(sp)
    800060c0:	fd62                	sd	s8,184(sp)
    800060c2:	e1e6                	sd	s9,192(sp)
    800060c4:	e5ea                	sd	s10,200(sp)
    800060c6:	e9ee                	sd	s11,208(sp)
    800060c8:	edf2                	sd	t3,216(sp)
    800060ca:	f1f6                	sd	t4,224(sp)
    800060cc:	f5fa                	sd	t5,232(sp)
    800060ce:	f9fe                	sd	t6,240(sp)
    800060d0:	b27fc0ef          	jal	80002bf6 <kerneltrap>
    800060d4:	6082                	ld	ra,0(sp)
    800060d6:	6122                	ld	sp,8(sp)
    800060d8:	61c2                	ld	gp,16(sp)
    800060da:	7282                	ld	t0,32(sp)
    800060dc:	7322                	ld	t1,40(sp)
    800060de:	73c2                	ld	t2,48(sp)
    800060e0:	7462                	ld	s0,56(sp)
    800060e2:	6486                	ld	s1,64(sp)
    800060e4:	6526                	ld	a0,72(sp)
    800060e6:	65c6                	ld	a1,80(sp)
    800060e8:	6666                	ld	a2,88(sp)
    800060ea:	7686                	ld	a3,96(sp)
    800060ec:	7726                	ld	a4,104(sp)
    800060ee:	77c6                	ld	a5,112(sp)
    800060f0:	7866                	ld	a6,120(sp)
    800060f2:	688a                	ld	a7,128(sp)
    800060f4:	692a                	ld	s2,136(sp)
    800060f6:	69ca                	ld	s3,144(sp)
    800060f8:	6a6a                	ld	s4,152(sp)
    800060fa:	7a8a                	ld	s5,160(sp)
    800060fc:	7b2a                	ld	s6,168(sp)
    800060fe:	7bca                	ld	s7,176(sp)
    80006100:	7c6a                	ld	s8,184(sp)
    80006102:	6c8e                	ld	s9,192(sp)
    80006104:	6d2e                	ld	s10,200(sp)
    80006106:	6dce                	ld	s11,208(sp)
    80006108:	6e6e                	ld	t3,216(sp)
    8000610a:	7e8e                	ld	t4,224(sp)
    8000610c:	7f2e                	ld	t5,232(sp)
    8000610e:	7fce                	ld	t6,240(sp)
    80006110:	6111                	addi	sp,sp,256
    80006112:	10200073          	sret
    80006116:	00000013          	nop
    8000611a:	00000013          	nop
    8000611e:	0001                	nop

0000000080006120 <timervec>:
    80006120:	34051573          	csrrw	a0,mscratch,a0
    80006124:	e10c                	sd	a1,0(a0)
    80006126:	e510                	sd	a2,8(a0)
    80006128:	e914                	sd	a3,16(a0)
    8000612a:	6d0c                	ld	a1,24(a0)
    8000612c:	7110                	ld	a2,32(a0)
    8000612e:	6194                	ld	a3,0(a1)
    80006130:	96b2                	add	a3,a3,a2
    80006132:	e194                	sd	a3,0(a1)
    80006134:	4589                	li	a1,2
    80006136:	14459073          	csrw	sip,a1
    8000613a:	6914                	ld	a3,16(a0)
    8000613c:	6510                	ld	a2,8(a0)
    8000613e:	610c                	ld	a1,0(a0)
    80006140:	34051573          	csrrw	a0,mscratch,a0
    80006144:	30200073          	mret
	...

000000008000614a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000614a:	1141                	addi	sp,sp,-16
    8000614c:	e422                	sd	s0,8(sp)
    8000614e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006150:	0c0007b7          	lui	a5,0xc000
    80006154:	4705                	li	a4,1
    80006156:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006158:	0c0007b7          	lui	a5,0xc000
    8000615c:	c3d8                	sw	a4,4(a5)
}
    8000615e:	6422                	ld	s0,8(sp)
    80006160:	0141                	addi	sp,sp,16
    80006162:	8082                	ret

0000000080006164 <plicinithart>:

void
plicinithart(void)
{
    80006164:	1141                	addi	sp,sp,-16
    80006166:	e406                	sd	ra,8(sp)
    80006168:	e022                	sd	s0,0(sp)
    8000616a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000616c:	ffffc097          	auipc	ra,0xffffc
    80006170:	8aa080e7          	jalr	-1878(ra) # 80001a16 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006174:	0085171b          	slliw	a4,a0,0x8
    80006178:	0c0027b7          	lui	a5,0xc002
    8000617c:	97ba                	add	a5,a5,a4
    8000617e:	40200713          	li	a4,1026
    80006182:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006186:	00d5151b          	slliw	a0,a0,0xd
    8000618a:	0c2017b7          	lui	a5,0xc201
    8000618e:	97aa                	add	a5,a5,a0
    80006190:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006194:	60a2                	ld	ra,8(sp)
    80006196:	6402                	ld	s0,0(sp)
    80006198:	0141                	addi	sp,sp,16
    8000619a:	8082                	ret

000000008000619c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000619c:	1141                	addi	sp,sp,-16
    8000619e:	e406                	sd	ra,8(sp)
    800061a0:	e022                	sd	s0,0(sp)
    800061a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061a4:	ffffc097          	auipc	ra,0xffffc
    800061a8:	872080e7          	jalr	-1934(ra) # 80001a16 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061ac:	00d5151b          	slliw	a0,a0,0xd
    800061b0:	0c2017b7          	lui	a5,0xc201
    800061b4:	97aa                	add	a5,a5,a0
  return irq;
}
    800061b6:	43c8                	lw	a0,4(a5)
    800061b8:	60a2                	ld	ra,8(sp)
    800061ba:	6402                	ld	s0,0(sp)
    800061bc:	0141                	addi	sp,sp,16
    800061be:	8082                	ret

00000000800061c0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061c0:	1101                	addi	sp,sp,-32
    800061c2:	ec06                	sd	ra,24(sp)
    800061c4:	e822                	sd	s0,16(sp)
    800061c6:	e426                	sd	s1,8(sp)
    800061c8:	1000                	addi	s0,sp,32
    800061ca:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061cc:	ffffc097          	auipc	ra,0xffffc
    800061d0:	84a080e7          	jalr	-1974(ra) # 80001a16 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800061d4:	00d5151b          	slliw	a0,a0,0xd
    800061d8:	0c2017b7          	lui	a5,0xc201
    800061dc:	97aa                	add	a5,a5,a0
    800061de:	c3c4                	sw	s1,4(a5)
}
    800061e0:	60e2                	ld	ra,24(sp)
    800061e2:	6442                	ld	s0,16(sp)
    800061e4:	64a2                	ld	s1,8(sp)
    800061e6:	6105                	addi	sp,sp,32
    800061e8:	8082                	ret

00000000800061ea <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800061ea:	1141                	addi	sp,sp,-16
    800061ec:	e406                	sd	ra,8(sp)
    800061ee:	e022                	sd	s0,0(sp)
    800061f0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061f2:	479d                	li	a5,7
    800061f4:	04a7cc63          	blt	a5,a0,8000624c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800061f8:	00022797          	auipc	a5,0x22
    800061fc:	51878793          	addi	a5,a5,1304 # 80028710 <disk>
    80006200:	97aa                	add	a5,a5,a0
    80006202:	0187c783          	lbu	a5,24(a5)
    80006206:	ebb9                	bnez	a5,8000625c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006208:	00451693          	slli	a3,a0,0x4
    8000620c:	00022797          	auipc	a5,0x22
    80006210:	50478793          	addi	a5,a5,1284 # 80028710 <disk>
    80006214:	6398                	ld	a4,0(a5)
    80006216:	9736                	add	a4,a4,a3
    80006218:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000621c:	6398                	ld	a4,0(a5)
    8000621e:	9736                	add	a4,a4,a3
    80006220:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006224:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006228:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000622c:	97aa                	add	a5,a5,a0
    8000622e:	4705                	li	a4,1
    80006230:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006234:	00022517          	auipc	a0,0x22
    80006238:	4f450513          	addi	a0,a0,1268 # 80028728 <disk+0x18>
    8000623c:	ffffc097          	auipc	ra,0xffffc
    80006240:	f4e080e7          	jalr	-178(ra) # 8000218a <wakeup>
}
    80006244:	60a2                	ld	ra,8(sp)
    80006246:	6402                	ld	s0,0(sp)
    80006248:	0141                	addi	sp,sp,16
    8000624a:	8082                	ret
    panic("free_desc 1");
    8000624c:	00002517          	auipc	a0,0x2
    80006250:	3f450513          	addi	a0,a0,1012 # 80008640 <etext+0x640>
    80006254:	ffffa097          	auipc	ra,0xffffa
    80006258:	30c080e7          	jalr	780(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000625c:	00002517          	auipc	a0,0x2
    80006260:	3f450513          	addi	a0,a0,1012 # 80008650 <etext+0x650>
    80006264:	ffffa097          	auipc	ra,0xffffa
    80006268:	2fc080e7          	jalr	764(ra) # 80000560 <panic>

000000008000626c <virtio_disk_init>:
{
    8000626c:	1101                	addi	sp,sp,-32
    8000626e:	ec06                	sd	ra,24(sp)
    80006270:	e822                	sd	s0,16(sp)
    80006272:	e426                	sd	s1,8(sp)
    80006274:	e04a                	sd	s2,0(sp)
    80006276:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006278:	00002597          	auipc	a1,0x2
    8000627c:	3e858593          	addi	a1,a1,1000 # 80008660 <etext+0x660>
    80006280:	00022517          	auipc	a0,0x22
    80006284:	5b850513          	addi	a0,a0,1464 # 80028838 <disk+0x128>
    80006288:	ffffb097          	auipc	ra,0xffffb
    8000628c:	920080e7          	jalr	-1760(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006290:	100017b7          	lui	a5,0x10001
    80006294:	4398                	lw	a4,0(a5)
    80006296:	2701                	sext.w	a4,a4
    80006298:	747277b7          	lui	a5,0x74727
    8000629c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062a0:	18f71c63          	bne	a4,a5,80006438 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062a4:	100017b7          	lui	a5,0x10001
    800062a8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800062aa:	439c                	lw	a5,0(a5)
    800062ac:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062ae:	4709                	li	a4,2
    800062b0:	18e79463          	bne	a5,a4,80006438 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062b4:	100017b7          	lui	a5,0x10001
    800062b8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800062ba:	439c                	lw	a5,0(a5)
    800062bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062be:	16e79d63          	bne	a5,a4,80006438 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062c2:	100017b7          	lui	a5,0x10001
    800062c6:	47d8                	lw	a4,12(a5)
    800062c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062ca:	554d47b7          	lui	a5,0x554d4
    800062ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062d2:	16f71363          	bne	a4,a5,80006438 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062d6:	100017b7          	lui	a5,0x10001
    800062da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062de:	4705                	li	a4,1
    800062e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062e2:	470d                	li	a4,3
    800062e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800062e6:	10001737          	lui	a4,0x10001
    800062ea:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062ec:	c7ffe737          	lui	a4,0xc7ffe
    800062f0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd5f0f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062f4:	8ef9                	and	a3,a3,a4
    800062f6:	10001737          	lui	a4,0x10001
    800062fa:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062fc:	472d                	li	a4,11
    800062fe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006300:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006304:	439c                	lw	a5,0(a5)
    80006306:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000630a:	8ba1                	andi	a5,a5,8
    8000630c:	12078e63          	beqz	a5,80006448 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006310:	100017b7          	lui	a5,0x10001
    80006314:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006318:	100017b7          	lui	a5,0x10001
    8000631c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006320:	439c                	lw	a5,0(a5)
    80006322:	2781                	sext.w	a5,a5
    80006324:	12079a63          	bnez	a5,80006458 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006328:	100017b7          	lui	a5,0x10001
    8000632c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006330:	439c                	lw	a5,0(a5)
    80006332:	2781                	sext.w	a5,a5
  if(max == 0)
    80006334:	12078a63          	beqz	a5,80006468 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006338:	471d                	li	a4,7
    8000633a:	12f77f63          	bgeu	a4,a5,80006478 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000633e:	ffffb097          	auipc	ra,0xffffb
    80006342:	80a080e7          	jalr	-2038(ra) # 80000b48 <kalloc>
    80006346:	00022497          	auipc	s1,0x22
    8000634a:	3ca48493          	addi	s1,s1,970 # 80028710 <disk>
    8000634e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006350:	ffffa097          	auipc	ra,0xffffa
    80006354:	7f8080e7          	jalr	2040(ra) # 80000b48 <kalloc>
    80006358:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000635a:	ffffa097          	auipc	ra,0xffffa
    8000635e:	7ee080e7          	jalr	2030(ra) # 80000b48 <kalloc>
    80006362:	87aa                	mv	a5,a0
    80006364:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006366:	6088                	ld	a0,0(s1)
    80006368:	12050063          	beqz	a0,80006488 <virtio_disk_init+0x21c>
    8000636c:	00022717          	auipc	a4,0x22
    80006370:	3ac73703          	ld	a4,940(a4) # 80028718 <disk+0x8>
    80006374:	10070a63          	beqz	a4,80006488 <virtio_disk_init+0x21c>
    80006378:	10078863          	beqz	a5,80006488 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000637c:	6605                	lui	a2,0x1
    8000637e:	4581                	li	a1,0
    80006380:	ffffb097          	auipc	ra,0xffffb
    80006384:	9b4080e7          	jalr	-1612(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006388:	00022497          	auipc	s1,0x22
    8000638c:	38848493          	addi	s1,s1,904 # 80028710 <disk>
    80006390:	6605                	lui	a2,0x1
    80006392:	4581                	li	a1,0
    80006394:	6488                	ld	a0,8(s1)
    80006396:	ffffb097          	auipc	ra,0xffffb
    8000639a:	99e080e7          	jalr	-1634(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    8000639e:	6605                	lui	a2,0x1
    800063a0:	4581                	li	a1,0
    800063a2:	6888                	ld	a0,16(s1)
    800063a4:	ffffb097          	auipc	ra,0xffffb
    800063a8:	990080e7          	jalr	-1648(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063ac:	100017b7          	lui	a5,0x10001
    800063b0:	4721                	li	a4,8
    800063b2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063b4:	4098                	lw	a4,0(s1)
    800063b6:	100017b7          	lui	a5,0x10001
    800063ba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063be:	40d8                	lw	a4,4(s1)
    800063c0:	100017b7          	lui	a5,0x10001
    800063c4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063c8:	649c                	ld	a5,8(s1)
    800063ca:	0007869b          	sext.w	a3,a5
    800063ce:	10001737          	lui	a4,0x10001
    800063d2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063d6:	9781                	srai	a5,a5,0x20
    800063d8:	10001737          	lui	a4,0x10001
    800063dc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063e0:	689c                	ld	a5,16(s1)
    800063e2:	0007869b          	sext.w	a3,a5
    800063e6:	10001737          	lui	a4,0x10001
    800063ea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063ee:	9781                	srai	a5,a5,0x20
    800063f0:	10001737          	lui	a4,0x10001
    800063f4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063f8:	10001737          	lui	a4,0x10001
    800063fc:	4785                	li	a5,1
    800063fe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006400:	00f48c23          	sb	a5,24(s1)
    80006404:	00f48ca3          	sb	a5,25(s1)
    80006408:	00f48d23          	sb	a5,26(s1)
    8000640c:	00f48da3          	sb	a5,27(s1)
    80006410:	00f48e23          	sb	a5,28(s1)
    80006414:	00f48ea3          	sb	a5,29(s1)
    80006418:	00f48f23          	sb	a5,30(s1)
    8000641c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006420:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006424:	100017b7          	lui	a5,0x10001
    80006428:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000642c:	60e2                	ld	ra,24(sp)
    8000642e:	6442                	ld	s0,16(sp)
    80006430:	64a2                	ld	s1,8(sp)
    80006432:	6902                	ld	s2,0(sp)
    80006434:	6105                	addi	sp,sp,32
    80006436:	8082                	ret
    panic("could not find virtio disk");
    80006438:	00002517          	auipc	a0,0x2
    8000643c:	23850513          	addi	a0,a0,568 # 80008670 <etext+0x670>
    80006440:	ffffa097          	auipc	ra,0xffffa
    80006444:	120080e7          	jalr	288(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006448:	00002517          	auipc	a0,0x2
    8000644c:	24850513          	addi	a0,a0,584 # 80008690 <etext+0x690>
    80006450:	ffffa097          	auipc	ra,0xffffa
    80006454:	110080e7          	jalr	272(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006458:	00002517          	auipc	a0,0x2
    8000645c:	25850513          	addi	a0,a0,600 # 800086b0 <etext+0x6b0>
    80006460:	ffffa097          	auipc	ra,0xffffa
    80006464:	100080e7          	jalr	256(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006468:	00002517          	auipc	a0,0x2
    8000646c:	26850513          	addi	a0,a0,616 # 800086d0 <etext+0x6d0>
    80006470:	ffffa097          	auipc	ra,0xffffa
    80006474:	0f0080e7          	jalr	240(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006478:	00002517          	auipc	a0,0x2
    8000647c:	27850513          	addi	a0,a0,632 # 800086f0 <etext+0x6f0>
    80006480:	ffffa097          	auipc	ra,0xffffa
    80006484:	0e0080e7          	jalr	224(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006488:	00002517          	auipc	a0,0x2
    8000648c:	28850513          	addi	a0,a0,648 # 80008710 <etext+0x710>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	0d0080e7          	jalr	208(ra) # 80000560 <panic>

0000000080006498 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006498:	7159                	addi	sp,sp,-112
    8000649a:	f486                	sd	ra,104(sp)
    8000649c:	f0a2                	sd	s0,96(sp)
    8000649e:	eca6                	sd	s1,88(sp)
    800064a0:	e8ca                	sd	s2,80(sp)
    800064a2:	e4ce                	sd	s3,72(sp)
    800064a4:	e0d2                	sd	s4,64(sp)
    800064a6:	fc56                	sd	s5,56(sp)
    800064a8:	f85a                	sd	s6,48(sp)
    800064aa:	f45e                	sd	s7,40(sp)
    800064ac:	f062                	sd	s8,32(sp)
    800064ae:	ec66                	sd	s9,24(sp)
    800064b0:	1880                	addi	s0,sp,112
    800064b2:	8a2a                	mv	s4,a0
    800064b4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064b6:	00c52c83          	lw	s9,12(a0)
    800064ba:	001c9c9b          	slliw	s9,s9,0x1
    800064be:	1c82                	slli	s9,s9,0x20
    800064c0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800064c4:	00022517          	auipc	a0,0x22
    800064c8:	37450513          	addi	a0,a0,884 # 80028838 <disk+0x128>
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	76c080e7          	jalr	1900(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    800064d4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064d8:	00022b17          	auipc	s6,0x22
    800064dc:	238b0b13          	addi	s6,s6,568 # 80028710 <disk>
  for(int i = 0; i < 3; i++){
    800064e0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064e2:	00022c17          	auipc	s8,0x22
    800064e6:	356c0c13          	addi	s8,s8,854 # 80028838 <disk+0x128>
    800064ea:	a0ad                	j	80006554 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800064ec:	00fb0733          	add	a4,s6,a5
    800064f0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800064f4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064f6:	0207c563          	bltz	a5,80006520 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800064fa:	2905                	addiw	s2,s2,1
    800064fc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800064fe:	05590f63          	beq	s2,s5,8000655c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006502:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006504:	00022717          	auipc	a4,0x22
    80006508:	20c70713          	addi	a4,a4,524 # 80028710 <disk>
    8000650c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000650e:	01874683          	lbu	a3,24(a4)
    80006512:	fee9                	bnez	a3,800064ec <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006514:	2785                	addiw	a5,a5,1
    80006516:	0705                	addi	a4,a4,1
    80006518:	fe979be3          	bne	a5,s1,8000650e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000651c:	57fd                	li	a5,-1
    8000651e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006520:	03205163          	blez	s2,80006542 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006524:	f9042503          	lw	a0,-112(s0)
    80006528:	00000097          	auipc	ra,0x0
    8000652c:	cc2080e7          	jalr	-830(ra) # 800061ea <free_desc>
      for(int j = 0; j < i; j++)
    80006530:	4785                	li	a5,1
    80006532:	0127d863          	bge	a5,s2,80006542 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006536:	f9442503          	lw	a0,-108(s0)
    8000653a:	00000097          	auipc	ra,0x0
    8000653e:	cb0080e7          	jalr	-848(ra) # 800061ea <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006542:	85e2                	mv	a1,s8
    80006544:	00022517          	auipc	a0,0x22
    80006548:	1e450513          	addi	a0,a0,484 # 80028728 <disk+0x18>
    8000654c:	ffffc097          	auipc	ra,0xffffc
    80006550:	bda080e7          	jalr	-1062(ra) # 80002126 <sleep>
  for(int i = 0; i < 3; i++){
    80006554:	f9040613          	addi	a2,s0,-112
    80006558:	894e                	mv	s2,s3
    8000655a:	b765                	j	80006502 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000655c:	f9042503          	lw	a0,-112(s0)
    80006560:	00451693          	slli	a3,a0,0x4

  if(write)
    80006564:	00022797          	auipc	a5,0x22
    80006568:	1ac78793          	addi	a5,a5,428 # 80028710 <disk>
    8000656c:	00a50713          	addi	a4,a0,10
    80006570:	0712                	slli	a4,a4,0x4
    80006572:	973e                	add	a4,a4,a5
    80006574:	01703633          	snez	a2,s7
    80006578:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000657a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000657e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006582:	6398                	ld	a4,0(a5)
    80006584:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006586:	0a868613          	addi	a2,a3,168
    8000658a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000658c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000658e:	6390                	ld	a2,0(a5)
    80006590:	00d605b3          	add	a1,a2,a3
    80006594:	4741                	li	a4,16
    80006596:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006598:	4805                	li	a6,1
    8000659a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000659e:	f9442703          	lw	a4,-108(s0)
    800065a2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065a6:	0712                	slli	a4,a4,0x4
    800065a8:	963a                	add	a2,a2,a4
    800065aa:	058a0593          	addi	a1,s4,88
    800065ae:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800065b0:	0007b883          	ld	a7,0(a5)
    800065b4:	9746                	add	a4,a4,a7
    800065b6:	40000613          	li	a2,1024
    800065ba:	c710                	sw	a2,8(a4)
  if(write)
    800065bc:	001bb613          	seqz	a2,s7
    800065c0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065c4:	00166613          	ori	a2,a2,1
    800065c8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800065cc:	f9842583          	lw	a1,-104(s0)
    800065d0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065d4:	00250613          	addi	a2,a0,2
    800065d8:	0612                	slli	a2,a2,0x4
    800065da:	963e                	add	a2,a2,a5
    800065dc:	577d                	li	a4,-1
    800065de:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065e2:	0592                	slli	a1,a1,0x4
    800065e4:	98ae                	add	a7,a7,a1
    800065e6:	03068713          	addi	a4,a3,48
    800065ea:	973e                	add	a4,a4,a5
    800065ec:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800065f0:	6398                	ld	a4,0(a5)
    800065f2:	972e                	add	a4,a4,a1
    800065f4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065f8:	4689                	li	a3,2
    800065fa:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800065fe:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006602:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006606:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000660a:	6794                	ld	a3,8(a5)
    8000660c:	0026d703          	lhu	a4,2(a3)
    80006610:	8b1d                	andi	a4,a4,7
    80006612:	0706                	slli	a4,a4,0x1
    80006614:	96ba                	add	a3,a3,a4
    80006616:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000661a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000661e:	6798                	ld	a4,8(a5)
    80006620:	00275783          	lhu	a5,2(a4)
    80006624:	2785                	addiw	a5,a5,1
    80006626:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000662a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000662e:	100017b7          	lui	a5,0x10001
    80006632:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006636:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000663a:	00022917          	auipc	s2,0x22
    8000663e:	1fe90913          	addi	s2,s2,510 # 80028838 <disk+0x128>
  while(b->disk == 1) {
    80006642:	4485                	li	s1,1
    80006644:	01079c63          	bne	a5,a6,8000665c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006648:	85ca                	mv	a1,s2
    8000664a:	8552                	mv	a0,s4
    8000664c:	ffffc097          	auipc	ra,0xffffc
    80006650:	ada080e7          	jalr	-1318(ra) # 80002126 <sleep>
  while(b->disk == 1) {
    80006654:	004a2783          	lw	a5,4(s4)
    80006658:	fe9788e3          	beq	a5,s1,80006648 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000665c:	f9042903          	lw	s2,-112(s0)
    80006660:	00290713          	addi	a4,s2,2
    80006664:	0712                	slli	a4,a4,0x4
    80006666:	00022797          	auipc	a5,0x22
    8000666a:	0aa78793          	addi	a5,a5,170 # 80028710 <disk>
    8000666e:	97ba                	add	a5,a5,a4
    80006670:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006674:	00022997          	auipc	s3,0x22
    80006678:	09c98993          	addi	s3,s3,156 # 80028710 <disk>
    8000667c:	00491713          	slli	a4,s2,0x4
    80006680:	0009b783          	ld	a5,0(s3)
    80006684:	97ba                	add	a5,a5,a4
    80006686:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000668a:	854a                	mv	a0,s2
    8000668c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006690:	00000097          	auipc	ra,0x0
    80006694:	b5a080e7          	jalr	-1190(ra) # 800061ea <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006698:	8885                	andi	s1,s1,1
    8000669a:	f0ed                	bnez	s1,8000667c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000669c:	00022517          	auipc	a0,0x22
    800066a0:	19c50513          	addi	a0,a0,412 # 80028838 <disk+0x128>
    800066a4:	ffffa097          	auipc	ra,0xffffa
    800066a8:	648080e7          	jalr	1608(ra) # 80000cec <release>
}
    800066ac:	70a6                	ld	ra,104(sp)
    800066ae:	7406                	ld	s0,96(sp)
    800066b0:	64e6                	ld	s1,88(sp)
    800066b2:	6946                	ld	s2,80(sp)
    800066b4:	69a6                	ld	s3,72(sp)
    800066b6:	6a06                	ld	s4,64(sp)
    800066b8:	7ae2                	ld	s5,56(sp)
    800066ba:	7b42                	ld	s6,48(sp)
    800066bc:	7ba2                	ld	s7,40(sp)
    800066be:	7c02                	ld	s8,32(sp)
    800066c0:	6ce2                	ld	s9,24(sp)
    800066c2:	6165                	addi	sp,sp,112
    800066c4:	8082                	ret

00000000800066c6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066c6:	1101                	addi	sp,sp,-32
    800066c8:	ec06                	sd	ra,24(sp)
    800066ca:	e822                	sd	s0,16(sp)
    800066cc:	e426                	sd	s1,8(sp)
    800066ce:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066d0:	00022497          	auipc	s1,0x22
    800066d4:	04048493          	addi	s1,s1,64 # 80028710 <disk>
    800066d8:	00022517          	auipc	a0,0x22
    800066dc:	16050513          	addi	a0,a0,352 # 80028838 <disk+0x128>
    800066e0:	ffffa097          	auipc	ra,0xffffa
    800066e4:	558080e7          	jalr	1368(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066e8:	100017b7          	lui	a5,0x10001
    800066ec:	53b8                	lw	a4,96(a5)
    800066ee:	8b0d                	andi	a4,a4,3
    800066f0:	100017b7          	lui	a5,0x10001
    800066f4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800066f6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066fa:	689c                	ld	a5,16(s1)
    800066fc:	0204d703          	lhu	a4,32(s1)
    80006700:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006704:	04f70863          	beq	a4,a5,80006754 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006708:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000670c:	6898                	ld	a4,16(s1)
    8000670e:	0204d783          	lhu	a5,32(s1)
    80006712:	8b9d                	andi	a5,a5,7
    80006714:	078e                	slli	a5,a5,0x3
    80006716:	97ba                	add	a5,a5,a4
    80006718:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000671a:	00278713          	addi	a4,a5,2
    8000671e:	0712                	slli	a4,a4,0x4
    80006720:	9726                	add	a4,a4,s1
    80006722:	01074703          	lbu	a4,16(a4)
    80006726:	e721                	bnez	a4,8000676e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006728:	0789                	addi	a5,a5,2
    8000672a:	0792                	slli	a5,a5,0x4
    8000672c:	97a6                	add	a5,a5,s1
    8000672e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006730:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006734:	ffffc097          	auipc	ra,0xffffc
    80006738:	a56080e7          	jalr	-1450(ra) # 8000218a <wakeup>

    disk.used_idx += 1;
    8000673c:	0204d783          	lhu	a5,32(s1)
    80006740:	2785                	addiw	a5,a5,1
    80006742:	17c2                	slli	a5,a5,0x30
    80006744:	93c1                	srli	a5,a5,0x30
    80006746:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000674a:	6898                	ld	a4,16(s1)
    8000674c:	00275703          	lhu	a4,2(a4)
    80006750:	faf71ce3          	bne	a4,a5,80006708 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006754:	00022517          	auipc	a0,0x22
    80006758:	0e450513          	addi	a0,a0,228 # 80028838 <disk+0x128>
    8000675c:	ffffa097          	auipc	ra,0xffffa
    80006760:	590080e7          	jalr	1424(ra) # 80000cec <release>
}
    80006764:	60e2                	ld	ra,24(sp)
    80006766:	6442                	ld	s0,16(sp)
    80006768:	64a2                	ld	s1,8(sp)
    8000676a:	6105                	addi	sp,sp,32
    8000676c:	8082                	ret
      panic("virtio_disk_intr status");
    8000676e:	00002517          	auipc	a0,0x2
    80006772:	fba50513          	addi	a0,a0,-70 # 80008728 <etext+0x728>
    80006776:	ffffa097          	auipc	ra,0xffffa
    8000677a:	dea080e7          	jalr	-534(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
