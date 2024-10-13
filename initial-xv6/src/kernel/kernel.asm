
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	33013103          	ld	sp,816(sp) # 8000b330 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	34070713          	addi	a4,a4,832 # 8000b390 <timer_scratch>
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
    80000066:	24e78793          	addi	a5,a5,590 # 800062b0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd5927>
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
    8000012e:	5c6080e7          	jalr	1478(ra) # 800026f0 <either_copyin>
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
    80000190:	34450513          	addi	a0,a0,836 # 800134d0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	33448493          	addi	s1,s1,820 # 800134d0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	3c490913          	addi	s2,s2,964 # 80013568 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	8be080e7          	jalr	-1858(ra) # 80001a7a <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	376080e7          	jalr	886(ra) # 8000253a <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	0b4080e7          	jalr	180(ra) # 80002286 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	2e870713          	addi	a4,a4,744 # 800134d0 <cons>
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
    8000021e:	480080e7          	jalr	1152(ra) # 8000269a <either_copyout>
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
    8000023a:	29a50513          	addi	a0,a0,666 # 800134d0 <cons>
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
    80000268:	30f72223          	sw	a5,772(a4) # 80013568 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	25650513          	addi	a0,a0,598 # 800134d0 <cons>
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
    800002e6:	1ee50513          	addi	a0,a0,494 # 800134d0 <cons>
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
    8000030c:	43e080e7          	jalr	1086(ra) # 80002746 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	1c050513          	addi	a0,a0,448 # 800134d0 <cons>
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
    80000336:	19e70713          	addi	a4,a4,414 # 800134d0 <cons>
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
    80000360:	17478793          	addi	a5,a5,372 # 800134d0 <cons>
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
    8000038e:	1de7a783          	lw	a5,478(a5) # 80013568 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	13070713          	addi	a4,a4,304 # 800134d0 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	12048493          	addi	s1,s1,288 # 800134d0 <cons>
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
    800003fa:	0da70713          	addi	a4,a4,218 # 800134d0 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	16f72223          	sw	a5,356(a4) # 80013570 <cons+0xa0>
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
    80000436:	09e78793          	addi	a5,a5,158 # 800134d0 <cons>
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
    8000045a:	10c7ab23          	sw	a2,278(a5) # 8001356c <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	10a50513          	addi	a0,a0,266 # 80013568 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	e84080e7          	jalr	-380(ra) # 800022ea <wakeup>
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
    80000484:	05050513          	addi	a0,a0,80 # 800134d0 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00028797          	auipc	a5,0x28
    8000049c:	8a878793          	addi	a5,a5,-1880 # 80027d40 <devsw>
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
    80000570:	0207a223          	sw	zero,36(a5) # 80013590 <pr+0x18>
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
    800005a4:	daf72823          	sw	a5,-592(a4) # 8000b350 <panicked>
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
    800005ce:	fc6d2d03          	lw	s10,-58(s10) # 80013590 <pr+0x18>
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
    8000061e:	f5e50513          	addi	a0,a0,-162 # 80013578 <pr>
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
    800007a4:	dd850513          	addi	a0,a0,-552 # 80013578 <pr>
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
    800007c0:	dbc48493          	addi	s1,s1,-580 # 80013578 <pr>
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
    8000082c:	d7050513          	addi	a0,a0,-656 # 80013598 <uart_tx_lock>
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
    80000858:	afc7a783          	lw	a5,-1284(a5) # 8000b350 <panicked>
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
    80000892:	aca7b783          	ld	a5,-1334(a5) # 8000b358 <uart_tx_r>
    80000896:	0000b717          	auipc	a4,0xb
    8000089a:	aca73703          	ld	a4,-1334(a4) # 8000b360 <uart_tx_w>
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
    800008c0:	cdca8a93          	addi	s5,s5,-804 # 80013598 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	0000b497          	auipc	s1,0xb
    800008c8:	a9448493          	addi	s1,s1,-1388 # 8000b358 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	0000b997          	auipc	s3,0xb
    800008d4:	a9098993          	addi	s3,s3,-1392 # 8000b360 <uart_tx_w>
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
    800008f6:	9f8080e7          	jalr	-1544(ra) # 800022ea <wakeup>
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
    80000934:	c6850513          	addi	a0,a0,-920 # 80013598 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	0000b797          	auipc	a5,0xb
    80000944:	a107a783          	lw	a5,-1520(a5) # 8000b350 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	0000b717          	auipc	a4,0xb
    8000094e:	a1673703          	ld	a4,-1514(a4) # 8000b360 <uart_tx_w>
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	a067b783          	ld	a5,-1530(a5) # 8000b358 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00013997          	auipc	s3,0x13
    80000962:	c3a98993          	addi	s3,s3,-966 # 80013598 <uart_tx_lock>
    80000966:	0000b497          	auipc	s1,0xb
    8000096a:	9f248493          	addi	s1,s1,-1550 # 8000b358 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	0000b917          	auipc	s2,0xb
    80000972:	9f290913          	addi	s2,s2,-1550 # 8000b360 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	908080e7          	jalr	-1784(ra) # 80002286 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00013497          	auipc	s1,0x13
    80000998:	c0448493          	addi	s1,s1,-1020 # 80013598 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	0000b797          	auipc	a5,0xb
    800009ac:	9ae7bc23          	sd	a4,-1608(a5) # 8000b360 <uart_tx_w>
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
    80000a20:	b7c48493          	addi	s1,s1,-1156 # 80013598 <uart_tx_lock>
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
    80000a62:	47a78793          	addi	a5,a5,1146 # 80028ed8 <end>
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
    80000a82:	b5290913          	addi	s2,s2,-1198 # 800135d0 <kmem>
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
    80000b20:	ab450513          	addi	a0,a0,-1356 # 800135d0 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00028517          	auipc	a0,0x28
    80000b34:	3a850513          	addi	a0,a0,936 # 80028ed8 <end>
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
    80000b56:	a7e48493          	addi	s1,s1,-1410 # 800135d0 <kmem>
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
    80000b6e:	a6650513          	addi	a0,a0,-1434 # 800135d0 <kmem>
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
    80000b9a:	a3a50513          	addi	a0,a0,-1478 # 800135d0 <kmem>
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
    80000bd6:	e8c080e7          	jalr	-372(ra) # 80001a5e <mycpu>
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
    80000c08:	e5a080e7          	jalr	-422(ra) # 80001a5e <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e4e080e7          	jalr	-434(ra) # 80001a5e <mycpu>
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
    80000c2c:	e36080e7          	jalr	-458(ra) # 80001a5e <mycpu>
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
    80000c6c:	df6080e7          	jalr	-522(ra) # 80001a5e <mycpu>
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
    80000c98:	dca080e7          	jalr	-566(ra) # 80001a5e <mycpu>
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
    80000da8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd6129>
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
void main()
{
    80000ed2:	1141                	addi	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	addi	s0,sp,16
  extern void srand(unsigned int seed);
  extern int rand(void);
  srand(r_time()); // r_time() returns the current time, which can serve as a seed
#endif

  if (cpuid() == 0)
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b74080e7          	jalr	-1164(ra) # 80001a4e <cpuid>
    __sync_synchronize();
    started = 1;
  }
  else
  {
    while (started == 0)
    80000ee2:	0000a717          	auipc	a4,0xa
    80000ee6:	48670713          	addi	a4,a4,1158 # 8000b368 <started>
  if (cpuid() == 0)
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while (started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b58080e7          	jalr	-1192(ra) # 80001a4e <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	addi	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();  // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000f18:	00002097          	auipc	ra,0x2
    80000f1c:	b1a080e7          	jalr	-1254(ra) # 80002a32 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	3d4080e7          	jalr	980(ra) # 800062f4 <plicinithart>
  }

  scheduler();
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	0d6080e7          	jalr	214(ra) # 80001ffe <scheduler>
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
    kinit();            // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();          // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();      // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();         // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	a04080e7          	jalr	-1532(ra) # 8000198c <procinit>
    trapinit();         // trap vectors
    80000f90:	00002097          	auipc	ra,0x2
    80000f94:	a7a080e7          	jalr	-1414(ra) # 80002a0a <trapinit>
    trapinithart();     // install kernel trap vector
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	a9a080e7          	jalr	-1382(ra) # 80002a32 <trapinithart>
    plicinit();         // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	33a080e7          	jalr	826(ra) # 800062da <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	34c080e7          	jalr	844(ra) # 800062f4 <plicinithart>
    binit();            // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	40c080e7          	jalr	1036(ra) # 800033bc <binit>
    iinit();            // inode table
    80000fb8:	00003097          	auipc	ra,0x3
    80000fbc:	ac2080e7          	jalr	-1342(ra) # 80003a7a <iinit>
    fileinit();         // file table
    80000fc0:	00004097          	auipc	ra,0x4
    80000fc4:	a72080e7          	jalr	-1422(ra) # 80004a32 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	434080e7          	jalr	1076(ra) # 800063fc <virtio_disk_init>
    userinit();         // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	de6080e7          	jalr	-538(ra) # 80001db6 <userinit>
    __sync_synchronize();
    80000fd8:	0330000f          	fence	rw,rw
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	0000a717          	auipc	a4,0xa
    80000fe2:	38f72523          	sw	a5,906(a4) # 8000b368 <started>
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
    80000ff6:	37e7b783          	ld	a5,894(a5) # 8000b370 <kernel_pagetable>
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
    80001070:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd611f>
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
    8000128c:	660080e7          	jalr	1632(ra) # 800018e8 <proc_mapstacks>
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
    800012b2:	0ca7b123          	sd	a0,194(a5) # 8000b370 <kernel_pagetable>
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
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd6128>
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

00000000800018b8 <random>:
  return number;
}

// Helper function to get a random number
uint random(void)
{
    800018b8:	1141                	addi	sp,sp,-16
    800018ba:	e422                	sd	s0,8(sp)
    800018bc:	0800                	addi	s0,sp,16
  // Simple linear congruential generator
  static uint seed = 1;
  seed = seed * 1103515245 + 12345;
    800018be:	0000a717          	auipc	a4,0xa
    800018c2:	a2670713          	addi	a4,a4,-1498 # 8000b2e4 <seed.2>
    800018c6:	431c                	lw	a5,0(a4)
    800018c8:	41c65537          	lui	a0,0x41c65
    800018cc:	e6d5051b          	addiw	a0,a0,-403 # 41c64e6d <_entry-0x3e39b193>
    800018d0:	02f5053b          	mulw	a0,a0,a5
    800018d4:	678d                	lui	a5,0x3
    800018d6:	0397879b          	addiw	a5,a5,57 # 3039 <_entry-0x7fffcfc7>
    800018da:	9d3d                	addw	a0,a0,a5
    800018dc:	c308                	sw	a0,0(a4)
  return (seed >> 16) & 0x7fff;
    800018de:	1506                	slli	a0,a0,0x21
}
    800018e0:	9145                	srli	a0,a0,0x31
    800018e2:	6422                	ld	s0,8(sp)
    800018e4:	0141                	addi	sp,sp,16
    800018e6:	8082                	ret

00000000800018e8 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800018e8:	7139                	addi	sp,sp,-64
    800018ea:	fc06                	sd	ra,56(sp)
    800018ec:	f822                	sd	s0,48(sp)
    800018ee:	f426                	sd	s1,40(sp)
    800018f0:	f04a                	sd	s2,32(sp)
    800018f2:	ec4e                	sd	s3,24(sp)
    800018f4:	e852                	sd	s4,16(sp)
    800018f6:	e456                	sd	s5,8(sp)
    800018f8:	e05a                	sd	s6,0(sp)
    800018fa:	0080                	addi	s0,sp,64
    800018fc:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800018fe:	00012497          	auipc	s1,0x12
    80001902:	12248493          	addi	s1,s1,290 # 80013a20 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001906:	8b26                	mv	s6,s1
    80001908:	fcccd937          	lui	s2,0xfcccd
    8000190c:	ccd90913          	addi	s2,s2,-819 # fffffffffccccccd <end+0xffffffff7cca3df5>
    80001910:	0932                	slli	s2,s2,0xc
    80001912:	ccd90913          	addi	s2,s2,-819
    80001916:	0932                	slli	s2,s2,0xc
    80001918:	ccd90913          	addi	s2,s2,-819
    8000191c:	0932                	slli	s2,s2,0xc
    8000191e:	ccd90913          	addi	s2,s2,-819
    80001922:	040009b7          	lui	s3,0x4000
    80001926:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001928:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000192a:	0001ca97          	auipc	s5,0x1c
    8000192e:	0f6a8a93          	addi	s5,s5,246 # 8001da20 <tickslock>
    char *pa = kalloc();
    80001932:	fffff097          	auipc	ra,0xfffff
    80001936:	216080e7          	jalr	534(ra) # 80000b48 <kalloc>
    8000193a:	862a                	mv	a2,a0
    if (pa == 0)
    8000193c:	c121                	beqz	a0,8000197c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int)(p - proc));
    8000193e:	416485b3          	sub	a1,s1,s6
    80001942:	859d                	srai	a1,a1,0x7
    80001944:	032585b3          	mul	a1,a1,s2
    80001948:	2585                	addiw	a1,a1,1
    8000194a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000194e:	4719                	li	a4,6
    80001950:	6685                	lui	a3,0x1
    80001952:	40b985b3          	sub	a1,s3,a1
    80001956:	8552                	mv	a0,s4
    80001958:	00000097          	auipc	ra,0x0
    8000195c:	840080e7          	jalr	-1984(ra) # 80001198 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001960:	28048493          	addi	s1,s1,640
    80001964:	fd5497e3          	bne	s1,s5,80001932 <proc_mapstacks+0x4a>
  }
}
    80001968:	70e2                	ld	ra,56(sp)
    8000196a:	7442                	ld	s0,48(sp)
    8000196c:	74a2                	ld	s1,40(sp)
    8000196e:	7902                	ld	s2,32(sp)
    80001970:	69e2                	ld	s3,24(sp)
    80001972:	6a42                	ld	s4,16(sp)
    80001974:	6aa2                	ld	s5,8(sp)
    80001976:	6b02                	ld	s6,0(sp)
    80001978:	6121                	addi	sp,sp,64
    8000197a:	8082                	ret
      panic("kalloc");
    8000197c:	00007517          	auipc	a0,0x7
    80001980:	83c50513          	addi	a0,a0,-1988 # 800081b8 <etext+0x1b8>
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	bdc080e7          	jalr	-1060(ra) # 80000560 <panic>

000000008000198c <procinit>:

// initialize the proc table.
void procinit(void)
{
    8000198c:	7139                	addi	sp,sp,-64
    8000198e:	fc06                	sd	ra,56(sp)
    80001990:	f822                	sd	s0,48(sp)
    80001992:	f426                	sd	s1,40(sp)
    80001994:	f04a                	sd	s2,32(sp)
    80001996:	ec4e                	sd	s3,24(sp)
    80001998:	e852                	sd	s4,16(sp)
    8000199a:	e456                	sd	s5,8(sp)
    8000199c:	e05a                	sd	s6,0(sp)
    8000199e:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800019a0:	00007597          	auipc	a1,0x7
    800019a4:	82058593          	addi	a1,a1,-2016 # 800081c0 <etext+0x1c0>
    800019a8:	00012517          	auipc	a0,0x12
    800019ac:	c4850513          	addi	a0,a0,-952 # 800135f0 <pid_lock>
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1f8080e7          	jalr	504(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    800019b8:	00007597          	auipc	a1,0x7
    800019bc:	81058593          	addi	a1,a1,-2032 # 800081c8 <etext+0x1c8>
    800019c0:	00012517          	auipc	a0,0x12
    800019c4:	c4850513          	addi	a0,a0,-952 # 80013608 <wait_lock>
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	1e0080e7          	jalr	480(ra) # 80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    800019d0:	00012497          	auipc	s1,0x12
    800019d4:	05048493          	addi	s1,s1,80 # 80013a20 <proc>
  {
    initlock(&p->lock, "proc");
    800019d8:	00007b17          	auipc	s6,0x7
    800019dc:	800b0b13          	addi	s6,s6,-2048 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800019e0:	8aa6                	mv	s5,s1
    800019e2:	fcccd937          	lui	s2,0xfcccd
    800019e6:	ccd90913          	addi	s2,s2,-819 # fffffffffccccccd <end+0xffffffff7cca3df5>
    800019ea:	0932                	slli	s2,s2,0xc
    800019ec:	ccd90913          	addi	s2,s2,-819
    800019f0:	0932                	slli	s2,s2,0xc
    800019f2:	ccd90913          	addi	s2,s2,-819
    800019f6:	0932                	slli	s2,s2,0xc
    800019f8:	ccd90913          	addi	s2,s2,-819
    800019fc:	040009b7          	lui	s3,0x4000
    80001a00:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a02:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a04:	0001ca17          	auipc	s4,0x1c
    80001a08:	01ca0a13          	addi	s4,s4,28 # 8001da20 <tickslock>
    initlock(&p->lock, "proc");
    80001a0c:	85da                	mv	a1,s6
    80001a0e:	8526                	mv	a0,s1
    80001a10:	fffff097          	auipc	ra,0xfffff
    80001a14:	198080e7          	jalr	408(ra) # 80000ba8 <initlock>
    p->state = UNUSED;
    80001a18:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001a1c:	415487b3          	sub	a5,s1,s5
    80001a20:	879d                	srai	a5,a5,0x7
    80001a22:	032787b3          	mul	a5,a5,s2
    80001a26:	2785                	addiw	a5,a5,1
    80001a28:	00d7979b          	slliw	a5,a5,0xd
    80001a2c:	40f987b3          	sub	a5,s3,a5
    80001a30:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001a32:	28048493          	addi	s1,s1,640
    80001a36:	fd449be3          	bne	s1,s4,80001a0c <procinit+0x80>
  }
}
    80001a3a:	70e2                	ld	ra,56(sp)
    80001a3c:	7442                	ld	s0,48(sp)
    80001a3e:	74a2                	ld	s1,40(sp)
    80001a40:	7902                	ld	s2,32(sp)
    80001a42:	69e2                	ld	s3,24(sp)
    80001a44:	6a42                	ld	s4,16(sp)
    80001a46:	6aa2                	ld	s5,8(sp)
    80001a48:	6b02                	ld	s6,0(sp)
    80001a4a:	6121                	addi	sp,sp,64
    80001a4c:	8082                	ret

0000000080001a4e <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001a4e:	1141                	addi	sp,sp,-16
    80001a50:	e422                	sd	s0,8(sp)
    80001a52:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a54:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a56:	2501                	sext.w	a0,a0
    80001a58:	6422                	ld	s0,8(sp)
    80001a5a:	0141                	addi	sp,sp,16
    80001a5c:	8082                	ret

0000000080001a5e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001a5e:	1141                	addi	sp,sp,-16
    80001a60:	e422                	sd	s0,8(sp)
    80001a62:	0800                	addi	s0,sp,16
    80001a64:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a66:	2781                	sext.w	a5,a5
    80001a68:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a6a:	00012517          	auipc	a0,0x12
    80001a6e:	bb650513          	addi	a0,a0,-1098 # 80013620 <cpus>
    80001a72:	953e                	add	a0,a0,a5
    80001a74:	6422                	ld	s0,8(sp)
    80001a76:	0141                	addi	sp,sp,16
    80001a78:	8082                	ret

0000000080001a7a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001a7a:	1101                	addi	sp,sp,-32
    80001a7c:	ec06                	sd	ra,24(sp)
    80001a7e:	e822                	sd	s0,16(sp)
    80001a80:	e426                	sd	s1,8(sp)
    80001a82:	1000                	addi	s0,sp,32
  push_off();
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	168080e7          	jalr	360(ra) # 80000bec <push_off>
    80001a8c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a8e:	2781                	sext.w	a5,a5
    80001a90:	079e                	slli	a5,a5,0x7
    80001a92:	00012717          	auipc	a4,0x12
    80001a96:	b5e70713          	addi	a4,a4,-1186 # 800135f0 <pid_lock>
    80001a9a:	97ba                	add	a5,a5,a4
    80001a9c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	1ee080e7          	jalr	494(ra) # 80000c8c <pop_off>
  return p;
}
    80001aa6:	8526                	mv	a0,s1
    80001aa8:	60e2                	ld	ra,24(sp)
    80001aaa:	6442                	ld	s0,16(sp)
    80001aac:	64a2                	ld	s1,8(sp)
    80001aae:	6105                	addi	sp,sp,32
    80001ab0:	8082                	ret

0000000080001ab2 <settickets>:
  if (number <= 0)
    80001ab2:	02a05463          	blez	a0,80001ada <settickets+0x28>
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	1000                	addi	s0,sp,32
    80001ac0:	84aa                	mv	s1,a0
  myproc()->tickets = number;
    80001ac2:	00000097          	auipc	ra,0x0
    80001ac6:	fb8080e7          	jalr	-72(ra) # 80001a7a <myproc>
    80001aca:	26952823          	sw	s1,624(a0)
  return number;
    80001ace:	8526                	mv	a0,s1
}
    80001ad0:	60e2                	ld	ra,24(sp)
    80001ad2:	6442                	ld	s0,16(sp)
    80001ad4:	64a2                	ld	s1,8(sp)
    80001ad6:	6105                	addi	sp,sp,32
    80001ad8:	8082                	ret
    return -1;
    80001ada:	557d                	li	a0,-1
}
    80001adc:	8082                	ret

0000000080001ade <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001ade:	1141                	addi	sp,sp,-16
    80001ae0:	e406                	sd	ra,8(sp)
    80001ae2:	e022                	sd	s0,0(sp)
    80001ae4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ae6:	00000097          	auipc	ra,0x0
    80001aea:	f94080e7          	jalr	-108(ra) # 80001a7a <myproc>
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	1fe080e7          	jalr	510(ra) # 80000cec <release>

  if (first)
    80001af6:	00009797          	auipc	a5,0x9
    80001afa:	7ea7a783          	lw	a5,2026(a5) # 8000b2e0 <first.1>
    80001afe:	eb89                	bnez	a5,80001b10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b00:	00001097          	auipc	ra,0x1
    80001b04:	f4a080e7          	jalr	-182(ra) # 80002a4a <usertrapret>
}
    80001b08:	60a2                	ld	ra,8(sp)
    80001b0a:	6402                	ld	s0,0(sp)
    80001b0c:	0141                	addi	sp,sp,16
    80001b0e:	8082                	ret
    first = 0;
    80001b10:	00009797          	auipc	a5,0x9
    80001b14:	7c07a823          	sw	zero,2000(a5) # 8000b2e0 <first.1>
    fsinit(ROOTDEV);
    80001b18:	4505                	li	a0,1
    80001b1a:	00002097          	auipc	ra,0x2
    80001b1e:	ee0080e7          	jalr	-288(ra) # 800039fa <fsinit>
    80001b22:	bff9                	j	80001b00 <forkret+0x22>

0000000080001b24 <allocpid>:
{
    80001b24:	1101                	addi	sp,sp,-32
    80001b26:	ec06                	sd	ra,24(sp)
    80001b28:	e822                	sd	s0,16(sp)
    80001b2a:	e426                	sd	s1,8(sp)
    80001b2c:	e04a                	sd	s2,0(sp)
    80001b2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b30:	00012917          	auipc	s2,0x12
    80001b34:	ac090913          	addi	s2,s2,-1344 # 800135f0 <pid_lock>
    80001b38:	854a                	mv	a0,s2
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	0fe080e7          	jalr	254(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001b42:	00009797          	auipc	a5,0x9
    80001b46:	7a678793          	addi	a5,a5,1958 # 8000b2e8 <nextpid>
    80001b4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b4c:	0014871b          	addiw	a4,s1,1
    80001b50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b52:	854a                	mv	a0,s2
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	198080e7          	jalr	408(ra) # 80000cec <release>
}
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	60e2                	ld	ra,24(sp)
    80001b60:	6442                	ld	s0,16(sp)
    80001b62:	64a2                	ld	s1,8(sp)
    80001b64:	6902                	ld	s2,0(sp)
    80001b66:	6105                	addi	sp,sp,32
    80001b68:	8082                	ret

0000000080001b6a <proc_pagetable>:
{
    80001b6a:	1101                	addi	sp,sp,-32
    80001b6c:	ec06                	sd	ra,24(sp)
    80001b6e:	e822                	sd	s0,16(sp)
    80001b70:	e426                	sd	s1,8(sp)
    80001b72:	e04a                	sd	s2,0(sp)
    80001b74:	1000                	addi	s0,sp,32
    80001b76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	81a080e7          	jalr	-2022(ra) # 80001392 <uvmcreate>
    80001b80:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b82:	c121                	beqz	a0,80001bc2 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b84:	4729                	li	a4,10
    80001b86:	00005697          	auipc	a3,0x5
    80001b8a:	47a68693          	addi	a3,a3,1146 # 80007000 <_trampoline>
    80001b8e:	6605                	lui	a2,0x1
    80001b90:	040005b7          	lui	a1,0x4000
    80001b94:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b96:	05b2                	slli	a1,a1,0xc
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	560080e7          	jalr	1376(ra) # 800010f8 <mappages>
    80001ba0:	02054863          	bltz	a0,80001bd0 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ba4:	4719                	li	a4,6
    80001ba6:	05893683          	ld	a3,88(s2)
    80001baa:	6605                	lui	a2,0x1
    80001bac:	020005b7          	lui	a1,0x2000
    80001bb0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bb2:	05b6                	slli	a1,a1,0xd
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	fffff097          	auipc	ra,0xfffff
    80001bba:	542080e7          	jalr	1346(ra) # 800010f8 <mappages>
    80001bbe:	02054163          	bltz	a0,80001be0 <proc_pagetable+0x76>
}
    80001bc2:	8526                	mv	a0,s1
    80001bc4:	60e2                	ld	ra,24(sp)
    80001bc6:	6442                	ld	s0,16(sp)
    80001bc8:	64a2                	ld	s1,8(sp)
    80001bca:	6902                	ld	s2,0(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret
    uvmfree(pagetable, 0);
    80001bd0:	4581                	li	a1,0
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	9d0080e7          	jalr	-1584(ra) # 800015a4 <uvmfree>
    return 0;
    80001bdc:	4481                	li	s1,0
    80001bde:	b7d5                	j	80001bc2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001be0:	4681                	li	a3,0
    80001be2:	4605                	li	a2,1
    80001be4:	040005b7          	lui	a1,0x4000
    80001be8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bea:	05b2                	slli	a1,a1,0xc
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	6d0080e7          	jalr	1744(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001bf6:	4581                	li	a1,0
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	00000097          	auipc	ra,0x0
    80001bfe:	9aa080e7          	jalr	-1622(ra) # 800015a4 <uvmfree>
    return 0;
    80001c02:	4481                	li	s1,0
    80001c04:	bf7d                	j	80001bc2 <proc_pagetable+0x58>

0000000080001c06 <proc_freepagetable>:
{
    80001c06:	1101                	addi	sp,sp,-32
    80001c08:	ec06                	sd	ra,24(sp)
    80001c0a:	e822                	sd	s0,16(sp)
    80001c0c:	e426                	sd	s1,8(sp)
    80001c0e:	e04a                	sd	s2,0(sp)
    80001c10:	1000                	addi	s0,sp,32
    80001c12:	84aa                	mv	s1,a0
    80001c14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c16:	4681                	li	a3,0
    80001c18:	4605                	li	a2,1
    80001c1a:	040005b7          	lui	a1,0x4000
    80001c1e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c20:	05b2                	slli	a1,a1,0xc
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	69c080e7          	jalr	1692(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c2a:	4681                	li	a3,0
    80001c2c:	4605                	li	a2,1
    80001c2e:	020005b7          	lui	a1,0x2000
    80001c32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c34:	05b6                	slli	a1,a1,0xd
    80001c36:	8526                	mv	a0,s1
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	686080e7          	jalr	1670(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001c40:	85ca                	mv	a1,s2
    80001c42:	8526                	mv	a0,s1
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	960080e7          	jalr	-1696(ra) # 800015a4 <uvmfree>
}
    80001c4c:	60e2                	ld	ra,24(sp)
    80001c4e:	6442                	ld	s0,16(sp)
    80001c50:	64a2                	ld	s1,8(sp)
    80001c52:	6902                	ld	s2,0(sp)
    80001c54:	6105                	addi	sp,sp,32
    80001c56:	8082                	ret

0000000080001c58 <freeproc>:
{
    80001c58:	1101                	addi	sp,sp,-32
    80001c5a:	ec06                	sd	ra,24(sp)
    80001c5c:	e822                	sd	s0,16(sp)
    80001c5e:	e426                	sd	s1,8(sp)
    80001c60:	1000                	addi	s0,sp,32
    80001c62:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c64:	6d28                	ld	a0,88(a0)
    80001c66:	c509                	beqz	a0,80001c70 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	de2080e7          	jalr	-542(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c70:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c74:	68a8                	ld	a0,80(s1)
    80001c76:	c511                	beqz	a0,80001c82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c78:	64ac                	ld	a1,72(s1)
    80001c7a:	00000097          	auipc	ra,0x0
    80001c7e:	f8c080e7          	jalr	-116(ra) # 80001c06 <proc_freepagetable>
  p->pagetable = 0;
    80001c82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c8a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c8e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c96:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c9a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ca2:	0004ac23          	sw	zero,24(s1)
}
    80001ca6:	60e2                	ld	ra,24(sp)
    80001ca8:	6442                	ld	s0,16(sp)
    80001caa:	64a2                	ld	s1,8(sp)
    80001cac:	6105                	addi	sp,sp,32
    80001cae:	8082                	ret

0000000080001cb0 <allocproc>:
{
    80001cb0:	1101                	addi	sp,sp,-32
    80001cb2:	ec06                	sd	ra,24(sp)
    80001cb4:	e822                	sd	s0,16(sp)
    80001cb6:	e426                	sd	s1,8(sp)
    80001cb8:	e04a                	sd	s2,0(sp)
    80001cba:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001cbc:	00012497          	auipc	s1,0x12
    80001cc0:	d6448493          	addi	s1,s1,-668 # 80013a20 <proc>
    80001cc4:	0001c917          	auipc	s2,0x1c
    80001cc8:	d5c90913          	addi	s2,s2,-676 # 8001da20 <tickslock>
    acquire(&p->lock);
    80001ccc:	8526                	mv	a0,s1
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	f6a080e7          	jalr	-150(ra) # 80000c38 <acquire>
    if (p->state == UNUSED)
    80001cd6:	4c9c                	lw	a5,24(s1)
    80001cd8:	cf81                	beqz	a5,80001cf0 <allocproc+0x40>
      release(&p->lock);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	010080e7          	jalr	16(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ce4:	28048493          	addi	s1,s1,640
    80001ce8:	ff2492e3          	bne	s1,s2,80001ccc <allocproc+0x1c>
  return 0;
    80001cec:	4481                	li	s1,0
    80001cee:	a069                	j	80001d78 <allocproc+0xc8>
  p->pid = allocpid();
    80001cf0:	00000097          	auipc	ra,0x0
    80001cf4:	e34080e7          	jalr	-460(ra) # 80001b24 <allocpid>
    80001cf8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cfa:	4785                	li	a5,1
    80001cfc:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	e4a080e7          	jalr	-438(ra) # 80000b48 <kalloc>
    80001d06:	892a                	mv	s2,a0
    80001d08:	eca8                	sd	a0,88(s1)
    80001d0a:	cd35                	beqz	a0,80001d86 <allocproc+0xd6>
  p->pagetable = proc_pagetable(p);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	e5c080e7          	jalr	-420(ra) # 80001b6a <proc_pagetable>
    80001d16:	892a                	mv	s2,a0
    80001d18:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001d1a:	c151                	beqz	a0,80001d9e <allocproc+0xee>
  memset(&p->context, 0, sizeof(p->context));
    80001d1c:	07000613          	li	a2,112
    80001d20:	4581                	li	a1,0
    80001d22:	06048513          	addi	a0,s1,96
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	00e080e7          	jalr	14(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001d2e:	00000797          	auipc	a5,0x0
    80001d32:	db078793          	addi	a5,a5,-592 # 80001ade <forkret>
    80001d36:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d38:	60bc                	ld	a5,64(s1)
    80001d3a:	6705                	lui	a4,0x1
    80001d3c:	97ba                	add	a5,a5,a4
    80001d3e:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001d40:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001d44:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001d48:	00009917          	auipc	s2,0x9
    80001d4c:	63890913          	addi	s2,s2,1592 # 8000b380 <ticks>
    80001d50:	00092783          	lw	a5,0(s2)
    80001d54:	16f4a623          	sw	a5,364(s1)
  memset(&p->syscall_counts, 0, sizeof(p->syscall_counts));
    80001d58:	0d800613          	li	a2,216
    80001d5c:	4581                	li	a1,0
    80001d5e:	17848513          	addi	a0,s1,376
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	fd2080e7          	jalr	-46(ra) # 80000d34 <memset>
  p->tickets = 1;          // Default ticket count
    80001d6a:	4785                	li	a5,1
    80001d6c:	26f4a823          	sw	a5,624(s1)
  p->arrival_time = ticks; // Set arrival time
    80001d70:	00096783          	lwu	a5,0(s2)
    80001d74:	26f4bc23          	sd	a5,632(s1)
}
    80001d78:	8526                	mv	a0,s1
    80001d7a:	60e2                	ld	ra,24(sp)
    80001d7c:	6442                	ld	s0,16(sp)
    80001d7e:	64a2                	ld	s1,8(sp)
    80001d80:	6902                	ld	s2,0(sp)
    80001d82:	6105                	addi	sp,sp,32
    80001d84:	8082                	ret
    freeproc(p);
    80001d86:	8526                	mv	a0,s1
    80001d88:	00000097          	auipc	ra,0x0
    80001d8c:	ed0080e7          	jalr	-304(ra) # 80001c58 <freeproc>
    release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	f5a080e7          	jalr	-166(ra) # 80000cec <release>
    return 0;
    80001d9a:	84ca                	mv	s1,s2
    80001d9c:	bff1                	j	80001d78 <allocproc+0xc8>
    freeproc(p);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	eb8080e7          	jalr	-328(ra) # 80001c58 <freeproc>
    release(&p->lock);
    80001da8:	8526                	mv	a0,s1
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	f42080e7          	jalr	-190(ra) # 80000cec <release>
    return 0;
    80001db2:	84ca                	mv	s1,s2
    80001db4:	b7d1                	j	80001d78 <allocproc+0xc8>

0000000080001db6 <userinit>:
{
    80001db6:	1101                	addi	sp,sp,-32
    80001db8:	ec06                	sd	ra,24(sp)
    80001dba:	e822                	sd	s0,16(sp)
    80001dbc:	e426                	sd	s1,8(sp)
    80001dbe:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dc0:	00000097          	auipc	ra,0x0
    80001dc4:	ef0080e7          	jalr	-272(ra) # 80001cb0 <allocproc>
    80001dc8:	84aa                	mv	s1,a0
  initproc = p;
    80001dca:	00009797          	auipc	a5,0x9
    80001dce:	5aa7b723          	sd	a0,1454(a5) # 8000b378 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001dd2:	03400613          	li	a2,52
    80001dd6:	00009597          	auipc	a1,0x9
    80001dda:	51a58593          	addi	a1,a1,1306 # 8000b2f0 <initcode>
    80001dde:	6928                	ld	a0,80(a0)
    80001de0:	fffff097          	auipc	ra,0xfffff
    80001de4:	5e0080e7          	jalr	1504(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001de8:	6785                	lui	a5,0x1
    80001dea:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001dec:	6cb8                	ld	a4,88(s1)
    80001dee:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001df2:	6cb8                	ld	a4,88(s1)
    80001df4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001df6:	4641                	li	a2,16
    80001df8:	00006597          	auipc	a1,0x6
    80001dfc:	3e858593          	addi	a1,a1,1000 # 800081e0 <etext+0x1e0>
    80001e00:	15848513          	addi	a0,s1,344
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	072080e7          	jalr	114(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001e0c:	00006517          	auipc	a0,0x6
    80001e10:	3e450513          	addi	a0,a0,996 # 800081f0 <etext+0x1f0>
    80001e14:	00002097          	auipc	ra,0x2
    80001e18:	638080e7          	jalr	1592(ra) # 8000444c <namei>
    80001e1c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e20:	478d                	li	a5,3
    80001e22:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e24:	8526                	mv	a0,s1
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	ec6080e7          	jalr	-314(ra) # 80000cec <release>
}
    80001e2e:	60e2                	ld	ra,24(sp)
    80001e30:	6442                	ld	s0,16(sp)
    80001e32:	64a2                	ld	s1,8(sp)
    80001e34:	6105                	addi	sp,sp,32
    80001e36:	8082                	ret

0000000080001e38 <growproc>:
{
    80001e38:	1101                	addi	sp,sp,-32
    80001e3a:	ec06                	sd	ra,24(sp)
    80001e3c:	e822                	sd	s0,16(sp)
    80001e3e:	e426                	sd	s1,8(sp)
    80001e40:	e04a                	sd	s2,0(sp)
    80001e42:	1000                	addi	s0,sp,32
    80001e44:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e46:	00000097          	auipc	ra,0x0
    80001e4a:	c34080e7          	jalr	-972(ra) # 80001a7a <myproc>
    80001e4e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e50:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001e52:	01204c63          	bgtz	s2,80001e6a <growproc+0x32>
  else if (n < 0)
    80001e56:	02094663          	bltz	s2,80001e82 <growproc+0x4a>
  p->sz = sz;
    80001e5a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001e5c:	4501                	li	a0,0
}
    80001e5e:	60e2                	ld	ra,24(sp)
    80001e60:	6442                	ld	s0,16(sp)
    80001e62:	64a2                	ld	s1,8(sp)
    80001e64:	6902                	ld	s2,0(sp)
    80001e66:	6105                	addi	sp,sp,32
    80001e68:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001e6a:	4691                	li	a3,4
    80001e6c:	00b90633          	add	a2,s2,a1
    80001e70:	6928                	ld	a0,80(a0)
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	608080e7          	jalr	1544(ra) # 8000147a <uvmalloc>
    80001e7a:	85aa                	mv	a1,a0
    80001e7c:	fd79                	bnez	a0,80001e5a <growproc+0x22>
      return -1;
    80001e7e:	557d                	li	a0,-1
    80001e80:	bff9                	j	80001e5e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e82:	00b90633          	add	a2,s2,a1
    80001e86:	6928                	ld	a0,80(a0)
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	5aa080e7          	jalr	1450(ra) # 80001432 <uvmdealloc>
    80001e90:	85aa                	mv	a1,a0
    80001e92:	b7e1                	j	80001e5a <growproc+0x22>

0000000080001e94 <fork>:
{
    80001e94:	7139                	addi	sp,sp,-64
    80001e96:	fc06                	sd	ra,56(sp)
    80001e98:	f822                	sd	s0,48(sp)
    80001e9a:	f04a                	sd	s2,32(sp)
    80001e9c:	e456                	sd	s5,8(sp)
    80001e9e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ea0:	00000097          	auipc	ra,0x0
    80001ea4:	bda080e7          	jalr	-1062(ra) # 80001a7a <myproc>
    80001ea8:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001eaa:	00000097          	auipc	ra,0x0
    80001eae:	e06080e7          	jalr	-506(ra) # 80001cb0 <allocproc>
    80001eb2:	14050463          	beqz	a0,80001ffa <fork+0x166>
    80001eb6:	ec4e                	sd	s3,24(sp)
    80001eb8:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001eba:	048ab603          	ld	a2,72(s5)
    80001ebe:	692c                	ld	a1,80(a0)
    80001ec0:	050ab503          	ld	a0,80(s5)
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	71a080e7          	jalr	1818(ra) # 800015de <uvmcopy>
    80001ecc:	04054a63          	bltz	a0,80001f20 <fork+0x8c>
    80001ed0:	f426                	sd	s1,40(sp)
    80001ed2:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001ed4:	048ab783          	ld	a5,72(s5)
    80001ed8:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001edc:	058ab683          	ld	a3,88(s5)
    80001ee0:	87b6                	mv	a5,a3
    80001ee2:	0589b703          	ld	a4,88(s3)
    80001ee6:	12068693          	addi	a3,a3,288
    80001eea:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001eee:	6788                	ld	a0,8(a5)
    80001ef0:	6b8c                	ld	a1,16(a5)
    80001ef2:	6f90                	ld	a2,24(a5)
    80001ef4:	01073023          	sd	a6,0(a4)
    80001ef8:	e708                	sd	a0,8(a4)
    80001efa:	eb0c                	sd	a1,16(a4)
    80001efc:	ef10                	sd	a2,24(a4)
    80001efe:	02078793          	addi	a5,a5,32
    80001f02:	02070713          	addi	a4,a4,32
    80001f06:	fed792e3          	bne	a5,a3,80001eea <fork+0x56>
  np->trapframe->a0 = 0;
    80001f0a:	0589b783          	ld	a5,88(s3)
    80001f0e:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001f12:	0d0a8493          	addi	s1,s5,208
    80001f16:	0d098913          	addi	s2,s3,208
    80001f1a:	150a8a13          	addi	s4,s5,336
    80001f1e:	a015                	j	80001f42 <fork+0xae>
    freeproc(np);
    80001f20:	854e                	mv	a0,s3
    80001f22:	00000097          	auipc	ra,0x0
    80001f26:	d36080e7          	jalr	-714(ra) # 80001c58 <freeproc>
    release(&np->lock);
    80001f2a:	854e                	mv	a0,s3
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	dc0080e7          	jalr	-576(ra) # 80000cec <release>
    return -1;
    80001f34:	597d                	li	s2,-1
    80001f36:	69e2                	ld	s3,24(sp)
    80001f38:	a855                	j	80001fec <fork+0x158>
  for (i = 0; i < NOFILE; i++)
    80001f3a:	04a1                	addi	s1,s1,8
    80001f3c:	0921                	addi	s2,s2,8
    80001f3e:	01448b63          	beq	s1,s4,80001f54 <fork+0xc0>
    if (p->ofile[i])
    80001f42:	6088                	ld	a0,0(s1)
    80001f44:	d97d                	beqz	a0,80001f3a <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f46:	00003097          	auipc	ra,0x3
    80001f4a:	b7e080e7          	jalr	-1154(ra) # 80004ac4 <filedup>
    80001f4e:	00a93023          	sd	a0,0(s2)
    80001f52:	b7e5                	j	80001f3a <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f54:	150ab503          	ld	a0,336(s5)
    80001f58:	00002097          	auipc	ra,0x2
    80001f5c:	ce8080e7          	jalr	-792(ra) # 80003c40 <idup>
    80001f60:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f64:	4641                	li	a2,16
    80001f66:	158a8593          	addi	a1,s5,344
    80001f6a:	15898513          	addi	a0,s3,344
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	f08080e7          	jalr	-248(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001f76:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f7a:	854e                	mv	a0,s3
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	d70080e7          	jalr	-656(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001f84:	00011497          	auipc	s1,0x11
    80001f88:	68448493          	addi	s1,s1,1668 # 80013608 <wait_lock>
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	caa080e7          	jalr	-854(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f96:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	d50080e7          	jalr	-688(ra) # 80000cec <release>
  acquire(&np->lock);
    80001fa4:	854e                	mv	a0,s3
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	c92080e7          	jalr	-878(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001fae:	478d                	li	a5,3
    80001fb0:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fb4:	854e                	mv	a0,s3
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	d36080e7          	jalr	-714(ra) # 80000cec <release>
  memmove(&np->syscall_counts, &p->syscall_counts, sizeof(p->syscall_counts));
    80001fbe:	0d800613          	li	a2,216
    80001fc2:	178a8593          	addi	a1,s5,376
    80001fc6:	17898513          	addi	a0,s3,376
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	dc6080e7          	jalr	-570(ra) # 80000d90 <memmove>
  np->tickets = p->tickets; // Child inherits parent's tickets
    80001fd2:	270aa783          	lw	a5,624(s5)
    80001fd6:	26f9a823          	sw	a5,624(s3)
  np->arrival_time = ticks; // Set arrival time for the new process
    80001fda:	00009797          	auipc	a5,0x9
    80001fde:	3a67e783          	lwu	a5,934(a5) # 8000b380 <ticks>
    80001fe2:	26f9bc23          	sd	a5,632(s3)
  return pid;
    80001fe6:	74a2                	ld	s1,40(sp)
    80001fe8:	69e2                	ld	s3,24(sp)
    80001fea:	6a42                	ld	s4,16(sp)
}
    80001fec:	854a                	mv	a0,s2
    80001fee:	70e2                	ld	ra,56(sp)
    80001ff0:	7442                	ld	s0,48(sp)
    80001ff2:	7902                	ld	s2,32(sp)
    80001ff4:	6aa2                	ld	s5,8(sp)
    80001ff6:	6121                	addi	sp,sp,64
    80001ff8:	8082                	ret
    return -1;
    80001ffa:	597d                	li	s2,-1
    80001ffc:	bfc5                	j	80001fec <fork+0x158>

0000000080001ffe <scheduler>:
{
    80001ffe:	da010113          	addi	sp,sp,-608
    80002002:	24113c23          	sd	ra,600(sp)
    80002006:	24813823          	sd	s0,592(sp)
    8000200a:	24913423          	sd	s1,584(sp)
    8000200e:	25213023          	sd	s2,576(sp)
    80002012:	23313c23          	sd	s3,568(sp)
    80002016:	23413823          	sd	s4,560(sp)
    8000201a:	23513423          	sd	s5,552(sp)
    8000201e:	23613023          	sd	s6,544(sp)
    80002022:	21713c23          	sd	s7,536(sp)
    80002026:	21813823          	sd	s8,528(sp)
    8000202a:	21913423          	sd	s9,520(sp)
    8000202e:	1480                	addi	s0,sp,608
    80002030:	8792                	mv	a5,tp
  int id = r_tp();
    80002032:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002034:	00779693          	slli	a3,a5,0x7
    80002038:	00011717          	auipc	a4,0x11
    8000203c:	5b870713          	addi	a4,a4,1464 # 800135f0 <pid_lock>
    80002040:	9736                	add	a4,a4,a3
    80002042:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &winner->context);
    80002046:	00011717          	auipc	a4,0x11
    8000204a:	5e270713          	addi	a4,a4,1506 # 80013628 <cpus+0x8>
    8000204e:	00e68cb3          	add	s9,a3,a4
    int num_candidates = 0;
    80002052:	4b01                	li	s6,0
      if (p->state == RUNNABLE)
    80002054:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002056:	0001ca17          	auipc	s4,0x1c
    8000205a:	9caa0a13          	addi	s4,s4,-1590 # 8001da20 <tickslock>
        winner->state = RUNNING;
    8000205e:	4c11                	li	s8,4
        c->proc = winner;
    80002060:	00011b97          	auipc	s7,0x11
    80002064:	590b8b93          	addi	s7,s7,1424 # 800135f0 <pid_lock>
    80002068:	9bb6                	add	s7,s7,a3
    8000206a:	a8d1                	j	8000213e <scheduler+0x140>
      release(&p->lock);
    8000206c:	8526                	mv	a0,s1
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	c7e080e7          	jalr	-898(ra) # 80000cec <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002076:	28048493          	addi	s1,s1,640
    8000207a:	03448763          	beq	s1,s4,800020a8 <scheduler+0xaa>
      acquire(&p->lock);
    8000207e:	8526                	mv	a0,s1
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	bb8080e7          	jalr	-1096(ra) # 80000c38 <acquire>
      if (p->state == RUNNABLE)
    80002088:	4c9c                	lw	a5,24(s1)
    8000208a:	ff3791e3          	bne	a5,s3,8000206c <scheduler+0x6e>
        total_tickets += p->tickets;
    8000208e:	2704a783          	lw	a5,624(s1)
    80002092:	01578abb          	addw	s5,a5,s5
        candidates[num_candidates++] = p;
    80002096:	00391793          	slli	a5,s2,0x3
    8000209a:	fa078793          	addi	a5,a5,-96
    8000209e:	97a2                	add	a5,a5,s0
    800020a0:	e097b023          	sd	s1,-512(a5)
    800020a4:	2905                	addiw	s2,s2,1
    800020a6:	b7d9                	j	8000206c <scheduler+0x6e>
    if (total_tickets > 0)
    800020a8:	09505b63          	blez	s5,8000213e <scheduler+0x140>
      int winner_ticket = random() % total_tickets;
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	80c080e7          	jalr	-2036(ra) # 800018b8 <random>
    800020b4:	035575bb          	remuw	a1,a0,s5
      for (int i = 0; i < num_candidates; i++)
    800020b8:	07205463          	blez	s2,80002120 <scheduler+0x122>
        current_tickets += candidates[i]->tickets;
    800020bc:	da043483          	ld	s1,-608(s0)
    800020c0:	2704a703          	lw	a4,624(s1)
        if (current_tickets > winner_ticket)
    800020c4:	02e5c663          	blt	a1,a4,800020f0 <scheduler+0xf2>
    800020c8:	da840793          	addi	a5,s0,-600
    800020cc:	fff9061b          	addiw	a2,s2,-1
    800020d0:	02061693          	slli	a3,a2,0x20
    800020d4:	01d6d613          	srli	a2,a3,0x1d
    800020d8:	963e                	add	a2,a2,a5
      for (int i = 0; i < num_candidates; i++)
    800020da:	00c78a63          	beq	a5,a2,800020ee <scheduler+0xf0>
        current_tickets += candidates[i]->tickets;
    800020de:	6384                	ld	s1,0(a5)
    800020e0:	2704a683          	lw	a3,624(s1)
    800020e4:	9f35                	addw	a4,a4,a3
        if (current_tickets > winner_ticket)
    800020e6:	07a1                	addi	a5,a5,8
    800020e8:	fee5d9e3          	bge	a1,a4,800020da <scheduler+0xdc>
    800020ec:	a011                	j	800020f0 <scheduler+0xf2>
      struct proc *winner = 0;
    800020ee:	84da                	mv	s1,s6
      for (int i = 0; i < num_candidates; i++)
    800020f0:	da040713          	addi	a4,s0,-608
    800020f4:	00391793          	slli	a5,s2,0x3
    800020f8:	97ba                	add	a5,a5,a4
    800020fa:	a021                	j	80002102 <scheduler+0x104>
    800020fc:	0721                	addi	a4,a4,8
    800020fe:	02f70263          	beq	a4,a5,80002122 <scheduler+0x124>
        if (candidates[i]->tickets == winner->tickets &&
    80002102:	6314                	ld	a3,0(a4)
    80002104:	2706a583          	lw	a1,624(a3)
    80002108:	2704a603          	lw	a2,624(s1)
    8000210c:	fec598e3          	bne	a1,a2,800020fc <scheduler+0xfe>
    80002110:	2786b583          	ld	a1,632(a3)
    80002114:	2784b603          	ld	a2,632(s1)
    80002118:	fec5f2e3          	bgeu	a1,a2,800020fc <scheduler+0xfe>
          winner = candidates[i];
    8000211c:	84b6                	mv	s1,a3
    8000211e:	bff9                	j	800020fc <scheduler+0xfe>
      struct proc *winner = 0;
    80002120:	84da                	mv	s1,s6
      acquire(&winner->lock);
    80002122:	8926                	mv	s2,s1
    80002124:	8526                	mv	a0,s1
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	b12080e7          	jalr	-1262(ra) # 80000c38 <acquire>
      if (winner->state == RUNNABLE)
    8000212e:	4c9c                	lw	a5,24(s1)
    80002130:	03378463          	beq	a5,s3,80002158 <scheduler+0x15a>
      release(&winner->lock);
    80002134:	854a                	mv	a0,s2
    80002136:	fffff097          	auipc	ra,0xfffff
    8000213a:	bb6080e7          	jalr	-1098(ra) # 80000cec <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000213e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002142:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002146:	10079073          	csrw	sstatus,a5
    int num_candidates = 0;
    8000214a:	895a                	mv	s2,s6
    int total_tickets = 0;
    8000214c:	8ada                	mv	s5,s6
    for (p = proc; p < &proc[NPROC]; p++)
    8000214e:	00012497          	auipc	s1,0x12
    80002152:	8d248493          	addi	s1,s1,-1838 # 80013a20 <proc>
    80002156:	b725                	j	8000207e <scheduler+0x80>
        winner->state = RUNNING;
    80002158:	0184ac23          	sw	s8,24(s1)
        c->proc = winner;
    8000215c:	029bb823          	sd	s1,48(s7)
        swtch(&c->context, &winner->context);
    80002160:	06048593          	addi	a1,s1,96
    80002164:	8566                	mv	a0,s9
    80002166:	00001097          	auipc	ra,0x1
    8000216a:	83a080e7          	jalr	-1990(ra) # 800029a0 <swtch>
        c->proc = 0;
    8000216e:	020bb823          	sd	zero,48(s7)
    80002172:	b7c9                	j	80002134 <scheduler+0x136>

0000000080002174 <sched>:
{
    80002174:	7179                	addi	sp,sp,-48
    80002176:	f406                	sd	ra,40(sp)
    80002178:	f022                	sd	s0,32(sp)
    8000217a:	ec26                	sd	s1,24(sp)
    8000217c:	e84a                	sd	s2,16(sp)
    8000217e:	e44e                	sd	s3,8(sp)
    80002180:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002182:	00000097          	auipc	ra,0x0
    80002186:	8f8080e7          	jalr	-1800(ra) # 80001a7a <myproc>
    8000218a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	a32080e7          	jalr	-1486(ra) # 80000bbe <holding>
    80002194:	c93d                	beqz	a0,8000220a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002196:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002198:	2781                	sext.w	a5,a5
    8000219a:	079e                	slli	a5,a5,0x7
    8000219c:	00011717          	auipc	a4,0x11
    800021a0:	45470713          	addi	a4,a4,1108 # 800135f0 <pid_lock>
    800021a4:	97ba                	add	a5,a5,a4
    800021a6:	0a87a703          	lw	a4,168(a5)
    800021aa:	4785                	li	a5,1
    800021ac:	06f71763          	bne	a4,a5,8000221a <sched+0xa6>
  if (p->state == RUNNING)
    800021b0:	4c98                	lw	a4,24(s1)
    800021b2:	4791                	li	a5,4
    800021b4:	06f70b63          	beq	a4,a5,8000222a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021b8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021bc:	8b89                	andi	a5,a5,2
  if (intr_get())
    800021be:	efb5                	bnez	a5,8000223a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021c0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021c2:	00011917          	auipc	s2,0x11
    800021c6:	42e90913          	addi	s2,s2,1070 # 800135f0 <pid_lock>
    800021ca:	2781                	sext.w	a5,a5
    800021cc:	079e                	slli	a5,a5,0x7
    800021ce:	97ca                	add	a5,a5,s2
    800021d0:	0ac7a983          	lw	s3,172(a5)
    800021d4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021d6:	2781                	sext.w	a5,a5
    800021d8:	079e                	slli	a5,a5,0x7
    800021da:	00011597          	auipc	a1,0x11
    800021de:	44e58593          	addi	a1,a1,1102 # 80013628 <cpus+0x8>
    800021e2:	95be                	add	a1,a1,a5
    800021e4:	06048513          	addi	a0,s1,96
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	7b8080e7          	jalr	1976(ra) # 800029a0 <swtch>
    800021f0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021f2:	2781                	sext.w	a5,a5
    800021f4:	079e                	slli	a5,a5,0x7
    800021f6:	993e                	add	s2,s2,a5
    800021f8:	0b392623          	sw	s3,172(s2)
}
    800021fc:	70a2                	ld	ra,40(sp)
    800021fe:	7402                	ld	s0,32(sp)
    80002200:	64e2                	ld	s1,24(sp)
    80002202:	6942                	ld	s2,16(sp)
    80002204:	69a2                	ld	s3,8(sp)
    80002206:	6145                	addi	sp,sp,48
    80002208:	8082                	ret
    panic("sched p->lock");
    8000220a:	00006517          	auipc	a0,0x6
    8000220e:	fee50513          	addi	a0,a0,-18 # 800081f8 <etext+0x1f8>
    80002212:	ffffe097          	auipc	ra,0xffffe
    80002216:	34e080e7          	jalr	846(ra) # 80000560 <panic>
    panic("sched locks");
    8000221a:	00006517          	auipc	a0,0x6
    8000221e:	fee50513          	addi	a0,a0,-18 # 80008208 <etext+0x208>
    80002222:	ffffe097          	auipc	ra,0xffffe
    80002226:	33e080e7          	jalr	830(ra) # 80000560 <panic>
    panic("sched running");
    8000222a:	00006517          	auipc	a0,0x6
    8000222e:	fee50513          	addi	a0,a0,-18 # 80008218 <etext+0x218>
    80002232:	ffffe097          	auipc	ra,0xffffe
    80002236:	32e080e7          	jalr	814(ra) # 80000560 <panic>
    panic("sched interruptible");
    8000223a:	00006517          	auipc	a0,0x6
    8000223e:	fee50513          	addi	a0,a0,-18 # 80008228 <etext+0x228>
    80002242:	ffffe097          	auipc	ra,0xffffe
    80002246:	31e080e7          	jalr	798(ra) # 80000560 <panic>

000000008000224a <yield>:
{
    8000224a:	1101                	addi	sp,sp,-32
    8000224c:	ec06                	sd	ra,24(sp)
    8000224e:	e822                	sd	s0,16(sp)
    80002250:	e426                	sd	s1,8(sp)
    80002252:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002254:	00000097          	auipc	ra,0x0
    80002258:	826080e7          	jalr	-2010(ra) # 80001a7a <myproc>
    8000225c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	9da080e7          	jalr	-1574(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    80002266:	478d                	li	a5,3
    80002268:	cc9c                	sw	a5,24(s1)
  sched();
    8000226a:	00000097          	auipc	ra,0x0
    8000226e:	f0a080e7          	jalr	-246(ra) # 80002174 <sched>
  release(&p->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a78080e7          	jalr	-1416(ra) # 80000cec <release>
}
    8000227c:	60e2                	ld	ra,24(sp)
    8000227e:	6442                	ld	s0,16(sp)
    80002280:	64a2                	ld	s1,8(sp)
    80002282:	6105                	addi	sp,sp,32
    80002284:	8082                	ret

0000000080002286 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002286:	7179                	addi	sp,sp,-48
    80002288:	f406                	sd	ra,40(sp)
    8000228a:	f022                	sd	s0,32(sp)
    8000228c:	ec26                	sd	s1,24(sp)
    8000228e:	e84a                	sd	s2,16(sp)
    80002290:	e44e                	sd	s3,8(sp)
    80002292:	1800                	addi	s0,sp,48
    80002294:	89aa                	mv	s3,a0
    80002296:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	7e2080e7          	jalr	2018(ra) # 80001a7a <myproc>
    800022a0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	996080e7          	jalr	-1642(ra) # 80000c38 <acquire>
  release(lk);
    800022aa:	854a                	mv	a0,s2
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	a40080e7          	jalr	-1472(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    800022b4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022b8:	4789                	li	a5,2
    800022ba:	cc9c                	sw	a5,24(s1)

  sched();
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	eb8080e7          	jalr	-328(ra) # 80002174 <sched>

  // Tidy up.
  p->chan = 0;
    800022c4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	a22080e7          	jalr	-1502(ra) # 80000cec <release>
  acquire(lk);
    800022d2:	854a                	mv	a0,s2
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	964080e7          	jalr	-1692(ra) # 80000c38 <acquire>
}
    800022dc:	70a2                	ld	ra,40(sp)
    800022de:	7402                	ld	s0,32(sp)
    800022e0:	64e2                	ld	s1,24(sp)
    800022e2:	6942                	ld	s2,16(sp)
    800022e4:	69a2                	ld	s3,8(sp)
    800022e6:	6145                	addi	sp,sp,48
    800022e8:	8082                	ret

00000000800022ea <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800022ea:	7139                	addi	sp,sp,-64
    800022ec:	fc06                	sd	ra,56(sp)
    800022ee:	f822                	sd	s0,48(sp)
    800022f0:	f426                	sd	s1,40(sp)
    800022f2:	f04a                	sd	s2,32(sp)
    800022f4:	ec4e                	sd	s3,24(sp)
    800022f6:	e852                	sd	s4,16(sp)
    800022f8:	e456                	sd	s5,8(sp)
    800022fa:	0080                	addi	s0,sp,64
    800022fc:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800022fe:	00011497          	auipc	s1,0x11
    80002302:	72248493          	addi	s1,s1,1826 # 80013a20 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002306:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002308:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000230a:	0001b917          	auipc	s2,0x1b
    8000230e:	71690913          	addi	s2,s2,1814 # 8001da20 <tickslock>
    80002312:	a811                	j	80002326 <wakeup+0x3c>
      }
      release(&p->lock);
    80002314:	8526                	mv	a0,s1
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	9d6080e7          	jalr	-1578(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000231e:	28048493          	addi	s1,s1,640
    80002322:	03248663          	beq	s1,s2,8000234e <wakeup+0x64>
    if (p != myproc())
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	754080e7          	jalr	1876(ra) # 80001a7a <myproc>
    8000232e:	fea488e3          	beq	s1,a0,8000231e <wakeup+0x34>
      acquire(&p->lock);
    80002332:	8526                	mv	a0,s1
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	904080e7          	jalr	-1788(ra) # 80000c38 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000233c:	4c9c                	lw	a5,24(s1)
    8000233e:	fd379be3          	bne	a5,s3,80002314 <wakeup+0x2a>
    80002342:	709c                	ld	a5,32(s1)
    80002344:	fd4798e3          	bne	a5,s4,80002314 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002348:	0154ac23          	sw	s5,24(s1)
    8000234c:	b7e1                	j	80002314 <wakeup+0x2a>
    }
  }
}
    8000234e:	70e2                	ld	ra,56(sp)
    80002350:	7442                	ld	s0,48(sp)
    80002352:	74a2                	ld	s1,40(sp)
    80002354:	7902                	ld	s2,32(sp)
    80002356:	69e2                	ld	s3,24(sp)
    80002358:	6a42                	ld	s4,16(sp)
    8000235a:	6aa2                	ld	s5,8(sp)
    8000235c:	6121                	addi	sp,sp,64
    8000235e:	8082                	ret

0000000080002360 <reparent>:
{
    80002360:	7179                	addi	sp,sp,-48
    80002362:	f406                	sd	ra,40(sp)
    80002364:	f022                	sd	s0,32(sp)
    80002366:	ec26                	sd	s1,24(sp)
    80002368:	e84a                	sd	s2,16(sp)
    8000236a:	e44e                	sd	s3,8(sp)
    8000236c:	e052                	sd	s4,0(sp)
    8000236e:	1800                	addi	s0,sp,48
    80002370:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002372:	00011497          	auipc	s1,0x11
    80002376:	6ae48493          	addi	s1,s1,1710 # 80013a20 <proc>
      pp->parent = initproc;
    8000237a:	00009a17          	auipc	s4,0x9
    8000237e:	ffea0a13          	addi	s4,s4,-2 # 8000b378 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002382:	0001b997          	auipc	s3,0x1b
    80002386:	69e98993          	addi	s3,s3,1694 # 8001da20 <tickslock>
    8000238a:	a029                	j	80002394 <reparent+0x34>
    8000238c:	28048493          	addi	s1,s1,640
    80002390:	01348d63          	beq	s1,s3,800023aa <reparent+0x4a>
    if (pp->parent == p)
    80002394:	7c9c                	ld	a5,56(s1)
    80002396:	ff279be3          	bne	a5,s2,8000238c <reparent+0x2c>
      pp->parent = initproc;
    8000239a:	000a3503          	ld	a0,0(s4)
    8000239e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023a0:	00000097          	auipc	ra,0x0
    800023a4:	f4a080e7          	jalr	-182(ra) # 800022ea <wakeup>
    800023a8:	b7d5                	j	8000238c <reparent+0x2c>
}
    800023aa:	70a2                	ld	ra,40(sp)
    800023ac:	7402                	ld	s0,32(sp)
    800023ae:	64e2                	ld	s1,24(sp)
    800023b0:	6942                	ld	s2,16(sp)
    800023b2:	69a2                	ld	s3,8(sp)
    800023b4:	6a02                	ld	s4,0(sp)
    800023b6:	6145                	addi	sp,sp,48
    800023b8:	8082                	ret

00000000800023ba <exit>:
{
    800023ba:	7179                	addi	sp,sp,-48
    800023bc:	f406                	sd	ra,40(sp)
    800023be:	f022                	sd	s0,32(sp)
    800023c0:	ec26                	sd	s1,24(sp)
    800023c2:	e84a                	sd	s2,16(sp)
    800023c4:	e44e                	sd	s3,8(sp)
    800023c6:	e052                	sd	s4,0(sp)
    800023c8:	1800                	addi	s0,sp,48
    800023ca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	6ae080e7          	jalr	1710(ra) # 80001a7a <myproc>
    800023d4:	89aa                	mv	s3,a0
  if (p == initproc)
    800023d6:	00009797          	auipc	a5,0x9
    800023da:	fa27b783          	ld	a5,-94(a5) # 8000b378 <initproc>
    800023de:	0d050493          	addi	s1,a0,208
    800023e2:	15050913          	addi	s2,a0,336
    800023e6:	02a79363          	bne	a5,a0,8000240c <exit+0x52>
    panic("init exiting");
    800023ea:	00006517          	auipc	a0,0x6
    800023ee:	e5650513          	addi	a0,a0,-426 # 80008240 <etext+0x240>
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	16e080e7          	jalr	366(ra) # 80000560 <panic>
      fileclose(f);
    800023fa:	00002097          	auipc	ra,0x2
    800023fe:	71c080e7          	jalr	1820(ra) # 80004b16 <fileclose>
      p->ofile[fd] = 0;
    80002402:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002406:	04a1                	addi	s1,s1,8
    80002408:	01248563          	beq	s1,s2,80002412 <exit+0x58>
    if (p->ofile[fd])
    8000240c:	6088                	ld	a0,0(s1)
    8000240e:	f575                	bnez	a0,800023fa <exit+0x40>
    80002410:	bfdd                	j	80002406 <exit+0x4c>
  begin_op();
    80002412:	00002097          	auipc	ra,0x2
    80002416:	23a080e7          	jalr	570(ra) # 8000464c <begin_op>
  iput(p->cwd);
    8000241a:	1509b503          	ld	a0,336(s3)
    8000241e:	00002097          	auipc	ra,0x2
    80002422:	a1e080e7          	jalr	-1506(ra) # 80003e3c <iput>
  end_op();
    80002426:	00002097          	auipc	ra,0x2
    8000242a:	2a0080e7          	jalr	672(ra) # 800046c6 <end_op>
  p->cwd = 0;
    8000242e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002432:	00011497          	auipc	s1,0x11
    80002436:	1d648493          	addi	s1,s1,470 # 80013608 <wait_lock>
    8000243a:	8526                	mv	a0,s1
    8000243c:	ffffe097          	auipc	ra,0xffffe
    80002440:	7fc080e7          	jalr	2044(ra) # 80000c38 <acquire>
  reparent(p);
    80002444:	854e                	mv	a0,s3
    80002446:	00000097          	auipc	ra,0x0
    8000244a:	f1a080e7          	jalr	-230(ra) # 80002360 <reparent>
  wakeup(p->parent);
    8000244e:	0389b503          	ld	a0,56(s3)
    80002452:	00000097          	auipc	ra,0x0
    80002456:	e98080e7          	jalr	-360(ra) # 800022ea <wakeup>
  acquire(&p->lock);
    8000245a:	854e                	mv	a0,s3
    8000245c:	ffffe097          	auipc	ra,0xffffe
    80002460:	7dc080e7          	jalr	2012(ra) # 80000c38 <acquire>
  p->xstate = status;
    80002464:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002468:	4795                	li	a5,5
    8000246a:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000246e:	00009797          	auipc	a5,0x9
    80002472:	f127a783          	lw	a5,-238(a5) # 8000b380 <ticks>
    80002476:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	870080e7          	jalr	-1936(ra) # 80000cec <release>
  sched();
    80002484:	00000097          	auipc	ra,0x0
    80002488:	cf0080e7          	jalr	-784(ra) # 80002174 <sched>
  panic("zombie exit");
    8000248c:	00006517          	auipc	a0,0x6
    80002490:	dc450513          	addi	a0,a0,-572 # 80008250 <etext+0x250>
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	0cc080e7          	jalr	204(ra) # 80000560 <panic>

000000008000249c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000249c:	7179                	addi	sp,sp,-48
    8000249e:	f406                	sd	ra,40(sp)
    800024a0:	f022                	sd	s0,32(sp)
    800024a2:	ec26                	sd	s1,24(sp)
    800024a4:	e84a                	sd	s2,16(sp)
    800024a6:	e44e                	sd	s3,8(sp)
    800024a8:	1800                	addi	s0,sp,48
    800024aa:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024ac:	00011497          	auipc	s1,0x11
    800024b0:	57448493          	addi	s1,s1,1396 # 80013a20 <proc>
    800024b4:	0001b997          	auipc	s3,0x1b
    800024b8:	56c98993          	addi	s3,s3,1388 # 8001da20 <tickslock>
  {
    acquire(&p->lock);
    800024bc:	8526                	mv	a0,s1
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	77a080e7          	jalr	1914(ra) # 80000c38 <acquire>
    if (p->pid == pid)
    800024c6:	589c                	lw	a5,48(s1)
    800024c8:	01278d63          	beq	a5,s2,800024e2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024cc:	8526                	mv	a0,s1
    800024ce:	fffff097          	auipc	ra,0xfffff
    800024d2:	81e080e7          	jalr	-2018(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024d6:	28048493          	addi	s1,s1,640
    800024da:	ff3491e3          	bne	s1,s3,800024bc <kill+0x20>
  }
  return -1;
    800024de:	557d                	li	a0,-1
    800024e0:	a829                	j	800024fa <kill+0x5e>
      p->killed = 1;
    800024e2:	4785                	li	a5,1
    800024e4:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800024e6:	4c98                	lw	a4,24(s1)
    800024e8:	4789                	li	a5,2
    800024ea:	00f70f63          	beq	a4,a5,80002508 <kill+0x6c>
      release(&p->lock);
    800024ee:	8526                	mv	a0,s1
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	7fc080e7          	jalr	2044(ra) # 80000cec <release>
      return 0;
    800024f8:	4501                	li	a0,0
}
    800024fa:	70a2                	ld	ra,40(sp)
    800024fc:	7402                	ld	s0,32(sp)
    800024fe:	64e2                	ld	s1,24(sp)
    80002500:	6942                	ld	s2,16(sp)
    80002502:	69a2                	ld	s3,8(sp)
    80002504:	6145                	addi	sp,sp,48
    80002506:	8082                	ret
        p->state = RUNNABLE;
    80002508:	478d                	li	a5,3
    8000250a:	cc9c                	sw	a5,24(s1)
    8000250c:	b7cd                	j	800024ee <kill+0x52>

000000008000250e <setkilled>:

void setkilled(struct proc *p)
{
    8000250e:	1101                	addi	sp,sp,-32
    80002510:	ec06                	sd	ra,24(sp)
    80002512:	e822                	sd	s0,16(sp)
    80002514:	e426                	sd	s1,8(sp)
    80002516:	1000                	addi	s0,sp,32
    80002518:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	71e080e7          	jalr	1822(ra) # 80000c38 <acquire>
  p->killed = 1;
    80002522:	4785                	li	a5,1
    80002524:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002526:	8526                	mv	a0,s1
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	7c4080e7          	jalr	1988(ra) # 80000cec <release>
}
    80002530:	60e2                	ld	ra,24(sp)
    80002532:	6442                	ld	s0,16(sp)
    80002534:	64a2                	ld	s1,8(sp)
    80002536:	6105                	addi	sp,sp,32
    80002538:	8082                	ret

000000008000253a <killed>:

int killed(struct proc *p)
{
    8000253a:	1101                	addi	sp,sp,-32
    8000253c:	ec06                	sd	ra,24(sp)
    8000253e:	e822                	sd	s0,16(sp)
    80002540:	e426                	sd	s1,8(sp)
    80002542:	e04a                	sd	s2,0(sp)
    80002544:	1000                	addi	s0,sp,32
    80002546:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	6f0080e7          	jalr	1776(ra) # 80000c38 <acquire>
  k = p->killed;
    80002550:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002554:	8526                	mv	a0,s1
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	796080e7          	jalr	1942(ra) # 80000cec <release>
  return k;
}
    8000255e:	854a                	mv	a0,s2
    80002560:	60e2                	ld	ra,24(sp)
    80002562:	6442                	ld	s0,16(sp)
    80002564:	64a2                	ld	s1,8(sp)
    80002566:	6902                	ld	s2,0(sp)
    80002568:	6105                	addi	sp,sp,32
    8000256a:	8082                	ret

000000008000256c <wait>:
{
    8000256c:	715d                	addi	sp,sp,-80
    8000256e:	e486                	sd	ra,72(sp)
    80002570:	e0a2                	sd	s0,64(sp)
    80002572:	fc26                	sd	s1,56(sp)
    80002574:	f84a                	sd	s2,48(sp)
    80002576:	f44e                	sd	s3,40(sp)
    80002578:	f052                	sd	s4,32(sp)
    8000257a:	ec56                	sd	s5,24(sp)
    8000257c:	e85a                	sd	s6,16(sp)
    8000257e:	e45e                	sd	s7,8(sp)
    80002580:	e062                	sd	s8,0(sp)
    80002582:	0880                	addi	s0,sp,80
    80002584:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002586:	fffff097          	auipc	ra,0xfffff
    8000258a:	4f4080e7          	jalr	1268(ra) # 80001a7a <myproc>
    8000258e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002590:	00011517          	auipc	a0,0x11
    80002594:	07850513          	addi	a0,a0,120 # 80013608 <wait_lock>
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	6a0080e7          	jalr	1696(ra) # 80000c38 <acquire>
    havekids = 0;
    800025a0:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800025a2:	4a15                	li	s4,5
        havekids = 1;
    800025a4:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800025a6:	0001b997          	auipc	s3,0x1b
    800025aa:	47a98993          	addi	s3,s3,1146 # 8001da20 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025ae:	00011c17          	auipc	s8,0x11
    800025b2:	05ac0c13          	addi	s8,s8,90 # 80013608 <wait_lock>
    800025b6:	a0d1                	j	8000267a <wait+0x10e>
          pid = pp->pid;
    800025b8:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025bc:	000b0e63          	beqz	s6,800025d8 <wait+0x6c>
    800025c0:	4691                	li	a3,4
    800025c2:	02c48613          	addi	a2,s1,44
    800025c6:	85da                	mv	a1,s6
    800025c8:	05093503          	ld	a0,80(s2)
    800025cc:	fffff097          	auipc	ra,0xfffff
    800025d0:	116080e7          	jalr	278(ra) # 800016e2 <copyout>
    800025d4:	04054163          	bltz	a0,80002616 <wait+0xaa>
          freeproc(pp);
    800025d8:	8526                	mv	a0,s1
    800025da:	fffff097          	auipc	ra,0xfffff
    800025de:	67e080e7          	jalr	1662(ra) # 80001c58 <freeproc>
          release(&pp->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	708080e7          	jalr	1800(ra) # 80000cec <release>
          release(&wait_lock);
    800025ec:	00011517          	auipc	a0,0x11
    800025f0:	01c50513          	addi	a0,a0,28 # 80013608 <wait_lock>
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	6f8080e7          	jalr	1784(ra) # 80000cec <release>
}
    800025fc:	854e                	mv	a0,s3
    800025fe:	60a6                	ld	ra,72(sp)
    80002600:	6406                	ld	s0,64(sp)
    80002602:	74e2                	ld	s1,56(sp)
    80002604:	7942                	ld	s2,48(sp)
    80002606:	79a2                	ld	s3,40(sp)
    80002608:	7a02                	ld	s4,32(sp)
    8000260a:	6ae2                	ld	s5,24(sp)
    8000260c:	6b42                	ld	s6,16(sp)
    8000260e:	6ba2                	ld	s7,8(sp)
    80002610:	6c02                	ld	s8,0(sp)
    80002612:	6161                	addi	sp,sp,80
    80002614:	8082                	ret
            release(&pp->lock);
    80002616:	8526                	mv	a0,s1
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	6d4080e7          	jalr	1748(ra) # 80000cec <release>
            release(&wait_lock);
    80002620:	00011517          	auipc	a0,0x11
    80002624:	fe850513          	addi	a0,a0,-24 # 80013608 <wait_lock>
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	6c4080e7          	jalr	1732(ra) # 80000cec <release>
            return -1;
    80002630:	59fd                	li	s3,-1
    80002632:	b7e9                	j	800025fc <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002634:	28048493          	addi	s1,s1,640
    80002638:	03348463          	beq	s1,s3,80002660 <wait+0xf4>
      if (pp->parent == p)
    8000263c:	7c9c                	ld	a5,56(s1)
    8000263e:	ff279be3          	bne	a5,s2,80002634 <wait+0xc8>
        acquire(&pp->lock);
    80002642:	8526                	mv	a0,s1
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	5f4080e7          	jalr	1524(ra) # 80000c38 <acquire>
        if (pp->state == ZOMBIE)
    8000264c:	4c9c                	lw	a5,24(s1)
    8000264e:	f74785e3          	beq	a5,s4,800025b8 <wait+0x4c>
        release(&pp->lock);
    80002652:	8526                	mv	a0,s1
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	698080e7          	jalr	1688(ra) # 80000cec <release>
        havekids = 1;
    8000265c:	8756                	mv	a4,s5
    8000265e:	bfd9                	j	80002634 <wait+0xc8>
    if (!havekids || killed(p))
    80002660:	c31d                	beqz	a4,80002686 <wait+0x11a>
    80002662:	854a                	mv	a0,s2
    80002664:	00000097          	auipc	ra,0x0
    80002668:	ed6080e7          	jalr	-298(ra) # 8000253a <killed>
    8000266c:	ed09                	bnez	a0,80002686 <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000266e:	85e2                	mv	a1,s8
    80002670:	854a                	mv	a0,s2
    80002672:	00000097          	auipc	ra,0x0
    80002676:	c14080e7          	jalr	-1004(ra) # 80002286 <sleep>
    havekids = 0;
    8000267a:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000267c:	00011497          	auipc	s1,0x11
    80002680:	3a448493          	addi	s1,s1,932 # 80013a20 <proc>
    80002684:	bf65                	j	8000263c <wait+0xd0>
      release(&wait_lock);
    80002686:	00011517          	auipc	a0,0x11
    8000268a:	f8250513          	addi	a0,a0,-126 # 80013608 <wait_lock>
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	65e080e7          	jalr	1630(ra) # 80000cec <release>
      return -1;
    80002696:	59fd                	li	s3,-1
    80002698:	b795                	j	800025fc <wait+0x90>

000000008000269a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000269a:	7179                	addi	sp,sp,-48
    8000269c:	f406                	sd	ra,40(sp)
    8000269e:	f022                	sd	s0,32(sp)
    800026a0:	ec26                	sd	s1,24(sp)
    800026a2:	e84a                	sd	s2,16(sp)
    800026a4:	e44e                	sd	s3,8(sp)
    800026a6:	e052                	sd	s4,0(sp)
    800026a8:	1800                	addi	s0,sp,48
    800026aa:	84aa                	mv	s1,a0
    800026ac:	892e                	mv	s2,a1
    800026ae:	89b2                	mv	s3,a2
    800026b0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026b2:	fffff097          	auipc	ra,0xfffff
    800026b6:	3c8080e7          	jalr	968(ra) # 80001a7a <myproc>
  if (user_dst)
    800026ba:	c08d                	beqz	s1,800026dc <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800026bc:	86d2                	mv	a3,s4
    800026be:	864e                	mv	a2,s3
    800026c0:	85ca                	mv	a1,s2
    800026c2:	6928                	ld	a0,80(a0)
    800026c4:	fffff097          	auipc	ra,0xfffff
    800026c8:	01e080e7          	jalr	30(ra) # 800016e2 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026cc:	70a2                	ld	ra,40(sp)
    800026ce:	7402                	ld	s0,32(sp)
    800026d0:	64e2                	ld	s1,24(sp)
    800026d2:	6942                	ld	s2,16(sp)
    800026d4:	69a2                	ld	s3,8(sp)
    800026d6:	6a02                	ld	s4,0(sp)
    800026d8:	6145                	addi	sp,sp,48
    800026da:	8082                	ret
    memmove((char *)dst, src, len);
    800026dc:	000a061b          	sext.w	a2,s4
    800026e0:	85ce                	mv	a1,s3
    800026e2:	854a                	mv	a0,s2
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	6ac080e7          	jalr	1708(ra) # 80000d90 <memmove>
    return 0;
    800026ec:	8526                	mv	a0,s1
    800026ee:	bff9                	j	800026cc <either_copyout+0x32>

00000000800026f0 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026f0:	7179                	addi	sp,sp,-48
    800026f2:	f406                	sd	ra,40(sp)
    800026f4:	f022                	sd	s0,32(sp)
    800026f6:	ec26                	sd	s1,24(sp)
    800026f8:	e84a                	sd	s2,16(sp)
    800026fa:	e44e                	sd	s3,8(sp)
    800026fc:	e052                	sd	s4,0(sp)
    800026fe:	1800                	addi	s0,sp,48
    80002700:	892a                	mv	s2,a0
    80002702:	84ae                	mv	s1,a1
    80002704:	89b2                	mv	s3,a2
    80002706:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002708:	fffff097          	auipc	ra,0xfffff
    8000270c:	372080e7          	jalr	882(ra) # 80001a7a <myproc>
  if (user_src)
    80002710:	c08d                	beqz	s1,80002732 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002712:	86d2                	mv	a3,s4
    80002714:	864e                	mv	a2,s3
    80002716:	85ca                	mv	a1,s2
    80002718:	6928                	ld	a0,80(a0)
    8000271a:	fffff097          	auipc	ra,0xfffff
    8000271e:	054080e7          	jalr	84(ra) # 8000176e <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002722:	70a2                	ld	ra,40(sp)
    80002724:	7402                	ld	s0,32(sp)
    80002726:	64e2                	ld	s1,24(sp)
    80002728:	6942                	ld	s2,16(sp)
    8000272a:	69a2                	ld	s3,8(sp)
    8000272c:	6a02                	ld	s4,0(sp)
    8000272e:	6145                	addi	sp,sp,48
    80002730:	8082                	ret
    memmove(dst, (char *)src, len);
    80002732:	000a061b          	sext.w	a2,s4
    80002736:	85ce                	mv	a1,s3
    80002738:	854a                	mv	a0,s2
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	656080e7          	jalr	1622(ra) # 80000d90 <memmove>
    return 0;
    80002742:	8526                	mv	a0,s1
    80002744:	bff9                	j	80002722 <either_copyin+0x32>

0000000080002746 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002746:	715d                	addi	sp,sp,-80
    80002748:	e486                	sd	ra,72(sp)
    8000274a:	e0a2                	sd	s0,64(sp)
    8000274c:	fc26                	sd	s1,56(sp)
    8000274e:	f84a                	sd	s2,48(sp)
    80002750:	f44e                	sd	s3,40(sp)
    80002752:	f052                	sd	s4,32(sp)
    80002754:	ec56                	sd	s5,24(sp)
    80002756:	e85a                	sd	s6,16(sp)
    80002758:	e45e                	sd	s7,8(sp)
    8000275a:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000275c:	00006517          	auipc	a0,0x6
    80002760:	8b450513          	addi	a0,a0,-1868 # 80008010 <etext+0x10>
    80002764:	ffffe097          	auipc	ra,0xffffe
    80002768:	e46080e7          	jalr	-442(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000276c:	00011497          	auipc	s1,0x11
    80002770:	40c48493          	addi	s1,s1,1036 # 80013b78 <proc+0x158>
    80002774:	0001b917          	auipc	s2,0x1b
    80002778:	40490913          	addi	s2,s2,1028 # 8001db78 <bcache+0x68>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000277c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000277e:	00006997          	auipc	s3,0x6
    80002782:	ae298993          	addi	s3,s3,-1310 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002786:	00006a97          	auipc	s5,0x6
    8000278a:	ae2a8a93          	addi	s5,s5,-1310 # 80008268 <etext+0x268>
    printf("\n");
    8000278e:	00006a17          	auipc	s4,0x6
    80002792:	882a0a13          	addi	s4,s4,-1918 # 80008010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002796:	00006b97          	auipc	s7,0x6
    8000279a:	fc2b8b93          	addi	s7,s7,-62 # 80008758 <states.0>
    8000279e:	a00d                	j	800027c0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027a0:	ed86a583          	lw	a1,-296(a3)
    800027a4:	8556                	mv	a0,s5
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	e04080e7          	jalr	-508(ra) # 800005aa <printf>
    printf("\n");
    800027ae:	8552                	mv	a0,s4
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	dfa080e7          	jalr	-518(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800027b8:	28048493          	addi	s1,s1,640
    800027bc:	03248263          	beq	s1,s2,800027e0 <procdump+0x9a>
    if (p->state == UNUSED)
    800027c0:	86a6                	mv	a3,s1
    800027c2:	ec04a783          	lw	a5,-320(s1)
    800027c6:	dbed                	beqz	a5,800027b8 <procdump+0x72>
      state = "???";
    800027c8:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ca:	fcfb6be3          	bltu	s6,a5,800027a0 <procdump+0x5a>
    800027ce:	02079713          	slli	a4,a5,0x20
    800027d2:	01d75793          	srli	a5,a4,0x1d
    800027d6:	97de                	add	a5,a5,s7
    800027d8:	6390                	ld	a2,0(a5)
    800027da:	f279                	bnez	a2,800027a0 <procdump+0x5a>
      state = "???";
    800027dc:	864e                	mv	a2,s3
    800027de:	b7c9                	j	800027a0 <procdump+0x5a>
  }
}
    800027e0:	60a6                	ld	ra,72(sp)
    800027e2:	6406                	ld	s0,64(sp)
    800027e4:	74e2                	ld	s1,56(sp)
    800027e6:	7942                	ld	s2,48(sp)
    800027e8:	79a2                	ld	s3,40(sp)
    800027ea:	7a02                	ld	s4,32(sp)
    800027ec:	6ae2                	ld	s5,24(sp)
    800027ee:	6b42                	ld	s6,16(sp)
    800027f0:	6ba2                	ld	s7,8(sp)
    800027f2:	6161                	addi	sp,sp,80
    800027f4:	8082                	ret

00000000800027f6 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800027f6:	711d                	addi	sp,sp,-96
    800027f8:	ec86                	sd	ra,88(sp)
    800027fa:	e8a2                	sd	s0,80(sp)
    800027fc:	e4a6                	sd	s1,72(sp)
    800027fe:	e0ca                	sd	s2,64(sp)
    80002800:	fc4e                	sd	s3,56(sp)
    80002802:	f852                	sd	s4,48(sp)
    80002804:	f456                	sd	s5,40(sp)
    80002806:	f05a                	sd	s6,32(sp)
    80002808:	ec5e                	sd	s7,24(sp)
    8000280a:	e862                	sd	s8,16(sp)
    8000280c:	e466                	sd	s9,8(sp)
    8000280e:	e06a                	sd	s10,0(sp)
    80002810:	1080                	addi	s0,sp,96
    80002812:	8b2a                	mv	s6,a0
    80002814:	8bae                	mv	s7,a1
    80002816:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002818:	fffff097          	auipc	ra,0xfffff
    8000281c:	262080e7          	jalr	610(ra) # 80001a7a <myproc>
    80002820:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002822:	00011517          	auipc	a0,0x11
    80002826:	de650513          	addi	a0,a0,-538 # 80013608 <wait_lock>
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	40e080e7          	jalr	1038(ra) # 80000c38 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002832:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002834:	4a15                	li	s4,5
        havekids = 1;
    80002836:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002838:	0001b997          	auipc	s3,0x1b
    8000283c:	1e898993          	addi	s3,s3,488 # 8001da20 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002840:	00011d17          	auipc	s10,0x11
    80002844:	dc8d0d13          	addi	s10,s10,-568 # 80013608 <wait_lock>
    80002848:	a8e9                	j	80002922 <waitx+0x12c>
          pid = np->pid;
    8000284a:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000284e:	1684a783          	lw	a5,360(s1)
    80002852:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002856:	16c4a703          	lw	a4,364(s1)
    8000285a:	9f3d                	addw	a4,a4,a5
    8000285c:	1704a783          	lw	a5,368(s1)
    80002860:	9f99                	subw	a5,a5,a4
    80002862:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002866:	000b0e63          	beqz	s6,80002882 <waitx+0x8c>
    8000286a:	4691                	li	a3,4
    8000286c:	02c48613          	addi	a2,s1,44
    80002870:	85da                	mv	a1,s6
    80002872:	05093503          	ld	a0,80(s2)
    80002876:	fffff097          	auipc	ra,0xfffff
    8000287a:	e6c080e7          	jalr	-404(ra) # 800016e2 <copyout>
    8000287e:	04054363          	bltz	a0,800028c4 <waitx+0xce>
          freeproc(np);
    80002882:	8526                	mv	a0,s1
    80002884:	fffff097          	auipc	ra,0xfffff
    80002888:	3d4080e7          	jalr	980(ra) # 80001c58 <freeproc>
          release(&np->lock);
    8000288c:	8526                	mv	a0,s1
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	45e080e7          	jalr	1118(ra) # 80000cec <release>
          release(&wait_lock);
    80002896:	00011517          	auipc	a0,0x11
    8000289a:	d7250513          	addi	a0,a0,-654 # 80013608 <wait_lock>
    8000289e:	ffffe097          	auipc	ra,0xffffe
    800028a2:	44e080e7          	jalr	1102(ra) # 80000cec <release>
  }
}
    800028a6:	854e                	mv	a0,s3
    800028a8:	60e6                	ld	ra,88(sp)
    800028aa:	6446                	ld	s0,80(sp)
    800028ac:	64a6                	ld	s1,72(sp)
    800028ae:	6906                	ld	s2,64(sp)
    800028b0:	79e2                	ld	s3,56(sp)
    800028b2:	7a42                	ld	s4,48(sp)
    800028b4:	7aa2                	ld	s5,40(sp)
    800028b6:	7b02                	ld	s6,32(sp)
    800028b8:	6be2                	ld	s7,24(sp)
    800028ba:	6c42                	ld	s8,16(sp)
    800028bc:	6ca2                	ld	s9,8(sp)
    800028be:	6d02                	ld	s10,0(sp)
    800028c0:	6125                	addi	sp,sp,96
    800028c2:	8082                	ret
            release(&np->lock);
    800028c4:	8526                	mv	a0,s1
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	426080e7          	jalr	1062(ra) # 80000cec <release>
            release(&wait_lock);
    800028ce:	00011517          	auipc	a0,0x11
    800028d2:	d3a50513          	addi	a0,a0,-710 # 80013608 <wait_lock>
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	416080e7          	jalr	1046(ra) # 80000cec <release>
            return -1;
    800028de:	59fd                	li	s3,-1
    800028e0:	b7d9                	j	800028a6 <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    800028e2:	28048493          	addi	s1,s1,640
    800028e6:	03348463          	beq	s1,s3,8000290e <waitx+0x118>
      if (np->parent == p)
    800028ea:	7c9c                	ld	a5,56(s1)
    800028ec:	ff279be3          	bne	a5,s2,800028e2 <waitx+0xec>
        acquire(&np->lock);
    800028f0:	8526                	mv	a0,s1
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	346080e7          	jalr	838(ra) # 80000c38 <acquire>
        if (np->state == ZOMBIE)
    800028fa:	4c9c                	lw	a5,24(s1)
    800028fc:	f54787e3          	beq	a5,s4,8000284a <waitx+0x54>
        release(&np->lock);
    80002900:	8526                	mv	a0,s1
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	3ea080e7          	jalr	1002(ra) # 80000cec <release>
        havekids = 1;
    8000290a:	8756                	mv	a4,s5
    8000290c:	bfd9                	j	800028e2 <waitx+0xec>
    if (!havekids || p->killed)
    8000290e:	c305                	beqz	a4,8000292e <waitx+0x138>
    80002910:	02892783          	lw	a5,40(s2)
    80002914:	ef89                	bnez	a5,8000292e <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002916:	85ea                	mv	a1,s10
    80002918:	854a                	mv	a0,s2
    8000291a:	00000097          	auipc	ra,0x0
    8000291e:	96c080e7          	jalr	-1684(ra) # 80002286 <sleep>
    havekids = 0;
    80002922:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002924:	00011497          	auipc	s1,0x11
    80002928:	0fc48493          	addi	s1,s1,252 # 80013a20 <proc>
    8000292c:	bf7d                	j	800028ea <waitx+0xf4>
      release(&wait_lock);
    8000292e:	00011517          	auipc	a0,0x11
    80002932:	cda50513          	addi	a0,a0,-806 # 80013608 <wait_lock>
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	3b6080e7          	jalr	950(ra) # 80000cec <release>
      return -1;
    8000293e:	59fd                	li	s3,-1
    80002940:	b79d                	j	800028a6 <waitx+0xb0>

0000000080002942 <update_time>:

void update_time()
{
    80002942:	7179                	addi	sp,sp,-48
    80002944:	f406                	sd	ra,40(sp)
    80002946:	f022                	sd	s0,32(sp)
    80002948:	ec26                	sd	s1,24(sp)
    8000294a:	e84a                	sd	s2,16(sp)
    8000294c:	e44e                	sd	s3,8(sp)
    8000294e:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002950:	00011497          	auipc	s1,0x11
    80002954:	0d048493          	addi	s1,s1,208 # 80013a20 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002958:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    8000295a:	0001b917          	auipc	s2,0x1b
    8000295e:	0c690913          	addi	s2,s2,198 # 8001da20 <tickslock>
    80002962:	a811                	j	80002976 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002964:	8526                	mv	a0,s1
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	386080e7          	jalr	902(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000296e:	28048493          	addi	s1,s1,640
    80002972:	03248063          	beq	s1,s2,80002992 <update_time+0x50>
    acquire(&p->lock);
    80002976:	8526                	mv	a0,s1
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	2c0080e7          	jalr	704(ra) # 80000c38 <acquire>
    if (p->state == RUNNING)
    80002980:	4c9c                	lw	a5,24(s1)
    80002982:	ff3791e3          	bne	a5,s3,80002964 <update_time+0x22>
      p->rtime++;
    80002986:	1684a783          	lw	a5,360(s1)
    8000298a:	2785                	addiw	a5,a5,1
    8000298c:	16f4a423          	sw	a5,360(s1)
    80002990:	bfd1                	j	80002964 <update_time+0x22>
  }
    80002992:	70a2                	ld	ra,40(sp)
    80002994:	7402                	ld	s0,32(sp)
    80002996:	64e2                	ld	s1,24(sp)
    80002998:	6942                	ld	s2,16(sp)
    8000299a:	69a2                	ld	s3,8(sp)
    8000299c:	6145                	addi	sp,sp,48
    8000299e:	8082                	ret

00000000800029a0 <swtch>:
    800029a0:	00153023          	sd	ra,0(a0)
    800029a4:	00253423          	sd	sp,8(a0)
    800029a8:	e900                	sd	s0,16(a0)
    800029aa:	ed04                	sd	s1,24(a0)
    800029ac:	03253023          	sd	s2,32(a0)
    800029b0:	03353423          	sd	s3,40(a0)
    800029b4:	03453823          	sd	s4,48(a0)
    800029b8:	03553c23          	sd	s5,56(a0)
    800029bc:	05653023          	sd	s6,64(a0)
    800029c0:	05753423          	sd	s7,72(a0)
    800029c4:	05853823          	sd	s8,80(a0)
    800029c8:	05953c23          	sd	s9,88(a0)
    800029cc:	07a53023          	sd	s10,96(a0)
    800029d0:	07b53423          	sd	s11,104(a0)
    800029d4:	0005b083          	ld	ra,0(a1)
    800029d8:	0085b103          	ld	sp,8(a1)
    800029dc:	6980                	ld	s0,16(a1)
    800029de:	6d84                	ld	s1,24(a1)
    800029e0:	0205b903          	ld	s2,32(a1)
    800029e4:	0285b983          	ld	s3,40(a1)
    800029e8:	0305ba03          	ld	s4,48(a1)
    800029ec:	0385ba83          	ld	s5,56(a1)
    800029f0:	0405bb03          	ld	s6,64(a1)
    800029f4:	0485bb83          	ld	s7,72(a1)
    800029f8:	0505bc03          	ld	s8,80(a1)
    800029fc:	0585bc83          	ld	s9,88(a1)
    80002a00:	0605bd03          	ld	s10,96(a1)
    80002a04:	0685bd83          	ld	s11,104(a1)
    80002a08:	8082                	ret

0000000080002a0a <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002a0a:	1141                	addi	sp,sp,-16
    80002a0c:	e406                	sd	ra,8(sp)
    80002a0e:	e022                	sd	s0,0(sp)
    80002a10:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a12:	00006597          	auipc	a1,0x6
    80002a16:	89658593          	addi	a1,a1,-1898 # 800082a8 <etext+0x2a8>
    80002a1a:	0001b517          	auipc	a0,0x1b
    80002a1e:	00650513          	addi	a0,a0,6 # 8001da20 <tickslock>
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	186080e7          	jalr	390(ra) # 80000ba8 <initlock>
}
    80002a2a:	60a2                	ld	ra,8(sp)
    80002a2c:	6402                	ld	s0,0(sp)
    80002a2e:	0141                	addi	sp,sp,16
    80002a30:	8082                	ret

0000000080002a32 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002a32:	1141                	addi	sp,sp,-16
    80002a34:	e422                	sd	s0,8(sp)
    80002a36:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a38:	00003797          	auipc	a5,0x3
    80002a3c:	7e878793          	addi	a5,a5,2024 # 80006220 <kernelvec>
    80002a40:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a44:	6422                	ld	s0,8(sp)
    80002a46:	0141                	addi	sp,sp,16
    80002a48:	8082                	ret

0000000080002a4a <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002a4a:	1141                	addi	sp,sp,-16
    80002a4c:	e406                	sd	ra,8(sp)
    80002a4e:	e022                	sd	s0,0(sp)
    80002a50:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a52:	fffff097          	auipc	ra,0xfffff
    80002a56:	028080e7          	jalr	40(ra) # 80001a7a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a5a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a5e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a60:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a64:	00004697          	auipc	a3,0x4
    80002a68:	59c68693          	addi	a3,a3,1436 # 80007000 <_trampoline>
    80002a6c:	00004717          	auipc	a4,0x4
    80002a70:	59470713          	addi	a4,a4,1428 # 80007000 <_trampoline>
    80002a74:	8f15                	sub	a4,a4,a3
    80002a76:	040007b7          	lui	a5,0x4000
    80002a7a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002a7c:	07b2                	slli	a5,a5,0xc
    80002a7e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a80:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a84:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a86:	18002673          	csrr	a2,satp
    80002a8a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a8c:	6d30                	ld	a2,88(a0)
    80002a8e:	6138                	ld	a4,64(a0)
    80002a90:	6585                	lui	a1,0x1
    80002a92:	972e                	add	a4,a4,a1
    80002a94:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a96:	6d38                	ld	a4,88(a0)
    80002a98:	00000617          	auipc	a2,0x0
    80002a9c:	14660613          	addi	a2,a2,326 # 80002bde <usertrap>
    80002aa0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002aa2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002aa4:	8612                	mv	a2,tp
    80002aa6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002aac:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ab0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ab4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ab8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002aba:	6f18                	ld	a4,24(a4)
    80002abc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ac0:	6928                	ld	a0,80(a0)
    80002ac2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002ac4:	00004717          	auipc	a4,0x4
    80002ac8:	5d870713          	addi	a4,a4,1496 # 8000709c <userret>
    80002acc:	8f15                	sub	a4,a4,a3
    80002ace:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ad0:	577d                	li	a4,-1
    80002ad2:	177e                	slli	a4,a4,0x3f
    80002ad4:	8d59                	or	a0,a0,a4
    80002ad6:	9782                	jalr	a5
}
    80002ad8:	60a2                	ld	ra,8(sp)
    80002ada:	6402                	ld	s0,0(sp)
    80002adc:	0141                	addi	sp,sp,16
    80002ade:	8082                	ret

0000000080002ae0 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002ae0:	1101                	addi	sp,sp,-32
    80002ae2:	ec06                	sd	ra,24(sp)
    80002ae4:	e822                	sd	s0,16(sp)
    80002ae6:	e426                	sd	s1,8(sp)
    80002ae8:	e04a                	sd	s2,0(sp)
    80002aea:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002aec:	0001b917          	auipc	s2,0x1b
    80002af0:	f3490913          	addi	s2,s2,-204 # 8001da20 <tickslock>
    80002af4:	854a                	mv	a0,s2
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	142080e7          	jalr	322(ra) # 80000c38 <acquire>
  ticks++;
    80002afe:	00009497          	auipc	s1,0x9
    80002b02:	88248493          	addi	s1,s1,-1918 # 8000b380 <ticks>
    80002b06:	409c                	lw	a5,0(s1)
    80002b08:	2785                	addiw	a5,a5,1
    80002b0a:	c09c                	sw	a5,0(s1)
  update_time();
    80002b0c:	00000097          	auipc	ra,0x0
    80002b10:	e36080e7          	jalr	-458(ra) # 80002942 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002b14:	8526                	mv	a0,s1
    80002b16:	fffff097          	auipc	ra,0xfffff
    80002b1a:	7d4080e7          	jalr	2004(ra) # 800022ea <wakeup>
  release(&tickslock);
    80002b1e:	854a                	mv	a0,s2
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	1cc080e7          	jalr	460(ra) # 80000cec <release>
}
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6902                	ld	s2,0(sp)
    80002b30:	6105                	addi	sp,sp,32
    80002b32:	8082                	ret

0000000080002b34 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b34:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002b38:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002b3a:	0a07d163          	bgez	a5,80002bdc <devintr+0xa8>
{
    80002b3e:	1101                	addi	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    80002b46:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002b4a:	46a5                	li	a3,9
    80002b4c:	00d70c63          	beq	a4,a3,80002b64 <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    80002b50:	577d                	li	a4,-1
    80002b52:	177e                	slli	a4,a4,0x3f
    80002b54:	0705                	addi	a4,a4,1
    return 0;
    80002b56:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002b58:	06e78163          	beq	a5,a4,80002bba <devintr+0x86>
  }
    80002b5c:	60e2                	ld	ra,24(sp)
    80002b5e:	6442                	ld	s0,16(sp)
    80002b60:	6105                	addi	sp,sp,32
    80002b62:	8082                	ret
    80002b64:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002b66:	00003097          	auipc	ra,0x3
    80002b6a:	7c6080e7          	jalr	1990(ra) # 8000632c <plic_claim>
    80002b6e:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002b70:	47a9                	li	a5,10
    80002b72:	00f50963          	beq	a0,a5,80002b84 <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002b76:	4785                	li	a5,1
    80002b78:	00f50b63          	beq	a0,a5,80002b8e <devintr+0x5a>
    return 1;
    80002b7c:	4505                	li	a0,1
    else if (irq)
    80002b7e:	ec89                	bnez	s1,80002b98 <devintr+0x64>
    80002b80:	64a2                	ld	s1,8(sp)
    80002b82:	bfe9                	j	80002b5c <devintr+0x28>
      uartintr();
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	e76080e7          	jalr	-394(ra) # 800009fa <uartintr>
    if (irq)
    80002b8c:	a839                	j	80002baa <devintr+0x76>
      virtio_disk_intr();
    80002b8e:	00004097          	auipc	ra,0x4
    80002b92:	cc8080e7          	jalr	-824(ra) # 80006856 <virtio_disk_intr>
    if (irq)
    80002b96:	a811                	j	80002baa <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b98:	85a6                	mv	a1,s1
    80002b9a:	00005517          	auipc	a0,0x5
    80002b9e:	71650513          	addi	a0,a0,1814 # 800082b0 <etext+0x2b0>
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	a08080e7          	jalr	-1528(ra) # 800005aa <printf>
      plic_complete(irq);
    80002baa:	8526                	mv	a0,s1
    80002bac:	00003097          	auipc	ra,0x3
    80002bb0:	7a4080e7          	jalr	1956(ra) # 80006350 <plic_complete>
    return 1;
    80002bb4:	4505                	li	a0,1
    80002bb6:	64a2                	ld	s1,8(sp)
    80002bb8:	b755                	j	80002b5c <devintr+0x28>
    if (cpuid() == 0)
    80002bba:	fffff097          	auipc	ra,0xfffff
    80002bbe:	e94080e7          	jalr	-364(ra) # 80001a4e <cpuid>
    80002bc2:	c901                	beqz	a0,80002bd2 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bc4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002bc8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002bca:	14479073          	csrw	sip,a5
    return 2;
    80002bce:	4509                	li	a0,2
    80002bd0:	b771                	j	80002b5c <devintr+0x28>
      clockintr();
    80002bd2:	00000097          	auipc	ra,0x0
    80002bd6:	f0e080e7          	jalr	-242(ra) # 80002ae0 <clockintr>
    80002bda:	b7ed                	j	80002bc4 <devintr+0x90>
    80002bdc:	8082                	ret

0000000080002bde <usertrap>:
{
    80002bde:	1101                	addi	sp,sp,-32
    80002be0:	ec06                	sd	ra,24(sp)
    80002be2:	e822                	sd	s0,16(sp)
    80002be4:	e426                	sd	s1,8(sp)
    80002be6:	e04a                	sd	s2,0(sp)
    80002be8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bea:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002bee:	1007f793          	andi	a5,a5,256
    80002bf2:	e3b1                	bnez	a5,80002c36 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bf4:	00003797          	auipc	a5,0x3
    80002bf8:	62c78793          	addi	a5,a5,1580 # 80006220 <kernelvec>
    80002bfc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	e7a080e7          	jalr	-390(ra) # 80001a7a <myproc>
    80002c08:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c0a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0c:	14102773          	csrr	a4,sepc
    80002c10:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c12:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002c16:	47a1                	li	a5,8
    80002c18:	02f70763          	beq	a4,a5,80002c46 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	f18080e7          	jalr	-232(ra) # 80002b34 <devintr>
    80002c24:	892a                	mv	s2,a0
    80002c26:	c92d                	beqz	a0,80002c98 <usertrap+0xba>
  if (killed(p))
    80002c28:	8526                	mv	a0,s1
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	910080e7          	jalr	-1776(ra) # 8000253a <killed>
    80002c32:	c555                	beqz	a0,80002cde <usertrap+0x100>
    80002c34:	a045                	j	80002cd4 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002c36:	00005517          	auipc	a0,0x5
    80002c3a:	69a50513          	addi	a0,a0,1690 # 800082d0 <etext+0x2d0>
    80002c3e:	ffffe097          	auipc	ra,0xffffe
    80002c42:	922080e7          	jalr	-1758(ra) # 80000560 <panic>
    if (killed(p))
    80002c46:	00000097          	auipc	ra,0x0
    80002c4a:	8f4080e7          	jalr	-1804(ra) # 8000253a <killed>
    80002c4e:	ed1d                	bnez	a0,80002c8c <usertrap+0xae>
    p->trapframe->epc += 4;
    80002c50:	6cb8                	ld	a4,88(s1)
    80002c52:	6f1c                	ld	a5,24(a4)
    80002c54:	0791                	addi	a5,a5,4
    80002c56:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c58:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c5c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c60:	10079073          	csrw	sstatus,a5
    syscall();
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	33c080e7          	jalr	828(ra) # 80002fa0 <syscall>
  if (killed(p))
    80002c6c:	8526                	mv	a0,s1
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	8cc080e7          	jalr	-1844(ra) # 8000253a <killed>
    80002c76:	ed31                	bnez	a0,80002cd2 <usertrap+0xf4>
  usertrapret();
    80002c78:	00000097          	auipc	ra,0x0
    80002c7c:	dd2080e7          	jalr	-558(ra) # 80002a4a <usertrapret>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6902                	ld	s2,0(sp)
    80002c88:	6105                	addi	sp,sp,32
    80002c8a:	8082                	ret
      exit(-1);
    80002c8c:	557d                	li	a0,-1
    80002c8e:	fffff097          	auipc	ra,0xfffff
    80002c92:	72c080e7          	jalr	1836(ra) # 800023ba <exit>
    80002c96:	bf6d                	j	80002c50 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c98:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c9c:	5890                	lw	a2,48(s1)
    80002c9e:	00005517          	auipc	a0,0x5
    80002ca2:	65250513          	addi	a0,a0,1618 # 800082f0 <etext+0x2f0>
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	904080e7          	jalr	-1788(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cb2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	66a50513          	addi	a0,a0,1642 # 80008320 <etext+0x320>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	8ec080e7          	jalr	-1812(ra) # 800005aa <printf>
    setkilled(p);
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	00000097          	auipc	ra,0x0
    80002ccc:	846080e7          	jalr	-1978(ra) # 8000250e <setkilled>
    80002cd0:	bf71                	j	80002c6c <usertrap+0x8e>
  if (killed(p))
    80002cd2:	4901                	li	s2,0
    exit(-1);
    80002cd4:	557d                	li	a0,-1
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	6e4080e7          	jalr	1764(ra) # 800023ba <exit>
  if (which_dev == 2)
    80002cde:	4789                	li	a5,2
    80002ce0:	f8f91ce3          	bne	s2,a5,80002c78 <usertrap+0x9a>
    yield();
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	566080e7          	jalr	1382(ra) # 8000224a <yield>
    struct proc *p = myproc();
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	d8e080e7          	jalr	-626(ra) # 80001a7a <myproc>
    80002cf4:	84aa                	mv	s1,a0
    if (p->alarm_interval > 0)
    80002cf6:	25052703          	lw	a4,592(a0)
    80002cfa:	f6e05fe3          	blez	a4,80002c78 <usertrap+0x9a>
      p->ticks_count++;
    80002cfe:	26052783          	lw	a5,608(a0)
    80002d02:	2785                	addiw	a5,a5,1
    80002d04:	0007869b          	sext.w	a3,a5
    80002d08:	26f52023          	sw	a5,608(a0)
      if (p->ticks_count >= p->alarm_interval && !p->alarm_active)
    80002d0c:	f6e6c6e3          	blt	a3,a4,80002c78 <usertrap+0x9a>
    80002d10:	26452783          	lw	a5,612(a0)
    80002d14:	f3b5                	bnez	a5,80002c78 <usertrap+0x9a>
        p->ticks_count = 0;
    80002d16:	26052023          	sw	zero,608(a0)
        p->alarm_active = 1;
    80002d1a:	4785                	li	a5,1
    80002d1c:	26f52223          	sw	a5,612(a0)
        p->alarm_tf = kalloc();
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	e28080e7          	jalr	-472(ra) # 80000b48 <kalloc>
    80002d28:	26a4b423          	sd	a0,616(s1)
        if (p->alarm_tf == 0)
    80002d2c:	cd09                	beqz	a0,80002d46 <usertrap+0x168>
        memmove(p->alarm_tf, p->trapframe, sizeof(struct trapframe));
    80002d2e:	12000613          	li	a2,288
    80002d32:	6cac                	ld	a1,88(s1)
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	05c080e7          	jalr	92(ra) # 80000d90 <memmove>
        p->trapframe->epc = (uint64)p->alarm_handler;
    80002d3c:	6cbc                	ld	a5,88(s1)
    80002d3e:	2584b703          	ld	a4,600(s1)
    80002d42:	ef98                	sd	a4,24(a5)
    80002d44:	bf15                	j	80002c78 <usertrap+0x9a>
          panic("usertrap: out of memory");
    80002d46:	00005517          	auipc	a0,0x5
    80002d4a:	5fa50513          	addi	a0,a0,1530 # 80008340 <etext+0x340>
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	812080e7          	jalr	-2030(ra) # 80000560 <panic>

0000000080002d56 <kerneltrap>:
{
    80002d56:	7179                	addi	sp,sp,-48
    80002d58:	f406                	sd	ra,40(sp)
    80002d5a:	f022                	sd	s0,32(sp)
    80002d5c:	ec26                	sd	s1,24(sp)
    80002d5e:	e84a                	sd	s2,16(sp)
    80002d60:	e44e                	sd	s3,8(sp)
    80002d62:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d64:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d68:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d6c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002d70:	1004f793          	andi	a5,s1,256
    80002d74:	cb85                	beqz	a5,80002da4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d7a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002d7c:	ef85                	bnez	a5,80002db4 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002d7e:	00000097          	auipc	ra,0x0
    80002d82:	db6080e7          	jalr	-586(ra) # 80002b34 <devintr>
    80002d86:	cd1d                	beqz	a0,80002dc4 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d88:	4789                	li	a5,2
    80002d8a:	06f50a63          	beq	a0,a5,80002dfe <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d8e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d92:	10049073          	csrw	sstatus,s1
}
    80002d96:	70a2                	ld	ra,40(sp)
    80002d98:	7402                	ld	s0,32(sp)
    80002d9a:	64e2                	ld	s1,24(sp)
    80002d9c:	6942                	ld	s2,16(sp)
    80002d9e:	69a2                	ld	s3,8(sp)
    80002da0:	6145                	addi	sp,sp,48
    80002da2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002da4:	00005517          	auipc	a0,0x5
    80002da8:	5b450513          	addi	a0,a0,1460 # 80008358 <etext+0x358>
    80002dac:	ffffd097          	auipc	ra,0xffffd
    80002db0:	7b4080e7          	jalr	1972(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002db4:	00005517          	auipc	a0,0x5
    80002db8:	5cc50513          	addi	a0,a0,1484 # 80008380 <etext+0x380>
    80002dbc:	ffffd097          	auipc	ra,0xffffd
    80002dc0:	7a4080e7          	jalr	1956(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002dc4:	85ce                	mv	a1,s3
    80002dc6:	00005517          	auipc	a0,0x5
    80002dca:	5da50513          	addi	a0,a0,1498 # 800083a0 <etext+0x3a0>
    80002dce:	ffffd097          	auipc	ra,0xffffd
    80002dd2:	7dc080e7          	jalr	2012(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dd6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dda:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dde:	00005517          	auipc	a0,0x5
    80002de2:	5d250513          	addi	a0,a0,1490 # 800083b0 <etext+0x3b0>
    80002de6:	ffffd097          	auipc	ra,0xffffd
    80002dea:	7c4080e7          	jalr	1988(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002dee:	00005517          	auipc	a0,0x5
    80002df2:	5da50513          	addi	a0,a0,1498 # 800083c8 <etext+0x3c8>
    80002df6:	ffffd097          	auipc	ra,0xffffd
    80002dfa:	76a080e7          	jalr	1898(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	c7c080e7          	jalr	-900(ra) # 80001a7a <myproc>
    80002e06:	d541                	beqz	a0,80002d8e <kerneltrap+0x38>
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	c72080e7          	jalr	-910(ra) # 80001a7a <myproc>
    80002e10:	4d18                	lw	a4,24(a0)
    80002e12:	4791                	li	a5,4
    80002e14:	f6f71de3          	bne	a4,a5,80002d8e <kerneltrap+0x38>
    yield();
    80002e18:	fffff097          	auipc	ra,0xfffff
    80002e1c:	432080e7          	jalr	1074(ra) # 8000224a <yield>
    80002e20:	b7bd                	j	80002d8e <kerneltrap+0x38>

0000000080002e22 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e22:	1101                	addi	sp,sp,-32
    80002e24:	ec06                	sd	ra,24(sp)
    80002e26:	e822                	sd	s0,16(sp)
    80002e28:	e426                	sd	s1,8(sp)
    80002e2a:	1000                	addi	s0,sp,32
    80002e2c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	c4c080e7          	jalr	-948(ra) # 80001a7a <myproc>
  switch (n)
    80002e36:	4795                	li	a5,5
    80002e38:	0497e163          	bltu	a5,s1,80002e7a <argraw+0x58>
    80002e3c:	048a                	slli	s1,s1,0x2
    80002e3e:	00006717          	auipc	a4,0x6
    80002e42:	94a70713          	addi	a4,a4,-1718 # 80008788 <states.0+0x30>
    80002e46:	94ba                	add	s1,s1,a4
    80002e48:	409c                	lw	a5,0(s1)
    80002e4a:	97ba                	add	a5,a5,a4
    80002e4c:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002e4e:	6d3c                	ld	a5,88(a0)
    80002e50:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e52:	60e2                	ld	ra,24(sp)
    80002e54:	6442                	ld	s0,16(sp)
    80002e56:	64a2                	ld	s1,8(sp)
    80002e58:	6105                	addi	sp,sp,32
    80002e5a:	8082                	ret
    return p->trapframe->a1;
    80002e5c:	6d3c                	ld	a5,88(a0)
    80002e5e:	7fa8                	ld	a0,120(a5)
    80002e60:	bfcd                	j	80002e52 <argraw+0x30>
    return p->trapframe->a2;
    80002e62:	6d3c                	ld	a5,88(a0)
    80002e64:	63c8                	ld	a0,128(a5)
    80002e66:	b7f5                	j	80002e52 <argraw+0x30>
    return p->trapframe->a3;
    80002e68:	6d3c                	ld	a5,88(a0)
    80002e6a:	67c8                	ld	a0,136(a5)
    80002e6c:	b7dd                	j	80002e52 <argraw+0x30>
    return p->trapframe->a4;
    80002e6e:	6d3c                	ld	a5,88(a0)
    80002e70:	6bc8                	ld	a0,144(a5)
    80002e72:	b7c5                	j	80002e52 <argraw+0x30>
    return p->trapframe->a5;
    80002e74:	6d3c                	ld	a5,88(a0)
    80002e76:	6fc8                	ld	a0,152(a5)
    80002e78:	bfe9                	j	80002e52 <argraw+0x30>
  panic("argraw");
    80002e7a:	00005517          	auipc	a0,0x5
    80002e7e:	55e50513          	addi	a0,a0,1374 # 800083d8 <etext+0x3d8>
    80002e82:	ffffd097          	auipc	ra,0xffffd
    80002e86:	6de080e7          	jalr	1758(ra) # 80000560 <panic>

0000000080002e8a <fetchaddr>:
{
    80002e8a:	1101                	addi	sp,sp,-32
    80002e8c:	ec06                	sd	ra,24(sp)
    80002e8e:	e822                	sd	s0,16(sp)
    80002e90:	e426                	sd	s1,8(sp)
    80002e92:	e04a                	sd	s2,0(sp)
    80002e94:	1000                	addi	s0,sp,32
    80002e96:	84aa                	mv	s1,a0
    80002e98:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	be0080e7          	jalr	-1056(ra) # 80001a7a <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ea2:	653c                	ld	a5,72(a0)
    80002ea4:	02f4f863          	bgeu	s1,a5,80002ed4 <fetchaddr+0x4a>
    80002ea8:	00848713          	addi	a4,s1,8
    80002eac:	02e7e663          	bltu	a5,a4,80002ed8 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002eb0:	46a1                	li	a3,8
    80002eb2:	8626                	mv	a2,s1
    80002eb4:	85ca                	mv	a1,s2
    80002eb6:	6928                	ld	a0,80(a0)
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	8b6080e7          	jalr	-1866(ra) # 8000176e <copyin>
    80002ec0:	00a03533          	snez	a0,a0
    80002ec4:	40a00533          	neg	a0,a0
}
    80002ec8:	60e2                	ld	ra,24(sp)
    80002eca:	6442                	ld	s0,16(sp)
    80002ecc:	64a2                	ld	s1,8(sp)
    80002ece:	6902                	ld	s2,0(sp)
    80002ed0:	6105                	addi	sp,sp,32
    80002ed2:	8082                	ret
    return -1;
    80002ed4:	557d                	li	a0,-1
    80002ed6:	bfcd                	j	80002ec8 <fetchaddr+0x3e>
    80002ed8:	557d                	li	a0,-1
    80002eda:	b7fd                	j	80002ec8 <fetchaddr+0x3e>

0000000080002edc <fetchstr>:
{
    80002edc:	7179                	addi	sp,sp,-48
    80002ede:	f406                	sd	ra,40(sp)
    80002ee0:	f022                	sd	s0,32(sp)
    80002ee2:	ec26                	sd	s1,24(sp)
    80002ee4:	e84a                	sd	s2,16(sp)
    80002ee6:	e44e                	sd	s3,8(sp)
    80002ee8:	1800                	addi	s0,sp,48
    80002eea:	892a                	mv	s2,a0
    80002eec:	84ae                	mv	s1,a1
    80002eee:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ef0:	fffff097          	auipc	ra,0xfffff
    80002ef4:	b8a080e7          	jalr	-1142(ra) # 80001a7a <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ef8:	86ce                	mv	a3,s3
    80002efa:	864a                	mv	a2,s2
    80002efc:	85a6                	mv	a1,s1
    80002efe:	6928                	ld	a0,80(a0)
    80002f00:	fffff097          	auipc	ra,0xfffff
    80002f04:	8fc080e7          	jalr	-1796(ra) # 800017fc <copyinstr>
    80002f08:	00054e63          	bltz	a0,80002f24 <fetchstr+0x48>
  return strlen(buf);
    80002f0c:	8526                	mv	a0,s1
    80002f0e:	ffffe097          	auipc	ra,0xffffe
    80002f12:	f9a080e7          	jalr	-102(ra) # 80000ea8 <strlen>
}
    80002f16:	70a2                	ld	ra,40(sp)
    80002f18:	7402                	ld	s0,32(sp)
    80002f1a:	64e2                	ld	s1,24(sp)
    80002f1c:	6942                	ld	s2,16(sp)
    80002f1e:	69a2                	ld	s3,8(sp)
    80002f20:	6145                	addi	sp,sp,48
    80002f22:	8082                	ret
    return -1;
    80002f24:	557d                	li	a0,-1
    80002f26:	bfc5                	j	80002f16 <fetchstr+0x3a>

0000000080002f28 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002f28:	1101                	addi	sp,sp,-32
    80002f2a:	ec06                	sd	ra,24(sp)
    80002f2c:	e822                	sd	s0,16(sp)
    80002f2e:	e426                	sd	s1,8(sp)
    80002f30:	1000                	addi	s0,sp,32
    80002f32:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f34:	00000097          	auipc	ra,0x0
    80002f38:	eee080e7          	jalr	-274(ra) # 80002e22 <argraw>
    80002f3c:	c088                	sw	a0,0(s1)
}
    80002f3e:	60e2                	ld	ra,24(sp)
    80002f40:	6442                	ld	s0,16(sp)
    80002f42:	64a2                	ld	s1,8(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret

0000000080002f48 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002f48:	1101                	addi	sp,sp,-32
    80002f4a:	ec06                	sd	ra,24(sp)
    80002f4c:	e822                	sd	s0,16(sp)
    80002f4e:	e426                	sd	s1,8(sp)
    80002f50:	1000                	addi	s0,sp,32
    80002f52:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f54:	00000097          	auipc	ra,0x0
    80002f58:	ece080e7          	jalr	-306(ra) # 80002e22 <argraw>
    80002f5c:	e088                	sd	a0,0(s1)
}
    80002f5e:	60e2                	ld	ra,24(sp)
    80002f60:	6442                	ld	s0,16(sp)
    80002f62:	64a2                	ld	s1,8(sp)
    80002f64:	6105                	addi	sp,sp,32
    80002f66:	8082                	ret

0000000080002f68 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f68:	7179                	addi	sp,sp,-48
    80002f6a:	f406                	sd	ra,40(sp)
    80002f6c:	f022                	sd	s0,32(sp)
    80002f6e:	ec26                	sd	s1,24(sp)
    80002f70:	e84a                	sd	s2,16(sp)
    80002f72:	1800                	addi	s0,sp,48
    80002f74:	84ae                	mv	s1,a1
    80002f76:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f78:	fd840593          	addi	a1,s0,-40
    80002f7c:	00000097          	auipc	ra,0x0
    80002f80:	fcc080e7          	jalr	-52(ra) # 80002f48 <argaddr>
  return fetchstr(addr, buf, max);
    80002f84:	864a                	mv	a2,s2
    80002f86:	85a6                	mv	a1,s1
    80002f88:	fd843503          	ld	a0,-40(s0)
    80002f8c:	00000097          	auipc	ra,0x0
    80002f90:	f50080e7          	jalr	-176(ra) # 80002edc <fetchstr>
}
    80002f94:	70a2                	ld	ra,40(sp)
    80002f96:	7402                	ld	s0,32(sp)
    80002f98:	64e2                	ld	s1,24(sp)
    80002f9a:	6942                	ld	s2,16(sp)
    80002f9c:	6145                	addi	sp,sp,48
    80002f9e:	8082                	ret

0000000080002fa0 <syscall>:
};

// Add a new array to keep track of syscall counts
uint64 syscall_counts[NSYSCALLS] = {0};
void syscall(void)
{
    80002fa0:	7179                	addi	sp,sp,-48
    80002fa2:	f406                	sd	ra,40(sp)
    80002fa4:	f022                	sd	s0,32(sp)
    80002fa6:	ec26                	sd	s1,24(sp)
    80002fa8:	e84a                	sd	s2,16(sp)
    80002faa:	e44e                	sd	s3,8(sp)
    80002fac:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	acc080e7          	jalr	-1332(ra) # 80001a7a <myproc>
    80002fb6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002fb8:	05853983          	ld	s3,88(a0)
    80002fbc:	0a89b783          	ld	a5,168(s3)
    80002fc0:	0007891b          	sext.w	s2,a5
  if (num > 0 && num < NSYSCALLS && syscalls[num])
    80002fc4:	37fd                	addiw	a5,a5,-1
    80002fc6:	4765                	li	a4,25
    80002fc8:	02f76863          	bltu	a4,a5,80002ff8 <syscall+0x58>
    80002fcc:	00391713          	slli	a4,s2,0x3
    80002fd0:	00005797          	auipc	a5,0x5
    80002fd4:	7d078793          	addi	a5,a5,2000 # 800087a0 <syscalls>
    80002fd8:	97ba                	add	a5,a5,a4
    80002fda:	639c                	ld	a5,0(a5)
    80002fdc:	cf91                	beqz	a5,80002ff8 <syscall+0x58>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    // if(num == SYS_exec)
    //   printf("exec called in %d\n",p->pid);
    p->trapframe->a0 = syscalls[num]();
    80002fde:	9782                	jalr	a5
    80002fe0:	06a9b823          	sd	a0,112(s3)
    syscall_counts[num]++; // Increment the count for this syscall
    80002fe4:	090e                	slli	s2,s2,0x3
    80002fe6:	0001b797          	auipc	a5,0x1b
    80002fea:	a5278793          	addi	a5,a5,-1454 # 8001da38 <syscall_counts>
    80002fee:	97ca                	add	a5,a5,s2
    80002ff0:	6398                	ld	a4,0(a5)
    80002ff2:	0705                	addi	a4,a4,1
    80002ff4:	e398                	sd	a4,0(a5)
    80002ff6:	a005                	j	80003016 <syscall+0x76>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002ff8:	86ca                	mv	a3,s2
    80002ffa:	15848613          	addi	a2,s1,344
    80002ffe:	588c                	lw	a1,48(s1)
    80003000:	00005517          	auipc	a0,0x5
    80003004:	3e050513          	addi	a0,a0,992 # 800083e0 <etext+0x3e0>
    80003008:	ffffd097          	auipc	ra,0xffffd
    8000300c:	5a2080e7          	jalr	1442(ra) # 800005aa <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003010:	6cbc                	ld	a5,88(s1)
    80003012:	577d                	li	a4,-1
    80003014:	fbb8                	sd	a4,112(a5)
  }
}
    80003016:	70a2                	ld	ra,40(sp)
    80003018:	7402                	ld	s0,32(sp)
    8000301a:	64e2                	ld	s1,24(sp)
    8000301c:	6942                	ld	s2,16(sp)
    8000301e:	69a2                	ld	s3,8(sp)
    80003020:	6145                	addi	sp,sp,48
    80003022:	8082                	ret

0000000080003024 <sys_exit>:

extern uint64 syscall_counts[];

uint64
sys_exit(void)
{
    80003024:	1101                	addi	sp,sp,-32
    80003026:	ec06                	sd	ra,24(sp)
    80003028:	e822                	sd	s0,16(sp)
    8000302a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000302c:	fec40593          	addi	a1,s0,-20
    80003030:	4501                	li	a0,0
    80003032:	00000097          	auipc	ra,0x0
    80003036:	ef6080e7          	jalr	-266(ra) # 80002f28 <argint>
  exit(n);
    8000303a:	fec42503          	lw	a0,-20(s0)
    8000303e:	fffff097          	auipc	ra,0xfffff
    80003042:	37c080e7          	jalr	892(ra) # 800023ba <exit>
  return 0; // not reached
}
    80003046:	4501                	li	a0,0
    80003048:	60e2                	ld	ra,24(sp)
    8000304a:	6442                	ld	s0,16(sp)
    8000304c:	6105                	addi	sp,sp,32
    8000304e:	8082                	ret

0000000080003050 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003050:	1141                	addi	sp,sp,-16
    80003052:	e406                	sd	ra,8(sp)
    80003054:	e022                	sd	s0,0(sp)
    80003056:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003058:	fffff097          	auipc	ra,0xfffff
    8000305c:	a22080e7          	jalr	-1502(ra) # 80001a7a <myproc>
}
    80003060:	5908                	lw	a0,48(a0)
    80003062:	60a2                	ld	ra,8(sp)
    80003064:	6402                	ld	s0,0(sp)
    80003066:	0141                	addi	sp,sp,16
    80003068:	8082                	ret

000000008000306a <sys_fork>:

uint64
sys_fork(void)
{
    8000306a:	1141                	addi	sp,sp,-16
    8000306c:	e406                	sd	ra,8(sp)
    8000306e:	e022                	sd	s0,0(sp)
    80003070:	0800                	addi	s0,sp,16
  return fork();
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	e22080e7          	jalr	-478(ra) # 80001e94 <fork>
}
    8000307a:	60a2                	ld	ra,8(sp)
    8000307c:	6402                	ld	s0,0(sp)
    8000307e:	0141                	addi	sp,sp,16
    80003080:	8082                	ret

0000000080003082 <sys_wait>:

uint64
sys_wait(void)
{
    80003082:	1101                	addi	sp,sp,-32
    80003084:	ec06                	sd	ra,24(sp)
    80003086:	e822                	sd	s0,16(sp)
    80003088:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000308a:	fe840593          	addi	a1,s0,-24
    8000308e:	4501                	li	a0,0
    80003090:	00000097          	auipc	ra,0x0
    80003094:	eb8080e7          	jalr	-328(ra) # 80002f48 <argaddr>
  return wait(p);
    80003098:	fe843503          	ld	a0,-24(s0)
    8000309c:	fffff097          	auipc	ra,0xfffff
    800030a0:	4d0080e7          	jalr	1232(ra) # 8000256c <wait>
}
    800030a4:	60e2                	ld	ra,24(sp)
    800030a6:	6442                	ld	s0,16(sp)
    800030a8:	6105                	addi	sp,sp,32
    800030aa:	8082                	ret

00000000800030ac <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030ac:	7179                	addi	sp,sp,-48
    800030ae:	f406                	sd	ra,40(sp)
    800030b0:	f022                	sd	s0,32(sp)
    800030b2:	ec26                	sd	s1,24(sp)
    800030b4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800030b6:	fdc40593          	addi	a1,s0,-36
    800030ba:	4501                	li	a0,0
    800030bc:	00000097          	auipc	ra,0x0
    800030c0:	e6c080e7          	jalr	-404(ra) # 80002f28 <argint>
  addr = myproc()->sz;
    800030c4:	fffff097          	auipc	ra,0xfffff
    800030c8:	9b6080e7          	jalr	-1610(ra) # 80001a7a <myproc>
    800030cc:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    800030ce:	fdc42503          	lw	a0,-36(s0)
    800030d2:	fffff097          	auipc	ra,0xfffff
    800030d6:	d66080e7          	jalr	-666(ra) # 80001e38 <growproc>
    800030da:	00054863          	bltz	a0,800030ea <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030de:	8526                	mv	a0,s1
    800030e0:	70a2                	ld	ra,40(sp)
    800030e2:	7402                	ld	s0,32(sp)
    800030e4:	64e2                	ld	s1,24(sp)
    800030e6:	6145                	addi	sp,sp,48
    800030e8:	8082                	ret
    return -1;
    800030ea:	54fd                	li	s1,-1
    800030ec:	bfcd                	j	800030de <sys_sbrk+0x32>

00000000800030ee <sys_sleep>:

uint64
sys_sleep(void)
{
    800030ee:	7139                	addi	sp,sp,-64
    800030f0:	fc06                	sd	ra,56(sp)
    800030f2:	f822                	sd	s0,48(sp)
    800030f4:	f04a                	sd	s2,32(sp)
    800030f6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800030f8:	fcc40593          	addi	a1,s0,-52
    800030fc:	4501                	li	a0,0
    800030fe:	00000097          	auipc	ra,0x0
    80003102:	e2a080e7          	jalr	-470(ra) # 80002f28 <argint>
  acquire(&tickslock);
    80003106:	0001b517          	auipc	a0,0x1b
    8000310a:	91a50513          	addi	a0,a0,-1766 # 8001da20 <tickslock>
    8000310e:	ffffe097          	auipc	ra,0xffffe
    80003112:	b2a080e7          	jalr	-1238(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80003116:	00008917          	auipc	s2,0x8
    8000311a:	26a92903          	lw	s2,618(s2) # 8000b380 <ticks>
  while (ticks - ticks0 < n)
    8000311e:	fcc42783          	lw	a5,-52(s0)
    80003122:	c3b9                	beqz	a5,80003168 <sys_sleep+0x7a>
    80003124:	f426                	sd	s1,40(sp)
    80003126:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003128:	0001b997          	auipc	s3,0x1b
    8000312c:	8f898993          	addi	s3,s3,-1800 # 8001da20 <tickslock>
    80003130:	00008497          	auipc	s1,0x8
    80003134:	25048493          	addi	s1,s1,592 # 8000b380 <ticks>
    if (killed(myproc()))
    80003138:	fffff097          	auipc	ra,0xfffff
    8000313c:	942080e7          	jalr	-1726(ra) # 80001a7a <myproc>
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	3fa080e7          	jalr	1018(ra) # 8000253a <killed>
    80003148:	ed15                	bnez	a0,80003184 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000314a:	85ce                	mv	a1,s3
    8000314c:	8526                	mv	a0,s1
    8000314e:	fffff097          	auipc	ra,0xfffff
    80003152:	138080e7          	jalr	312(ra) # 80002286 <sleep>
  while (ticks - ticks0 < n)
    80003156:	409c                	lw	a5,0(s1)
    80003158:	412787bb          	subw	a5,a5,s2
    8000315c:	fcc42703          	lw	a4,-52(s0)
    80003160:	fce7ece3          	bltu	a5,a4,80003138 <sys_sleep+0x4a>
    80003164:	74a2                	ld	s1,40(sp)
    80003166:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003168:	0001b517          	auipc	a0,0x1b
    8000316c:	8b850513          	addi	a0,a0,-1864 # 8001da20 <tickslock>
    80003170:	ffffe097          	auipc	ra,0xffffe
    80003174:	b7c080e7          	jalr	-1156(ra) # 80000cec <release>
  return 0;
    80003178:	4501                	li	a0,0
}
    8000317a:	70e2                	ld	ra,56(sp)
    8000317c:	7442                	ld	s0,48(sp)
    8000317e:	7902                	ld	s2,32(sp)
    80003180:	6121                	addi	sp,sp,64
    80003182:	8082                	ret
      release(&tickslock);
    80003184:	0001b517          	auipc	a0,0x1b
    80003188:	89c50513          	addi	a0,a0,-1892 # 8001da20 <tickslock>
    8000318c:	ffffe097          	auipc	ra,0xffffe
    80003190:	b60080e7          	jalr	-1184(ra) # 80000cec <release>
      return -1;
    80003194:	557d                	li	a0,-1
    80003196:	74a2                	ld	s1,40(sp)
    80003198:	69e2                	ld	s3,24(sp)
    8000319a:	b7c5                	j	8000317a <sys_sleep+0x8c>

000000008000319c <sys_kill>:

uint64
sys_kill(void)
{
    8000319c:	1101                	addi	sp,sp,-32
    8000319e:	ec06                	sd	ra,24(sp)
    800031a0:	e822                	sd	s0,16(sp)
    800031a2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800031a4:	fec40593          	addi	a1,s0,-20
    800031a8:	4501                	li	a0,0
    800031aa:	00000097          	auipc	ra,0x0
    800031ae:	d7e080e7          	jalr	-642(ra) # 80002f28 <argint>
  return kill(pid);
    800031b2:	fec42503          	lw	a0,-20(s0)
    800031b6:	fffff097          	auipc	ra,0xfffff
    800031ba:	2e6080e7          	jalr	742(ra) # 8000249c <kill>
}
    800031be:	60e2                	ld	ra,24(sp)
    800031c0:	6442                	ld	s0,16(sp)
    800031c2:	6105                	addi	sp,sp,32
    800031c4:	8082                	ret

00000000800031c6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031c6:	1101                	addi	sp,sp,-32
    800031c8:	ec06                	sd	ra,24(sp)
    800031ca:	e822                	sd	s0,16(sp)
    800031cc:	e426                	sd	s1,8(sp)
    800031ce:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031d0:	0001b517          	auipc	a0,0x1b
    800031d4:	85050513          	addi	a0,a0,-1968 # 8001da20 <tickslock>
    800031d8:	ffffe097          	auipc	ra,0xffffe
    800031dc:	a60080e7          	jalr	-1440(ra) # 80000c38 <acquire>
  xticks = ticks;
    800031e0:	00008497          	auipc	s1,0x8
    800031e4:	1a04a483          	lw	s1,416(s1) # 8000b380 <ticks>
  release(&tickslock);
    800031e8:	0001b517          	auipc	a0,0x1b
    800031ec:	83850513          	addi	a0,a0,-1992 # 8001da20 <tickslock>
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	afc080e7          	jalr	-1284(ra) # 80000cec <release>
  return xticks;
}
    800031f8:	02049513          	slli	a0,s1,0x20
    800031fc:	9101                	srli	a0,a0,0x20
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret

0000000080003208 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003208:	7139                	addi	sp,sp,-64
    8000320a:	fc06                	sd	ra,56(sp)
    8000320c:	f822                	sd	s0,48(sp)
    8000320e:	f426                	sd	s1,40(sp)
    80003210:	f04a                	sd	s2,32(sp)
    80003212:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003214:	fd840593          	addi	a1,s0,-40
    80003218:	4501                	li	a0,0
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	d2e080e7          	jalr	-722(ra) # 80002f48 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003222:	fd040593          	addi	a1,s0,-48
    80003226:	4505                	li	a0,1
    80003228:	00000097          	auipc	ra,0x0
    8000322c:	d20080e7          	jalr	-736(ra) # 80002f48 <argaddr>
  argaddr(2, &addr2);
    80003230:	fc840593          	addi	a1,s0,-56
    80003234:	4509                	li	a0,2
    80003236:	00000097          	auipc	ra,0x0
    8000323a:	d12080e7          	jalr	-750(ra) # 80002f48 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000323e:	fc040613          	addi	a2,s0,-64
    80003242:	fc440593          	addi	a1,s0,-60
    80003246:	fd843503          	ld	a0,-40(s0)
    8000324a:	fffff097          	auipc	ra,0xfffff
    8000324e:	5ac080e7          	jalr	1452(ra) # 800027f6 <waitx>
    80003252:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003254:	fffff097          	auipc	ra,0xfffff
    80003258:	826080e7          	jalr	-2010(ra) # 80001a7a <myproc>
    8000325c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000325e:	4691                	li	a3,4
    80003260:	fc440613          	addi	a2,s0,-60
    80003264:	fd043583          	ld	a1,-48(s0)
    80003268:	6928                	ld	a0,80(a0)
    8000326a:	ffffe097          	auipc	ra,0xffffe
    8000326e:	478080e7          	jalr	1144(ra) # 800016e2 <copyout>
    return -1;
    80003272:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003274:	00054f63          	bltz	a0,80003292 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003278:	4691                	li	a3,4
    8000327a:	fc040613          	addi	a2,s0,-64
    8000327e:	fc843583          	ld	a1,-56(s0)
    80003282:	68a8                	ld	a0,80(s1)
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	45e080e7          	jalr	1118(ra) # 800016e2 <copyout>
    8000328c:	00054a63          	bltz	a0,800032a0 <sys_waitx+0x98>
    return -1;
  return ret;
    80003290:	87ca                	mv	a5,s2
}
    80003292:	853e                	mv	a0,a5
    80003294:	70e2                	ld	ra,56(sp)
    80003296:	7442                	ld	s0,48(sp)
    80003298:	74a2                	ld	s1,40(sp)
    8000329a:	7902                	ld	s2,32(sp)
    8000329c:	6121                	addi	sp,sp,64
    8000329e:	8082                	ret
    return -1;
    800032a0:	57fd                	li	a5,-1
    800032a2:	bfc5                	j	80003292 <sys_waitx+0x8a>

00000000800032a4 <sys_getsyscount>:

uint64
sys_getsyscount(void)
{
    800032a4:	1101                	addi	sp,sp,-32
    800032a6:	ec06                	sd	ra,24(sp)
    800032a8:	e822                	sd	s0,16(sp)
    800032aa:	1000                	addi	s0,sp,32
  int mask;
  argint(0, &mask); // argint is a void function, it directly sets the value of mask
    800032ac:	fec40593          	addi	a1,s0,-20
    800032b0:	4501                	li	a0,0
    800032b2:	00000097          	auipc	ra,0x0
    800032b6:	c76080e7          	jalr	-906(ra) # 80002f28 <argint>

  // Find the syscall number from the mask
  int syscall_num = -1;
  for (int i = 1; i < NSYSCALLS; i++)
  {
    if (mask == (1 << i))
    800032ba:	fec42603          	lw	a2,-20(s0)
  for (int i = 1; i < NSYSCALLS; i++)
    800032be:	4785                	li	a5,1
    if (mask == (1 << i))
    800032c0:	4685                	li	a3,1
  for (int i = 1; i < NSYSCALLS; i++)
    800032c2:	45ed                	li	a1,27
    if (mask == (1 << i))
    800032c4:	00f6973b          	sllw	a4,a3,a5
    800032c8:	00c70763          	beq	a4,a2,800032d6 <sys_getsyscount+0x32>
  for (int i = 1; i < NSYSCALLS; i++)
    800032cc:	2785                	addiw	a5,a5,1
    800032ce:	feb79be3          	bne	a5,a1,800032c4 <sys_getsyscount+0x20>
      break;
    }
  }

  if (syscall_num == -1 || syscall_num >= NSYSCALLS)
    return -1;
    800032d2:	557d                	li	a0,-1
    800032d4:	a829                	j	800032ee <sys_getsyscount+0x4a>
  if (syscall_num == -1 || syscall_num >= NSYSCALLS)
    800032d6:	577d                	li	a4,-1
    800032d8:	00e78f63          	beq	a5,a4,800032f6 <sys_getsyscount+0x52>

  uint64 count = syscall_counts[syscall_num];
    800032dc:	078e                	slli	a5,a5,0x3
    800032de:	0001a717          	auipc	a4,0x1a
    800032e2:	75a70713          	addi	a4,a4,1882 # 8001da38 <syscall_counts>
    800032e6:	97ba                	add	a5,a5,a4
    800032e8:	6388                	ld	a0,0(a5)
  syscall_counts[syscall_num] = 0; // Reset the count after reading
    800032ea:	0007b023          	sd	zero,0(a5)
  return count;
}
    800032ee:	60e2                	ld	ra,24(sp)
    800032f0:	6442                	ld	s0,16(sp)
    800032f2:	6105                	addi	sp,sp,32
    800032f4:	8082                	ret
    return -1;
    800032f6:	557d                	li	a0,-1
    800032f8:	bfdd                	j	800032ee <sys_getsyscount+0x4a>

00000000800032fa <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    800032fa:	1101                	addi	sp,sp,-32
    800032fc:	ec06                	sd	ra,24(sp)
    800032fe:	e822                	sd	s0,16(sp)
    80003300:	1000                	addi	s0,sp,32
  int interval;
  uint64 handler;

  argint(0, &interval);
    80003302:	fec40593          	addi	a1,s0,-20
    80003306:	4501                	li	a0,0
    80003308:	00000097          	auipc	ra,0x0
    8000330c:	c20080e7          	jalr	-992(ra) # 80002f28 <argint>
  argaddr(1, &handler);
    80003310:	fe040593          	addi	a1,s0,-32
    80003314:	4505                	li	a0,1
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	c32080e7          	jalr	-974(ra) # 80002f48 <argaddr>

  struct proc *p = myproc();
    8000331e:	ffffe097          	auipc	ra,0xffffe
    80003322:	75c080e7          	jalr	1884(ra) # 80001a7a <myproc>
  p->alarm_interval = interval;
    80003326:	fec42783          	lw	a5,-20(s0)
    8000332a:	24f52823          	sw	a5,592(a0)
  p->alarm_handler = (void (*)())handler;
    8000332e:	fe043783          	ld	a5,-32(s0)
    80003332:	24f53c23          	sd	a5,600(a0)
  p->ticks_count = 0;
    80003336:	26052023          	sw	zero,608(a0)
  p->alarm_active = 0;
    8000333a:	26052223          	sw	zero,612(a0)

  return 0;
}
    8000333e:	4501                	li	a0,0
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	e426                	sd	s1,8(sp)
    80003350:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	728080e7          	jalr	1832(ra) # 80001a7a <myproc>
    8000335a:	84aa                	mv	s1,a0
  if (p->alarm_tf)
    8000335c:	26853583          	ld	a1,616(a0)
    80003360:	c195                	beqz	a1,80003384 <sys_sigreturn+0x3c>
  {
    memmove(p->trapframe, p->alarm_tf, sizeof(struct trapframe));
    80003362:	12000613          	li	a2,288
    80003366:	6d28                	ld	a0,88(a0)
    80003368:	ffffe097          	auipc	ra,0xffffe
    8000336c:	a28080e7          	jalr	-1496(ra) # 80000d90 <memmove>
    kfree(p->alarm_tf);
    80003370:	2684b503          	ld	a0,616(s1)
    80003374:	ffffd097          	auipc	ra,0xffffd
    80003378:	6d6080e7          	jalr	1750(ra) # 80000a4a <kfree>
    p->alarm_tf = 0;
    8000337c:	2604b423          	sd	zero,616(s1)
    p->alarm_active = 0;
    80003380:	2604a223          	sw	zero,612(s1)
  }
  return p->trapframe->a0;
    80003384:	6cbc                	ld	a5,88(s1)
}
    80003386:	7ba8                	ld	a0,112(a5)
    80003388:	60e2                	ld	ra,24(sp)
    8000338a:	6442                	ld	s0,16(sp)
    8000338c:	64a2                	ld	s1,8(sp)
    8000338e:	6105                	addi	sp,sp,32
    80003390:	8082                	ret

0000000080003392 <sys_settickets>:
#if LBS
uint64
sys_settickets(void)
{
    80003392:	1101                	addi	sp,sp,-32
    80003394:	ec06                	sd	ra,24(sp)
    80003396:	e822                	sd	s0,16(sp)
    80003398:	1000                	addi	s0,sp,32
  int number;
  argint(0, &number);
    8000339a:	fec40593          	addi	a1,s0,-20
    8000339e:	4501                	li	a0,0
    800033a0:	00000097          	auipc	ra,0x0
    800033a4:	b88080e7          	jalr	-1144(ra) # 80002f28 <argint>
  return settickets(number);
    800033a8:	fec42503          	lw	a0,-20(s0)
    800033ac:	ffffe097          	auipc	ra,0xffffe
    800033b0:	706080e7          	jalr	1798(ra) # 80001ab2 <settickets>
}
    800033b4:	60e2                	ld	ra,24(sp)
    800033b6:	6442                	ld	s0,16(sp)
    800033b8:	6105                	addi	sp,sp,32
    800033ba:	8082                	ret

00000000800033bc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033bc:	7179                	addi	sp,sp,-48
    800033be:	f406                	sd	ra,40(sp)
    800033c0:	f022                	sd	s0,32(sp)
    800033c2:	ec26                	sd	s1,24(sp)
    800033c4:	e84a                	sd	s2,16(sp)
    800033c6:	e44e                	sd	s3,8(sp)
    800033c8:	e052                	sd	s4,0(sp)
    800033ca:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033cc:	00005597          	auipc	a1,0x5
    800033d0:	03458593          	addi	a1,a1,52 # 80008400 <etext+0x400>
    800033d4:	0001a517          	auipc	a0,0x1a
    800033d8:	73c50513          	addi	a0,a0,1852 # 8001db10 <bcache>
    800033dc:	ffffd097          	auipc	ra,0xffffd
    800033e0:	7cc080e7          	jalr	1996(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033e4:	00022797          	auipc	a5,0x22
    800033e8:	72c78793          	addi	a5,a5,1836 # 80025b10 <bcache+0x8000>
    800033ec:	00023717          	auipc	a4,0x23
    800033f0:	98c70713          	addi	a4,a4,-1652 # 80025d78 <bcache+0x8268>
    800033f4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033f8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033fc:	0001a497          	auipc	s1,0x1a
    80003400:	72c48493          	addi	s1,s1,1836 # 8001db28 <bcache+0x18>
    b->next = bcache.head.next;
    80003404:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003406:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003408:	00005a17          	auipc	s4,0x5
    8000340c:	000a0a13          	mv	s4,s4
    b->next = bcache.head.next;
    80003410:	2b893783          	ld	a5,696(s2)
    80003414:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003416:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000341a:	85d2                	mv	a1,s4
    8000341c:	01048513          	addi	a0,s1,16
    80003420:	00001097          	auipc	ra,0x1
    80003424:	4e8080e7          	jalr	1256(ra) # 80004908 <initsleeplock>
    bcache.head.next->prev = b;
    80003428:	2b893783          	ld	a5,696(s2)
    8000342c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000342e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003432:	45848493          	addi	s1,s1,1112
    80003436:	fd349de3          	bne	s1,s3,80003410 <binit+0x54>
  }
}
    8000343a:	70a2                	ld	ra,40(sp)
    8000343c:	7402                	ld	s0,32(sp)
    8000343e:	64e2                	ld	s1,24(sp)
    80003440:	6942                	ld	s2,16(sp)
    80003442:	69a2                	ld	s3,8(sp)
    80003444:	6a02                	ld	s4,0(sp)
    80003446:	6145                	addi	sp,sp,48
    80003448:	8082                	ret

000000008000344a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000344a:	7179                	addi	sp,sp,-48
    8000344c:	f406                	sd	ra,40(sp)
    8000344e:	f022                	sd	s0,32(sp)
    80003450:	ec26                	sd	s1,24(sp)
    80003452:	e84a                	sd	s2,16(sp)
    80003454:	e44e                	sd	s3,8(sp)
    80003456:	1800                	addi	s0,sp,48
    80003458:	892a                	mv	s2,a0
    8000345a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000345c:	0001a517          	auipc	a0,0x1a
    80003460:	6b450513          	addi	a0,a0,1716 # 8001db10 <bcache>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	7d4080e7          	jalr	2004(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000346c:	00023497          	auipc	s1,0x23
    80003470:	95c4b483          	ld	s1,-1700(s1) # 80025dc8 <bcache+0x82b8>
    80003474:	00023797          	auipc	a5,0x23
    80003478:	90478793          	addi	a5,a5,-1788 # 80025d78 <bcache+0x8268>
    8000347c:	02f48f63          	beq	s1,a5,800034ba <bread+0x70>
    80003480:	873e                	mv	a4,a5
    80003482:	a021                	j	8000348a <bread+0x40>
    80003484:	68a4                	ld	s1,80(s1)
    80003486:	02e48a63          	beq	s1,a4,800034ba <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000348a:	449c                	lw	a5,8(s1)
    8000348c:	ff279ce3          	bne	a5,s2,80003484 <bread+0x3a>
    80003490:	44dc                	lw	a5,12(s1)
    80003492:	ff3799e3          	bne	a5,s3,80003484 <bread+0x3a>
      b->refcnt++;
    80003496:	40bc                	lw	a5,64(s1)
    80003498:	2785                	addiw	a5,a5,1
    8000349a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000349c:	0001a517          	auipc	a0,0x1a
    800034a0:	67450513          	addi	a0,a0,1652 # 8001db10 <bcache>
    800034a4:	ffffe097          	auipc	ra,0xffffe
    800034a8:	848080e7          	jalr	-1976(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    800034ac:	01048513          	addi	a0,s1,16
    800034b0:	00001097          	auipc	ra,0x1
    800034b4:	492080e7          	jalr	1170(ra) # 80004942 <acquiresleep>
      return b;
    800034b8:	a8b9                	j	80003516 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034ba:	00023497          	auipc	s1,0x23
    800034be:	9064b483          	ld	s1,-1786(s1) # 80025dc0 <bcache+0x82b0>
    800034c2:	00023797          	auipc	a5,0x23
    800034c6:	8b678793          	addi	a5,a5,-1866 # 80025d78 <bcache+0x8268>
    800034ca:	00f48863          	beq	s1,a5,800034da <bread+0x90>
    800034ce:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034d0:	40bc                	lw	a5,64(s1)
    800034d2:	cf81                	beqz	a5,800034ea <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034d4:	64a4                	ld	s1,72(s1)
    800034d6:	fee49de3          	bne	s1,a4,800034d0 <bread+0x86>
  panic("bget: no buffers");
    800034da:	00005517          	auipc	a0,0x5
    800034de:	f3650513          	addi	a0,a0,-202 # 80008410 <etext+0x410>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	07e080e7          	jalr	126(ra) # 80000560 <panic>
      b->dev = dev;
    800034ea:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034ee:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034f2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034f6:	4785                	li	a5,1
    800034f8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034fa:	0001a517          	auipc	a0,0x1a
    800034fe:	61650513          	addi	a0,a0,1558 # 8001db10 <bcache>
    80003502:	ffffd097          	auipc	ra,0xffffd
    80003506:	7ea080e7          	jalr	2026(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    8000350a:	01048513          	addi	a0,s1,16
    8000350e:	00001097          	auipc	ra,0x1
    80003512:	434080e7          	jalr	1076(ra) # 80004942 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003516:	409c                	lw	a5,0(s1)
    80003518:	cb89                	beqz	a5,8000352a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000351a:	8526                	mv	a0,s1
    8000351c:	70a2                	ld	ra,40(sp)
    8000351e:	7402                	ld	s0,32(sp)
    80003520:	64e2                	ld	s1,24(sp)
    80003522:	6942                	ld	s2,16(sp)
    80003524:	69a2                	ld	s3,8(sp)
    80003526:	6145                	addi	sp,sp,48
    80003528:	8082                	ret
    virtio_disk_rw(b, 0);
    8000352a:	4581                	li	a1,0
    8000352c:	8526                	mv	a0,s1
    8000352e:	00003097          	auipc	ra,0x3
    80003532:	0fa080e7          	jalr	250(ra) # 80006628 <virtio_disk_rw>
    b->valid = 1;
    80003536:	4785                	li	a5,1
    80003538:	c09c                	sw	a5,0(s1)
  return b;
    8000353a:	b7c5                	j	8000351a <bread+0xd0>

000000008000353c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000353c:	1101                	addi	sp,sp,-32
    8000353e:	ec06                	sd	ra,24(sp)
    80003540:	e822                	sd	s0,16(sp)
    80003542:	e426                	sd	s1,8(sp)
    80003544:	1000                	addi	s0,sp,32
    80003546:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003548:	0541                	addi	a0,a0,16
    8000354a:	00001097          	auipc	ra,0x1
    8000354e:	492080e7          	jalr	1170(ra) # 800049dc <holdingsleep>
    80003552:	cd01                	beqz	a0,8000356a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003554:	4585                	li	a1,1
    80003556:	8526                	mv	a0,s1
    80003558:	00003097          	auipc	ra,0x3
    8000355c:	0d0080e7          	jalr	208(ra) # 80006628 <virtio_disk_rw>
}
    80003560:	60e2                	ld	ra,24(sp)
    80003562:	6442                	ld	s0,16(sp)
    80003564:	64a2                	ld	s1,8(sp)
    80003566:	6105                	addi	sp,sp,32
    80003568:	8082                	ret
    panic("bwrite");
    8000356a:	00005517          	auipc	a0,0x5
    8000356e:	ebe50513          	addi	a0,a0,-322 # 80008428 <etext+0x428>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	fee080e7          	jalr	-18(ra) # 80000560 <panic>

000000008000357a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000357a:	1101                	addi	sp,sp,-32
    8000357c:	ec06                	sd	ra,24(sp)
    8000357e:	e822                	sd	s0,16(sp)
    80003580:	e426                	sd	s1,8(sp)
    80003582:	e04a                	sd	s2,0(sp)
    80003584:	1000                	addi	s0,sp,32
    80003586:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003588:	01050913          	addi	s2,a0,16
    8000358c:	854a                	mv	a0,s2
    8000358e:	00001097          	auipc	ra,0x1
    80003592:	44e080e7          	jalr	1102(ra) # 800049dc <holdingsleep>
    80003596:	c925                	beqz	a0,80003606 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003598:	854a                	mv	a0,s2
    8000359a:	00001097          	auipc	ra,0x1
    8000359e:	3fe080e7          	jalr	1022(ra) # 80004998 <releasesleep>

  acquire(&bcache.lock);
    800035a2:	0001a517          	auipc	a0,0x1a
    800035a6:	56e50513          	addi	a0,a0,1390 # 8001db10 <bcache>
    800035aa:	ffffd097          	auipc	ra,0xffffd
    800035ae:	68e080e7          	jalr	1678(ra) # 80000c38 <acquire>
  b->refcnt--;
    800035b2:	40bc                	lw	a5,64(s1)
    800035b4:	37fd                	addiw	a5,a5,-1
    800035b6:	0007871b          	sext.w	a4,a5
    800035ba:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800035bc:	e71d                	bnez	a4,800035ea <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800035be:	68b8                	ld	a4,80(s1)
    800035c0:	64bc                	ld	a5,72(s1)
    800035c2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800035c4:	68b8                	ld	a4,80(s1)
    800035c6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035c8:	00022797          	auipc	a5,0x22
    800035cc:	54878793          	addi	a5,a5,1352 # 80025b10 <bcache+0x8000>
    800035d0:	2b87b703          	ld	a4,696(a5)
    800035d4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035d6:	00022717          	auipc	a4,0x22
    800035da:	7a270713          	addi	a4,a4,1954 # 80025d78 <bcache+0x8268>
    800035de:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035e0:	2b87b703          	ld	a4,696(a5)
    800035e4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035e6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800035ea:	0001a517          	auipc	a0,0x1a
    800035ee:	52650513          	addi	a0,a0,1318 # 8001db10 <bcache>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	6fa080e7          	jalr	1786(ra) # 80000cec <release>
}
    800035fa:	60e2                	ld	ra,24(sp)
    800035fc:	6442                	ld	s0,16(sp)
    800035fe:	64a2                	ld	s1,8(sp)
    80003600:	6902                	ld	s2,0(sp)
    80003602:	6105                	addi	sp,sp,32
    80003604:	8082                	ret
    panic("brelse");
    80003606:	00005517          	auipc	a0,0x5
    8000360a:	e2a50513          	addi	a0,a0,-470 # 80008430 <etext+0x430>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	f52080e7          	jalr	-174(ra) # 80000560 <panic>

0000000080003616 <bpin>:

void
bpin(struct buf *b) {
    80003616:	1101                	addi	sp,sp,-32
    80003618:	ec06                	sd	ra,24(sp)
    8000361a:	e822                	sd	s0,16(sp)
    8000361c:	e426                	sd	s1,8(sp)
    8000361e:	1000                	addi	s0,sp,32
    80003620:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003622:	0001a517          	auipc	a0,0x1a
    80003626:	4ee50513          	addi	a0,a0,1262 # 8001db10 <bcache>
    8000362a:	ffffd097          	auipc	ra,0xffffd
    8000362e:	60e080e7          	jalr	1550(ra) # 80000c38 <acquire>
  b->refcnt++;
    80003632:	40bc                	lw	a5,64(s1)
    80003634:	2785                	addiw	a5,a5,1
    80003636:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003638:	0001a517          	auipc	a0,0x1a
    8000363c:	4d850513          	addi	a0,a0,1240 # 8001db10 <bcache>
    80003640:	ffffd097          	auipc	ra,0xffffd
    80003644:	6ac080e7          	jalr	1708(ra) # 80000cec <release>
}
    80003648:	60e2                	ld	ra,24(sp)
    8000364a:	6442                	ld	s0,16(sp)
    8000364c:	64a2                	ld	s1,8(sp)
    8000364e:	6105                	addi	sp,sp,32
    80003650:	8082                	ret

0000000080003652 <bunpin>:

void
bunpin(struct buf *b) {
    80003652:	1101                	addi	sp,sp,-32
    80003654:	ec06                	sd	ra,24(sp)
    80003656:	e822                	sd	s0,16(sp)
    80003658:	e426                	sd	s1,8(sp)
    8000365a:	1000                	addi	s0,sp,32
    8000365c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000365e:	0001a517          	auipc	a0,0x1a
    80003662:	4b250513          	addi	a0,a0,1202 # 8001db10 <bcache>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	5d2080e7          	jalr	1490(ra) # 80000c38 <acquire>
  b->refcnt--;
    8000366e:	40bc                	lw	a5,64(s1)
    80003670:	37fd                	addiw	a5,a5,-1
    80003672:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003674:	0001a517          	auipc	a0,0x1a
    80003678:	49c50513          	addi	a0,a0,1180 # 8001db10 <bcache>
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	670080e7          	jalr	1648(ra) # 80000cec <release>
}
    80003684:	60e2                	ld	ra,24(sp)
    80003686:	6442                	ld	s0,16(sp)
    80003688:	64a2                	ld	s1,8(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret

000000008000368e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000368e:	1101                	addi	sp,sp,-32
    80003690:	ec06                	sd	ra,24(sp)
    80003692:	e822                	sd	s0,16(sp)
    80003694:	e426                	sd	s1,8(sp)
    80003696:	e04a                	sd	s2,0(sp)
    80003698:	1000                	addi	s0,sp,32
    8000369a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000369c:	00d5d59b          	srliw	a1,a1,0xd
    800036a0:	00023797          	auipc	a5,0x23
    800036a4:	b4c7a783          	lw	a5,-1204(a5) # 800261ec <sb+0x1c>
    800036a8:	9dbd                	addw	a1,a1,a5
    800036aa:	00000097          	auipc	ra,0x0
    800036ae:	da0080e7          	jalr	-608(ra) # 8000344a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036b2:	0074f713          	andi	a4,s1,7
    800036b6:	4785                	li	a5,1
    800036b8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036bc:	14ce                	slli	s1,s1,0x33
    800036be:	90d9                	srli	s1,s1,0x36
    800036c0:	00950733          	add	a4,a0,s1
    800036c4:	05874703          	lbu	a4,88(a4)
    800036c8:	00e7f6b3          	and	a3,a5,a4
    800036cc:	c69d                	beqz	a3,800036fa <bfree+0x6c>
    800036ce:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036d0:	94aa                	add	s1,s1,a0
    800036d2:	fff7c793          	not	a5,a5
    800036d6:	8f7d                	and	a4,a4,a5
    800036d8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800036dc:	00001097          	auipc	ra,0x1
    800036e0:	148080e7          	jalr	328(ra) # 80004824 <log_write>
  brelse(bp);
    800036e4:	854a                	mv	a0,s2
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	e94080e7          	jalr	-364(ra) # 8000357a <brelse>
}
    800036ee:	60e2                	ld	ra,24(sp)
    800036f0:	6442                	ld	s0,16(sp)
    800036f2:	64a2                	ld	s1,8(sp)
    800036f4:	6902                	ld	s2,0(sp)
    800036f6:	6105                	addi	sp,sp,32
    800036f8:	8082                	ret
    panic("freeing free block");
    800036fa:	00005517          	auipc	a0,0x5
    800036fe:	d3e50513          	addi	a0,a0,-706 # 80008438 <etext+0x438>
    80003702:	ffffd097          	auipc	ra,0xffffd
    80003706:	e5e080e7          	jalr	-418(ra) # 80000560 <panic>

000000008000370a <balloc>:
{
    8000370a:	711d                	addi	sp,sp,-96
    8000370c:	ec86                	sd	ra,88(sp)
    8000370e:	e8a2                	sd	s0,80(sp)
    80003710:	e4a6                	sd	s1,72(sp)
    80003712:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003714:	00023797          	auipc	a5,0x23
    80003718:	ac07a783          	lw	a5,-1344(a5) # 800261d4 <sb+0x4>
    8000371c:	10078f63          	beqz	a5,8000383a <balloc+0x130>
    80003720:	e0ca                	sd	s2,64(sp)
    80003722:	fc4e                	sd	s3,56(sp)
    80003724:	f852                	sd	s4,48(sp)
    80003726:	f456                	sd	s5,40(sp)
    80003728:	f05a                	sd	s6,32(sp)
    8000372a:	ec5e                	sd	s7,24(sp)
    8000372c:	e862                	sd	s8,16(sp)
    8000372e:	e466                	sd	s9,8(sp)
    80003730:	8baa                	mv	s7,a0
    80003732:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003734:	00023b17          	auipc	s6,0x23
    80003738:	a9cb0b13          	addi	s6,s6,-1380 # 800261d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000373c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000373e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003740:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003742:	6c89                	lui	s9,0x2
    80003744:	a061                	j	800037cc <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003746:	97ca                	add	a5,a5,s2
    80003748:	8e55                	or	a2,a2,a3
    8000374a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000374e:	854a                	mv	a0,s2
    80003750:	00001097          	auipc	ra,0x1
    80003754:	0d4080e7          	jalr	212(ra) # 80004824 <log_write>
        brelse(bp);
    80003758:	854a                	mv	a0,s2
    8000375a:	00000097          	auipc	ra,0x0
    8000375e:	e20080e7          	jalr	-480(ra) # 8000357a <brelse>
  bp = bread(dev, bno);
    80003762:	85a6                	mv	a1,s1
    80003764:	855e                	mv	a0,s7
    80003766:	00000097          	auipc	ra,0x0
    8000376a:	ce4080e7          	jalr	-796(ra) # 8000344a <bread>
    8000376e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003770:	40000613          	li	a2,1024
    80003774:	4581                	li	a1,0
    80003776:	05850513          	addi	a0,a0,88
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	5ba080e7          	jalr	1466(ra) # 80000d34 <memset>
  log_write(bp);
    80003782:	854a                	mv	a0,s2
    80003784:	00001097          	auipc	ra,0x1
    80003788:	0a0080e7          	jalr	160(ra) # 80004824 <log_write>
  brelse(bp);
    8000378c:	854a                	mv	a0,s2
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	dec080e7          	jalr	-532(ra) # 8000357a <brelse>
}
    80003796:	6906                	ld	s2,64(sp)
    80003798:	79e2                	ld	s3,56(sp)
    8000379a:	7a42                	ld	s4,48(sp)
    8000379c:	7aa2                	ld	s5,40(sp)
    8000379e:	7b02                	ld	s6,32(sp)
    800037a0:	6be2                	ld	s7,24(sp)
    800037a2:	6c42                	ld	s8,16(sp)
    800037a4:	6ca2                	ld	s9,8(sp)
}
    800037a6:	8526                	mv	a0,s1
    800037a8:	60e6                	ld	ra,88(sp)
    800037aa:	6446                	ld	s0,80(sp)
    800037ac:	64a6                	ld	s1,72(sp)
    800037ae:	6125                	addi	sp,sp,96
    800037b0:	8082                	ret
    brelse(bp);
    800037b2:	854a                	mv	a0,s2
    800037b4:	00000097          	auipc	ra,0x0
    800037b8:	dc6080e7          	jalr	-570(ra) # 8000357a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037bc:	015c87bb          	addw	a5,s9,s5
    800037c0:	00078a9b          	sext.w	s5,a5
    800037c4:	004b2703          	lw	a4,4(s6)
    800037c8:	06eaf163          	bgeu	s5,a4,8000382a <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    800037cc:	41fad79b          	sraiw	a5,s5,0x1f
    800037d0:	0137d79b          	srliw	a5,a5,0x13
    800037d4:	015787bb          	addw	a5,a5,s5
    800037d8:	40d7d79b          	sraiw	a5,a5,0xd
    800037dc:	01cb2583          	lw	a1,28(s6)
    800037e0:	9dbd                	addw	a1,a1,a5
    800037e2:	855e                	mv	a0,s7
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	c66080e7          	jalr	-922(ra) # 8000344a <bread>
    800037ec:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ee:	004b2503          	lw	a0,4(s6)
    800037f2:	000a849b          	sext.w	s1,s5
    800037f6:	8762                	mv	a4,s8
    800037f8:	faa4fde3          	bgeu	s1,a0,800037b2 <balloc+0xa8>
      m = 1 << (bi % 8);
    800037fc:	00777693          	andi	a3,a4,7
    80003800:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003804:	41f7579b          	sraiw	a5,a4,0x1f
    80003808:	01d7d79b          	srliw	a5,a5,0x1d
    8000380c:	9fb9                	addw	a5,a5,a4
    8000380e:	4037d79b          	sraiw	a5,a5,0x3
    80003812:	00f90633          	add	a2,s2,a5
    80003816:	05864603          	lbu	a2,88(a2)
    8000381a:	00c6f5b3          	and	a1,a3,a2
    8000381e:	d585                	beqz	a1,80003746 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003820:	2705                	addiw	a4,a4,1
    80003822:	2485                	addiw	s1,s1,1
    80003824:	fd471ae3          	bne	a4,s4,800037f8 <balloc+0xee>
    80003828:	b769                	j	800037b2 <balloc+0xa8>
    8000382a:	6906                	ld	s2,64(sp)
    8000382c:	79e2                	ld	s3,56(sp)
    8000382e:	7a42                	ld	s4,48(sp)
    80003830:	7aa2                	ld	s5,40(sp)
    80003832:	7b02                	ld	s6,32(sp)
    80003834:	6be2                	ld	s7,24(sp)
    80003836:	6c42                	ld	s8,16(sp)
    80003838:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000383a:	00005517          	auipc	a0,0x5
    8000383e:	c1650513          	addi	a0,a0,-1002 # 80008450 <etext+0x450>
    80003842:	ffffd097          	auipc	ra,0xffffd
    80003846:	d68080e7          	jalr	-664(ra) # 800005aa <printf>
  return 0;
    8000384a:	4481                	li	s1,0
    8000384c:	bfa9                	j	800037a6 <balloc+0x9c>

000000008000384e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000384e:	7179                	addi	sp,sp,-48
    80003850:	f406                	sd	ra,40(sp)
    80003852:	f022                	sd	s0,32(sp)
    80003854:	ec26                	sd	s1,24(sp)
    80003856:	e84a                	sd	s2,16(sp)
    80003858:	e44e                	sd	s3,8(sp)
    8000385a:	1800                	addi	s0,sp,48
    8000385c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000385e:	47ad                	li	a5,11
    80003860:	02b7e863          	bltu	a5,a1,80003890 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003864:	02059793          	slli	a5,a1,0x20
    80003868:	01e7d593          	srli	a1,a5,0x1e
    8000386c:	00b504b3          	add	s1,a0,a1
    80003870:	0504a903          	lw	s2,80(s1)
    80003874:	08091263          	bnez	s2,800038f8 <bmap+0xaa>
      addr = balloc(ip->dev);
    80003878:	4108                	lw	a0,0(a0)
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	e90080e7          	jalr	-368(ra) # 8000370a <balloc>
    80003882:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003886:	06090963          	beqz	s2,800038f8 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    8000388a:	0524a823          	sw	s2,80(s1)
    8000388e:	a0ad                	j	800038f8 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003890:	ff45849b          	addiw	s1,a1,-12
    80003894:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003898:	0ff00793          	li	a5,255
    8000389c:	08e7e863          	bltu	a5,a4,8000392c <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800038a0:	08052903          	lw	s2,128(a0)
    800038a4:	00091f63          	bnez	s2,800038c2 <bmap+0x74>
      addr = balloc(ip->dev);
    800038a8:	4108                	lw	a0,0(a0)
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	e60080e7          	jalr	-416(ra) # 8000370a <balloc>
    800038b2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038b6:	04090163          	beqz	s2,800038f8 <bmap+0xaa>
    800038ba:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800038bc:	0929a023          	sw	s2,128(s3)
    800038c0:	a011                	j	800038c4 <bmap+0x76>
    800038c2:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800038c4:	85ca                	mv	a1,s2
    800038c6:	0009a503          	lw	a0,0(s3)
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	b80080e7          	jalr	-1152(ra) # 8000344a <bread>
    800038d2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038d4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038d8:	02049713          	slli	a4,s1,0x20
    800038dc:	01e75593          	srli	a1,a4,0x1e
    800038e0:	00b784b3          	add	s1,a5,a1
    800038e4:	0004a903          	lw	s2,0(s1)
    800038e8:	02090063          	beqz	s2,80003908 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038ec:	8552                	mv	a0,s4
    800038ee:	00000097          	auipc	ra,0x0
    800038f2:	c8c080e7          	jalr	-884(ra) # 8000357a <brelse>
    return addr;
    800038f6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800038f8:	854a                	mv	a0,s2
    800038fa:	70a2                	ld	ra,40(sp)
    800038fc:	7402                	ld	s0,32(sp)
    800038fe:	64e2                	ld	s1,24(sp)
    80003900:	6942                	ld	s2,16(sp)
    80003902:	69a2                	ld	s3,8(sp)
    80003904:	6145                	addi	sp,sp,48
    80003906:	8082                	ret
      addr = balloc(ip->dev);
    80003908:	0009a503          	lw	a0,0(s3)
    8000390c:	00000097          	auipc	ra,0x0
    80003910:	dfe080e7          	jalr	-514(ra) # 8000370a <balloc>
    80003914:	0005091b          	sext.w	s2,a0
      if(addr){
    80003918:	fc090ae3          	beqz	s2,800038ec <bmap+0x9e>
        a[bn] = addr;
    8000391c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003920:	8552                	mv	a0,s4
    80003922:	00001097          	auipc	ra,0x1
    80003926:	f02080e7          	jalr	-254(ra) # 80004824 <log_write>
    8000392a:	b7c9                	j	800038ec <bmap+0x9e>
    8000392c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000392e:	00005517          	auipc	a0,0x5
    80003932:	b3a50513          	addi	a0,a0,-1222 # 80008468 <etext+0x468>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	c2a080e7          	jalr	-982(ra) # 80000560 <panic>

000000008000393e <iget>:
{
    8000393e:	7179                	addi	sp,sp,-48
    80003940:	f406                	sd	ra,40(sp)
    80003942:	f022                	sd	s0,32(sp)
    80003944:	ec26                	sd	s1,24(sp)
    80003946:	e84a                	sd	s2,16(sp)
    80003948:	e44e                	sd	s3,8(sp)
    8000394a:	e052                	sd	s4,0(sp)
    8000394c:	1800                	addi	s0,sp,48
    8000394e:	89aa                	mv	s3,a0
    80003950:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003952:	00023517          	auipc	a0,0x23
    80003956:	89e50513          	addi	a0,a0,-1890 # 800261f0 <itable>
    8000395a:	ffffd097          	auipc	ra,0xffffd
    8000395e:	2de080e7          	jalr	734(ra) # 80000c38 <acquire>
  empty = 0;
    80003962:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003964:	00023497          	auipc	s1,0x23
    80003968:	8a448493          	addi	s1,s1,-1884 # 80026208 <itable+0x18>
    8000396c:	00024697          	auipc	a3,0x24
    80003970:	32c68693          	addi	a3,a3,812 # 80027c98 <log>
    80003974:	a039                	j	80003982 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003976:	02090b63          	beqz	s2,800039ac <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000397a:	08848493          	addi	s1,s1,136
    8000397e:	02d48a63          	beq	s1,a3,800039b2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003982:	449c                	lw	a5,8(s1)
    80003984:	fef059e3          	blez	a5,80003976 <iget+0x38>
    80003988:	4098                	lw	a4,0(s1)
    8000398a:	ff3716e3          	bne	a4,s3,80003976 <iget+0x38>
    8000398e:	40d8                	lw	a4,4(s1)
    80003990:	ff4713e3          	bne	a4,s4,80003976 <iget+0x38>
      ip->ref++;
    80003994:	2785                	addiw	a5,a5,1
    80003996:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003998:	00023517          	auipc	a0,0x23
    8000399c:	85850513          	addi	a0,a0,-1960 # 800261f0 <itable>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	34c080e7          	jalr	844(ra) # 80000cec <release>
      return ip;
    800039a8:	8926                	mv	s2,s1
    800039aa:	a03d                	j	800039d8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039ac:	f7f9                	bnez	a5,8000397a <iget+0x3c>
      empty = ip;
    800039ae:	8926                	mv	s2,s1
    800039b0:	b7e9                	j	8000397a <iget+0x3c>
  if(empty == 0)
    800039b2:	02090c63          	beqz	s2,800039ea <iget+0xac>
  ip->dev = dev;
    800039b6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039ba:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039be:	4785                	li	a5,1
    800039c0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039c4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039c8:	00023517          	auipc	a0,0x23
    800039cc:	82850513          	addi	a0,a0,-2008 # 800261f0 <itable>
    800039d0:	ffffd097          	auipc	ra,0xffffd
    800039d4:	31c080e7          	jalr	796(ra) # 80000cec <release>
}
    800039d8:	854a                	mv	a0,s2
    800039da:	70a2                	ld	ra,40(sp)
    800039dc:	7402                	ld	s0,32(sp)
    800039de:	64e2                	ld	s1,24(sp)
    800039e0:	6942                	ld	s2,16(sp)
    800039e2:	69a2                	ld	s3,8(sp)
    800039e4:	6a02                	ld	s4,0(sp)
    800039e6:	6145                	addi	sp,sp,48
    800039e8:	8082                	ret
    panic("iget: no inodes");
    800039ea:	00005517          	auipc	a0,0x5
    800039ee:	a9650513          	addi	a0,a0,-1386 # 80008480 <etext+0x480>
    800039f2:	ffffd097          	auipc	ra,0xffffd
    800039f6:	b6e080e7          	jalr	-1170(ra) # 80000560 <panic>

00000000800039fa <fsinit>:
fsinit(int dev) {
    800039fa:	7179                	addi	sp,sp,-48
    800039fc:	f406                	sd	ra,40(sp)
    800039fe:	f022                	sd	s0,32(sp)
    80003a00:	ec26                	sd	s1,24(sp)
    80003a02:	e84a                	sd	s2,16(sp)
    80003a04:	e44e                	sd	s3,8(sp)
    80003a06:	1800                	addi	s0,sp,48
    80003a08:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a0a:	4585                	li	a1,1
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	a3e080e7          	jalr	-1474(ra) # 8000344a <bread>
    80003a14:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a16:	00022997          	auipc	s3,0x22
    80003a1a:	7ba98993          	addi	s3,s3,1978 # 800261d0 <sb>
    80003a1e:	02000613          	li	a2,32
    80003a22:	05850593          	addi	a1,a0,88
    80003a26:	854e                	mv	a0,s3
    80003a28:	ffffd097          	auipc	ra,0xffffd
    80003a2c:	368080e7          	jalr	872(ra) # 80000d90 <memmove>
  brelse(bp);
    80003a30:	8526                	mv	a0,s1
    80003a32:	00000097          	auipc	ra,0x0
    80003a36:	b48080e7          	jalr	-1208(ra) # 8000357a <brelse>
  if(sb.magic != FSMAGIC)
    80003a3a:	0009a703          	lw	a4,0(s3)
    80003a3e:	102037b7          	lui	a5,0x10203
    80003a42:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a46:	02f71263          	bne	a4,a5,80003a6a <fsinit+0x70>
  initlog(dev, &sb);
    80003a4a:	00022597          	auipc	a1,0x22
    80003a4e:	78658593          	addi	a1,a1,1926 # 800261d0 <sb>
    80003a52:	854a                	mv	a0,s2
    80003a54:	00001097          	auipc	ra,0x1
    80003a58:	b60080e7          	jalr	-1184(ra) # 800045b4 <initlog>
}
    80003a5c:	70a2                	ld	ra,40(sp)
    80003a5e:	7402                	ld	s0,32(sp)
    80003a60:	64e2                	ld	s1,24(sp)
    80003a62:	6942                	ld	s2,16(sp)
    80003a64:	69a2                	ld	s3,8(sp)
    80003a66:	6145                	addi	sp,sp,48
    80003a68:	8082                	ret
    panic("invalid file system");
    80003a6a:	00005517          	auipc	a0,0x5
    80003a6e:	a2650513          	addi	a0,a0,-1498 # 80008490 <etext+0x490>
    80003a72:	ffffd097          	auipc	ra,0xffffd
    80003a76:	aee080e7          	jalr	-1298(ra) # 80000560 <panic>

0000000080003a7a <iinit>:
{
    80003a7a:	7179                	addi	sp,sp,-48
    80003a7c:	f406                	sd	ra,40(sp)
    80003a7e:	f022                	sd	s0,32(sp)
    80003a80:	ec26                	sd	s1,24(sp)
    80003a82:	e84a                	sd	s2,16(sp)
    80003a84:	e44e                	sd	s3,8(sp)
    80003a86:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a88:	00005597          	auipc	a1,0x5
    80003a8c:	a2058593          	addi	a1,a1,-1504 # 800084a8 <etext+0x4a8>
    80003a90:	00022517          	auipc	a0,0x22
    80003a94:	76050513          	addi	a0,a0,1888 # 800261f0 <itable>
    80003a98:	ffffd097          	auipc	ra,0xffffd
    80003a9c:	110080e7          	jalr	272(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003aa0:	00022497          	auipc	s1,0x22
    80003aa4:	77848493          	addi	s1,s1,1912 # 80026218 <itable+0x28>
    80003aa8:	00024997          	auipc	s3,0x24
    80003aac:	20098993          	addi	s3,s3,512 # 80027ca8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ab0:	00005917          	auipc	s2,0x5
    80003ab4:	a0090913          	addi	s2,s2,-1536 # 800084b0 <etext+0x4b0>
    80003ab8:	85ca                	mv	a1,s2
    80003aba:	8526                	mv	a0,s1
    80003abc:	00001097          	auipc	ra,0x1
    80003ac0:	e4c080e7          	jalr	-436(ra) # 80004908 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ac4:	08848493          	addi	s1,s1,136
    80003ac8:	ff3498e3          	bne	s1,s3,80003ab8 <iinit+0x3e>
}
    80003acc:	70a2                	ld	ra,40(sp)
    80003ace:	7402                	ld	s0,32(sp)
    80003ad0:	64e2                	ld	s1,24(sp)
    80003ad2:	6942                	ld	s2,16(sp)
    80003ad4:	69a2                	ld	s3,8(sp)
    80003ad6:	6145                	addi	sp,sp,48
    80003ad8:	8082                	ret

0000000080003ada <ialloc>:
{
    80003ada:	7139                	addi	sp,sp,-64
    80003adc:	fc06                	sd	ra,56(sp)
    80003ade:	f822                	sd	s0,48(sp)
    80003ae0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ae2:	00022717          	auipc	a4,0x22
    80003ae6:	6fa72703          	lw	a4,1786(a4) # 800261dc <sb+0xc>
    80003aea:	4785                	li	a5,1
    80003aec:	06e7f463          	bgeu	a5,a4,80003b54 <ialloc+0x7a>
    80003af0:	f426                	sd	s1,40(sp)
    80003af2:	f04a                	sd	s2,32(sp)
    80003af4:	ec4e                	sd	s3,24(sp)
    80003af6:	e852                	sd	s4,16(sp)
    80003af8:	e456                	sd	s5,8(sp)
    80003afa:	e05a                	sd	s6,0(sp)
    80003afc:	8aaa                	mv	s5,a0
    80003afe:	8b2e                	mv	s6,a1
    80003b00:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b02:	00022a17          	auipc	s4,0x22
    80003b06:	6cea0a13          	addi	s4,s4,1742 # 800261d0 <sb>
    80003b0a:	00495593          	srli	a1,s2,0x4
    80003b0e:	018a2783          	lw	a5,24(s4)
    80003b12:	9dbd                	addw	a1,a1,a5
    80003b14:	8556                	mv	a0,s5
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	934080e7          	jalr	-1740(ra) # 8000344a <bread>
    80003b1e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b20:	05850993          	addi	s3,a0,88
    80003b24:	00f97793          	andi	a5,s2,15
    80003b28:	079a                	slli	a5,a5,0x6
    80003b2a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b2c:	00099783          	lh	a5,0(s3)
    80003b30:	cf9d                	beqz	a5,80003b6e <ialloc+0x94>
    brelse(bp);
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	a48080e7          	jalr	-1464(ra) # 8000357a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b3a:	0905                	addi	s2,s2,1
    80003b3c:	00ca2703          	lw	a4,12(s4)
    80003b40:	0009079b          	sext.w	a5,s2
    80003b44:	fce7e3e3          	bltu	a5,a4,80003b0a <ialloc+0x30>
    80003b48:	74a2                	ld	s1,40(sp)
    80003b4a:	7902                	ld	s2,32(sp)
    80003b4c:	69e2                	ld	s3,24(sp)
    80003b4e:	6a42                	ld	s4,16(sp)
    80003b50:	6aa2                	ld	s5,8(sp)
    80003b52:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003b54:	00005517          	auipc	a0,0x5
    80003b58:	96450513          	addi	a0,a0,-1692 # 800084b8 <etext+0x4b8>
    80003b5c:	ffffd097          	auipc	ra,0xffffd
    80003b60:	a4e080e7          	jalr	-1458(ra) # 800005aa <printf>
  return 0;
    80003b64:	4501                	li	a0,0
}
    80003b66:	70e2                	ld	ra,56(sp)
    80003b68:	7442                	ld	s0,48(sp)
    80003b6a:	6121                	addi	sp,sp,64
    80003b6c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b6e:	04000613          	li	a2,64
    80003b72:	4581                	li	a1,0
    80003b74:	854e                	mv	a0,s3
    80003b76:	ffffd097          	auipc	ra,0xffffd
    80003b7a:	1be080e7          	jalr	446(ra) # 80000d34 <memset>
      dip->type = type;
    80003b7e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b82:	8526                	mv	a0,s1
    80003b84:	00001097          	auipc	ra,0x1
    80003b88:	ca0080e7          	jalr	-864(ra) # 80004824 <log_write>
      brelse(bp);
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	9ec080e7          	jalr	-1556(ra) # 8000357a <brelse>
      return iget(dev, inum);
    80003b96:	0009059b          	sext.w	a1,s2
    80003b9a:	8556                	mv	a0,s5
    80003b9c:	00000097          	auipc	ra,0x0
    80003ba0:	da2080e7          	jalr	-606(ra) # 8000393e <iget>
    80003ba4:	74a2                	ld	s1,40(sp)
    80003ba6:	7902                	ld	s2,32(sp)
    80003ba8:	69e2                	ld	s3,24(sp)
    80003baa:	6a42                	ld	s4,16(sp)
    80003bac:	6aa2                	ld	s5,8(sp)
    80003bae:	6b02                	ld	s6,0(sp)
    80003bb0:	bf5d                	j	80003b66 <ialloc+0x8c>

0000000080003bb2 <iupdate>:
{
    80003bb2:	1101                	addi	sp,sp,-32
    80003bb4:	ec06                	sd	ra,24(sp)
    80003bb6:	e822                	sd	s0,16(sp)
    80003bb8:	e426                	sd	s1,8(sp)
    80003bba:	e04a                	sd	s2,0(sp)
    80003bbc:	1000                	addi	s0,sp,32
    80003bbe:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bc0:	415c                	lw	a5,4(a0)
    80003bc2:	0047d79b          	srliw	a5,a5,0x4
    80003bc6:	00022597          	auipc	a1,0x22
    80003bca:	6225a583          	lw	a1,1570(a1) # 800261e8 <sb+0x18>
    80003bce:	9dbd                	addw	a1,a1,a5
    80003bd0:	4108                	lw	a0,0(a0)
    80003bd2:	00000097          	auipc	ra,0x0
    80003bd6:	878080e7          	jalr	-1928(ra) # 8000344a <bread>
    80003bda:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bdc:	05850793          	addi	a5,a0,88
    80003be0:	40d8                	lw	a4,4(s1)
    80003be2:	8b3d                	andi	a4,a4,15
    80003be4:	071a                	slli	a4,a4,0x6
    80003be6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003be8:	04449703          	lh	a4,68(s1)
    80003bec:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003bf0:	04649703          	lh	a4,70(s1)
    80003bf4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003bf8:	04849703          	lh	a4,72(s1)
    80003bfc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003c00:	04a49703          	lh	a4,74(s1)
    80003c04:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003c08:	44f8                	lw	a4,76(s1)
    80003c0a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c0c:	03400613          	li	a2,52
    80003c10:	05048593          	addi	a1,s1,80
    80003c14:	00c78513          	addi	a0,a5,12
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	178080e7          	jalr	376(ra) # 80000d90 <memmove>
  log_write(bp);
    80003c20:	854a                	mv	a0,s2
    80003c22:	00001097          	auipc	ra,0x1
    80003c26:	c02080e7          	jalr	-1022(ra) # 80004824 <log_write>
  brelse(bp);
    80003c2a:	854a                	mv	a0,s2
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	94e080e7          	jalr	-1714(ra) # 8000357a <brelse>
}
    80003c34:	60e2                	ld	ra,24(sp)
    80003c36:	6442                	ld	s0,16(sp)
    80003c38:	64a2                	ld	s1,8(sp)
    80003c3a:	6902                	ld	s2,0(sp)
    80003c3c:	6105                	addi	sp,sp,32
    80003c3e:	8082                	ret

0000000080003c40 <idup>:
{
    80003c40:	1101                	addi	sp,sp,-32
    80003c42:	ec06                	sd	ra,24(sp)
    80003c44:	e822                	sd	s0,16(sp)
    80003c46:	e426                	sd	s1,8(sp)
    80003c48:	1000                	addi	s0,sp,32
    80003c4a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c4c:	00022517          	auipc	a0,0x22
    80003c50:	5a450513          	addi	a0,a0,1444 # 800261f0 <itable>
    80003c54:	ffffd097          	auipc	ra,0xffffd
    80003c58:	fe4080e7          	jalr	-28(ra) # 80000c38 <acquire>
  ip->ref++;
    80003c5c:	449c                	lw	a5,8(s1)
    80003c5e:	2785                	addiw	a5,a5,1
    80003c60:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c62:	00022517          	auipc	a0,0x22
    80003c66:	58e50513          	addi	a0,a0,1422 # 800261f0 <itable>
    80003c6a:	ffffd097          	auipc	ra,0xffffd
    80003c6e:	082080e7          	jalr	130(ra) # 80000cec <release>
}
    80003c72:	8526                	mv	a0,s1
    80003c74:	60e2                	ld	ra,24(sp)
    80003c76:	6442                	ld	s0,16(sp)
    80003c78:	64a2                	ld	s1,8(sp)
    80003c7a:	6105                	addi	sp,sp,32
    80003c7c:	8082                	ret

0000000080003c7e <ilock>:
{
    80003c7e:	1101                	addi	sp,sp,-32
    80003c80:	ec06                	sd	ra,24(sp)
    80003c82:	e822                	sd	s0,16(sp)
    80003c84:	e426                	sd	s1,8(sp)
    80003c86:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c88:	c10d                	beqz	a0,80003caa <ilock+0x2c>
    80003c8a:	84aa                	mv	s1,a0
    80003c8c:	451c                	lw	a5,8(a0)
    80003c8e:	00f05e63          	blez	a5,80003caa <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003c92:	0541                	addi	a0,a0,16
    80003c94:	00001097          	auipc	ra,0x1
    80003c98:	cae080e7          	jalr	-850(ra) # 80004942 <acquiresleep>
  if(ip->valid == 0){
    80003c9c:	40bc                	lw	a5,64(s1)
    80003c9e:	cf99                	beqz	a5,80003cbc <ilock+0x3e>
}
    80003ca0:	60e2                	ld	ra,24(sp)
    80003ca2:	6442                	ld	s0,16(sp)
    80003ca4:	64a2                	ld	s1,8(sp)
    80003ca6:	6105                	addi	sp,sp,32
    80003ca8:	8082                	ret
    80003caa:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003cac:	00005517          	auipc	a0,0x5
    80003cb0:	82450513          	addi	a0,a0,-2012 # 800084d0 <etext+0x4d0>
    80003cb4:	ffffd097          	auipc	ra,0xffffd
    80003cb8:	8ac080e7          	jalr	-1876(ra) # 80000560 <panic>
    80003cbc:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cbe:	40dc                	lw	a5,4(s1)
    80003cc0:	0047d79b          	srliw	a5,a5,0x4
    80003cc4:	00022597          	auipc	a1,0x22
    80003cc8:	5245a583          	lw	a1,1316(a1) # 800261e8 <sb+0x18>
    80003ccc:	9dbd                	addw	a1,a1,a5
    80003cce:	4088                	lw	a0,0(s1)
    80003cd0:	fffff097          	auipc	ra,0xfffff
    80003cd4:	77a080e7          	jalr	1914(ra) # 8000344a <bread>
    80003cd8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cda:	05850593          	addi	a1,a0,88
    80003cde:	40dc                	lw	a5,4(s1)
    80003ce0:	8bbd                	andi	a5,a5,15
    80003ce2:	079a                	slli	a5,a5,0x6
    80003ce4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ce6:	00059783          	lh	a5,0(a1)
    80003cea:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cee:	00259783          	lh	a5,2(a1)
    80003cf2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cf6:	00459783          	lh	a5,4(a1)
    80003cfa:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cfe:	00659783          	lh	a5,6(a1)
    80003d02:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d06:	459c                	lw	a5,8(a1)
    80003d08:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d0a:	03400613          	li	a2,52
    80003d0e:	05b1                	addi	a1,a1,12
    80003d10:	05048513          	addi	a0,s1,80
    80003d14:	ffffd097          	auipc	ra,0xffffd
    80003d18:	07c080e7          	jalr	124(ra) # 80000d90 <memmove>
    brelse(bp);
    80003d1c:	854a                	mv	a0,s2
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	85c080e7          	jalr	-1956(ra) # 8000357a <brelse>
    ip->valid = 1;
    80003d26:	4785                	li	a5,1
    80003d28:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d2a:	04449783          	lh	a5,68(s1)
    80003d2e:	c399                	beqz	a5,80003d34 <ilock+0xb6>
    80003d30:	6902                	ld	s2,0(sp)
    80003d32:	b7bd                	j	80003ca0 <ilock+0x22>
      panic("ilock: no type");
    80003d34:	00004517          	auipc	a0,0x4
    80003d38:	7a450513          	addi	a0,a0,1956 # 800084d8 <etext+0x4d8>
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	824080e7          	jalr	-2012(ra) # 80000560 <panic>

0000000080003d44 <iunlock>:
{
    80003d44:	1101                	addi	sp,sp,-32
    80003d46:	ec06                	sd	ra,24(sp)
    80003d48:	e822                	sd	s0,16(sp)
    80003d4a:	e426                	sd	s1,8(sp)
    80003d4c:	e04a                	sd	s2,0(sp)
    80003d4e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d50:	c905                	beqz	a0,80003d80 <iunlock+0x3c>
    80003d52:	84aa                	mv	s1,a0
    80003d54:	01050913          	addi	s2,a0,16
    80003d58:	854a                	mv	a0,s2
    80003d5a:	00001097          	auipc	ra,0x1
    80003d5e:	c82080e7          	jalr	-894(ra) # 800049dc <holdingsleep>
    80003d62:	cd19                	beqz	a0,80003d80 <iunlock+0x3c>
    80003d64:	449c                	lw	a5,8(s1)
    80003d66:	00f05d63          	blez	a5,80003d80 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	00001097          	auipc	ra,0x1
    80003d70:	c2c080e7          	jalr	-980(ra) # 80004998 <releasesleep>
}
    80003d74:	60e2                	ld	ra,24(sp)
    80003d76:	6442                	ld	s0,16(sp)
    80003d78:	64a2                	ld	s1,8(sp)
    80003d7a:	6902                	ld	s2,0(sp)
    80003d7c:	6105                	addi	sp,sp,32
    80003d7e:	8082                	ret
    panic("iunlock");
    80003d80:	00004517          	auipc	a0,0x4
    80003d84:	76850513          	addi	a0,a0,1896 # 800084e8 <etext+0x4e8>
    80003d88:	ffffc097          	auipc	ra,0xffffc
    80003d8c:	7d8080e7          	jalr	2008(ra) # 80000560 <panic>

0000000080003d90 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d90:	7179                	addi	sp,sp,-48
    80003d92:	f406                	sd	ra,40(sp)
    80003d94:	f022                	sd	s0,32(sp)
    80003d96:	ec26                	sd	s1,24(sp)
    80003d98:	e84a                	sd	s2,16(sp)
    80003d9a:	e44e                	sd	s3,8(sp)
    80003d9c:	1800                	addi	s0,sp,48
    80003d9e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003da0:	05050493          	addi	s1,a0,80
    80003da4:	08050913          	addi	s2,a0,128
    80003da8:	a021                	j	80003db0 <itrunc+0x20>
    80003daa:	0491                	addi	s1,s1,4
    80003dac:	01248d63          	beq	s1,s2,80003dc6 <itrunc+0x36>
    if(ip->addrs[i]){
    80003db0:	408c                	lw	a1,0(s1)
    80003db2:	dde5                	beqz	a1,80003daa <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003db4:	0009a503          	lw	a0,0(s3)
    80003db8:	00000097          	auipc	ra,0x0
    80003dbc:	8d6080e7          	jalr	-1834(ra) # 8000368e <bfree>
      ip->addrs[i] = 0;
    80003dc0:	0004a023          	sw	zero,0(s1)
    80003dc4:	b7dd                	j	80003daa <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dc6:	0809a583          	lw	a1,128(s3)
    80003dca:	ed99                	bnez	a1,80003de8 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dcc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dd0:	854e                	mv	a0,s3
    80003dd2:	00000097          	auipc	ra,0x0
    80003dd6:	de0080e7          	jalr	-544(ra) # 80003bb2 <iupdate>
}
    80003dda:	70a2                	ld	ra,40(sp)
    80003ddc:	7402                	ld	s0,32(sp)
    80003dde:	64e2                	ld	s1,24(sp)
    80003de0:	6942                	ld	s2,16(sp)
    80003de2:	69a2                	ld	s3,8(sp)
    80003de4:	6145                	addi	sp,sp,48
    80003de6:	8082                	ret
    80003de8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dea:	0009a503          	lw	a0,0(s3)
    80003dee:	fffff097          	auipc	ra,0xfffff
    80003df2:	65c080e7          	jalr	1628(ra) # 8000344a <bread>
    80003df6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003df8:	05850493          	addi	s1,a0,88
    80003dfc:	45850913          	addi	s2,a0,1112
    80003e00:	a021                	j	80003e08 <itrunc+0x78>
    80003e02:	0491                	addi	s1,s1,4
    80003e04:	01248b63          	beq	s1,s2,80003e1a <itrunc+0x8a>
      if(a[j])
    80003e08:	408c                	lw	a1,0(s1)
    80003e0a:	dde5                	beqz	a1,80003e02 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003e0c:	0009a503          	lw	a0,0(s3)
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	87e080e7          	jalr	-1922(ra) # 8000368e <bfree>
    80003e18:	b7ed                	j	80003e02 <itrunc+0x72>
    brelse(bp);
    80003e1a:	8552                	mv	a0,s4
    80003e1c:	fffff097          	auipc	ra,0xfffff
    80003e20:	75e080e7          	jalr	1886(ra) # 8000357a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e24:	0809a583          	lw	a1,128(s3)
    80003e28:	0009a503          	lw	a0,0(s3)
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	862080e7          	jalr	-1950(ra) # 8000368e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e34:	0809a023          	sw	zero,128(s3)
    80003e38:	6a02                	ld	s4,0(sp)
    80003e3a:	bf49                	j	80003dcc <itrunc+0x3c>

0000000080003e3c <iput>:
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	1000                	addi	s0,sp,32
    80003e46:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e48:	00022517          	auipc	a0,0x22
    80003e4c:	3a850513          	addi	a0,a0,936 # 800261f0 <itable>
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	de8080e7          	jalr	-536(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e58:	4498                	lw	a4,8(s1)
    80003e5a:	4785                	li	a5,1
    80003e5c:	02f70263          	beq	a4,a5,80003e80 <iput+0x44>
  ip->ref--;
    80003e60:	449c                	lw	a5,8(s1)
    80003e62:	37fd                	addiw	a5,a5,-1
    80003e64:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e66:	00022517          	auipc	a0,0x22
    80003e6a:	38a50513          	addi	a0,a0,906 # 800261f0 <itable>
    80003e6e:	ffffd097          	auipc	ra,0xffffd
    80003e72:	e7e080e7          	jalr	-386(ra) # 80000cec <release>
}
    80003e76:	60e2                	ld	ra,24(sp)
    80003e78:	6442                	ld	s0,16(sp)
    80003e7a:	64a2                	ld	s1,8(sp)
    80003e7c:	6105                	addi	sp,sp,32
    80003e7e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e80:	40bc                	lw	a5,64(s1)
    80003e82:	dff9                	beqz	a5,80003e60 <iput+0x24>
    80003e84:	04a49783          	lh	a5,74(s1)
    80003e88:	ffe1                	bnez	a5,80003e60 <iput+0x24>
    80003e8a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003e8c:	01048913          	addi	s2,s1,16
    80003e90:	854a                	mv	a0,s2
    80003e92:	00001097          	auipc	ra,0x1
    80003e96:	ab0080e7          	jalr	-1360(ra) # 80004942 <acquiresleep>
    release(&itable.lock);
    80003e9a:	00022517          	auipc	a0,0x22
    80003e9e:	35650513          	addi	a0,a0,854 # 800261f0 <itable>
    80003ea2:	ffffd097          	auipc	ra,0xffffd
    80003ea6:	e4a080e7          	jalr	-438(ra) # 80000cec <release>
    itrunc(ip);
    80003eaa:	8526                	mv	a0,s1
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	ee4080e7          	jalr	-284(ra) # 80003d90 <itrunc>
    ip->type = 0;
    80003eb4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	cf8080e7          	jalr	-776(ra) # 80003bb2 <iupdate>
    ip->valid = 0;
    80003ec2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ec6:	854a                	mv	a0,s2
    80003ec8:	00001097          	auipc	ra,0x1
    80003ecc:	ad0080e7          	jalr	-1328(ra) # 80004998 <releasesleep>
    acquire(&itable.lock);
    80003ed0:	00022517          	auipc	a0,0x22
    80003ed4:	32050513          	addi	a0,a0,800 # 800261f0 <itable>
    80003ed8:	ffffd097          	auipc	ra,0xffffd
    80003edc:	d60080e7          	jalr	-672(ra) # 80000c38 <acquire>
    80003ee0:	6902                	ld	s2,0(sp)
    80003ee2:	bfbd                	j	80003e60 <iput+0x24>

0000000080003ee4 <iunlockput>:
{
    80003ee4:	1101                	addi	sp,sp,-32
    80003ee6:	ec06                	sd	ra,24(sp)
    80003ee8:	e822                	sd	s0,16(sp)
    80003eea:	e426                	sd	s1,8(sp)
    80003eec:	1000                	addi	s0,sp,32
    80003eee:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	e54080e7          	jalr	-428(ra) # 80003d44 <iunlock>
  iput(ip);
    80003ef8:	8526                	mv	a0,s1
    80003efa:	00000097          	auipc	ra,0x0
    80003efe:	f42080e7          	jalr	-190(ra) # 80003e3c <iput>
}
    80003f02:	60e2                	ld	ra,24(sp)
    80003f04:	6442                	ld	s0,16(sp)
    80003f06:	64a2                	ld	s1,8(sp)
    80003f08:	6105                	addi	sp,sp,32
    80003f0a:	8082                	ret

0000000080003f0c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f0c:	1141                	addi	sp,sp,-16
    80003f0e:	e422                	sd	s0,8(sp)
    80003f10:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f12:	411c                	lw	a5,0(a0)
    80003f14:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f16:	415c                	lw	a5,4(a0)
    80003f18:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f1a:	04451783          	lh	a5,68(a0)
    80003f1e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f22:	04a51783          	lh	a5,74(a0)
    80003f26:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f2a:	04c56783          	lwu	a5,76(a0)
    80003f2e:	e99c                	sd	a5,16(a1)
}
    80003f30:	6422                	ld	s0,8(sp)
    80003f32:	0141                	addi	sp,sp,16
    80003f34:	8082                	ret

0000000080003f36 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f36:	457c                	lw	a5,76(a0)
    80003f38:	10d7e563          	bltu	a5,a3,80004042 <readi+0x10c>
{
    80003f3c:	7159                	addi	sp,sp,-112
    80003f3e:	f486                	sd	ra,104(sp)
    80003f40:	f0a2                	sd	s0,96(sp)
    80003f42:	eca6                	sd	s1,88(sp)
    80003f44:	e0d2                	sd	s4,64(sp)
    80003f46:	fc56                	sd	s5,56(sp)
    80003f48:	f85a                	sd	s6,48(sp)
    80003f4a:	f45e                	sd	s7,40(sp)
    80003f4c:	1880                	addi	s0,sp,112
    80003f4e:	8b2a                	mv	s6,a0
    80003f50:	8bae                	mv	s7,a1
    80003f52:	8a32                	mv	s4,a2
    80003f54:	84b6                	mv	s1,a3
    80003f56:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f58:	9f35                	addw	a4,a4,a3
    return 0;
    80003f5a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f5c:	0cd76a63          	bltu	a4,a3,80004030 <readi+0xfa>
    80003f60:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003f62:	00e7f463          	bgeu	a5,a4,80003f6a <readi+0x34>
    n = ip->size - off;
    80003f66:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f6a:	0a0a8963          	beqz	s5,8000401c <readi+0xe6>
    80003f6e:	e8ca                	sd	s2,80(sp)
    80003f70:	f062                	sd	s8,32(sp)
    80003f72:	ec66                	sd	s9,24(sp)
    80003f74:	e86a                	sd	s10,16(sp)
    80003f76:	e46e                	sd	s11,8(sp)
    80003f78:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f7a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f7e:	5c7d                	li	s8,-1
    80003f80:	a82d                	j	80003fba <readi+0x84>
    80003f82:	020d1d93          	slli	s11,s10,0x20
    80003f86:	020ddd93          	srli	s11,s11,0x20
    80003f8a:	05890613          	addi	a2,s2,88
    80003f8e:	86ee                	mv	a3,s11
    80003f90:	963a                	add	a2,a2,a4
    80003f92:	85d2                	mv	a1,s4
    80003f94:	855e                	mv	a0,s7
    80003f96:	ffffe097          	auipc	ra,0xffffe
    80003f9a:	704080e7          	jalr	1796(ra) # 8000269a <either_copyout>
    80003f9e:	05850d63          	beq	a0,s8,80003ff8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fa2:	854a                	mv	a0,s2
    80003fa4:	fffff097          	auipc	ra,0xfffff
    80003fa8:	5d6080e7          	jalr	1494(ra) # 8000357a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fac:	013d09bb          	addw	s3,s10,s3
    80003fb0:	009d04bb          	addw	s1,s10,s1
    80003fb4:	9a6e                	add	s4,s4,s11
    80003fb6:	0559fd63          	bgeu	s3,s5,80004010 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003fba:	00a4d59b          	srliw	a1,s1,0xa
    80003fbe:	855a                	mv	a0,s6
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	88e080e7          	jalr	-1906(ra) # 8000384e <bmap>
    80003fc8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fcc:	c9b1                	beqz	a1,80004020 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003fce:	000b2503          	lw	a0,0(s6)
    80003fd2:	fffff097          	auipc	ra,0xfffff
    80003fd6:	478080e7          	jalr	1144(ra) # 8000344a <bread>
    80003fda:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fdc:	3ff4f713          	andi	a4,s1,1023
    80003fe0:	40ec87bb          	subw	a5,s9,a4
    80003fe4:	413a86bb          	subw	a3,s5,s3
    80003fe8:	8d3e                	mv	s10,a5
    80003fea:	2781                	sext.w	a5,a5
    80003fec:	0006861b          	sext.w	a2,a3
    80003ff0:	f8f679e3          	bgeu	a2,a5,80003f82 <readi+0x4c>
    80003ff4:	8d36                	mv	s10,a3
    80003ff6:	b771                	j	80003f82 <readi+0x4c>
      brelse(bp);
    80003ff8:	854a                	mv	a0,s2
    80003ffa:	fffff097          	auipc	ra,0xfffff
    80003ffe:	580080e7          	jalr	1408(ra) # 8000357a <brelse>
      tot = -1;
    80004002:	59fd                	li	s3,-1
      break;
    80004004:	6946                	ld	s2,80(sp)
    80004006:	7c02                	ld	s8,32(sp)
    80004008:	6ce2                	ld	s9,24(sp)
    8000400a:	6d42                	ld	s10,16(sp)
    8000400c:	6da2                	ld	s11,8(sp)
    8000400e:	a831                	j	8000402a <readi+0xf4>
    80004010:	6946                	ld	s2,80(sp)
    80004012:	7c02                	ld	s8,32(sp)
    80004014:	6ce2                	ld	s9,24(sp)
    80004016:	6d42                	ld	s10,16(sp)
    80004018:	6da2                	ld	s11,8(sp)
    8000401a:	a801                	j	8000402a <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000401c:	89d6                	mv	s3,s5
    8000401e:	a031                	j	8000402a <readi+0xf4>
    80004020:	6946                	ld	s2,80(sp)
    80004022:	7c02                	ld	s8,32(sp)
    80004024:	6ce2                	ld	s9,24(sp)
    80004026:	6d42                	ld	s10,16(sp)
    80004028:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000402a:	0009851b          	sext.w	a0,s3
    8000402e:	69a6                	ld	s3,72(sp)
}
    80004030:	70a6                	ld	ra,104(sp)
    80004032:	7406                	ld	s0,96(sp)
    80004034:	64e6                	ld	s1,88(sp)
    80004036:	6a06                	ld	s4,64(sp)
    80004038:	7ae2                	ld	s5,56(sp)
    8000403a:	7b42                	ld	s6,48(sp)
    8000403c:	7ba2                	ld	s7,40(sp)
    8000403e:	6165                	addi	sp,sp,112
    80004040:	8082                	ret
    return 0;
    80004042:	4501                	li	a0,0
}
    80004044:	8082                	ret

0000000080004046 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004046:	457c                	lw	a5,76(a0)
    80004048:	10d7ee63          	bltu	a5,a3,80004164 <writei+0x11e>
{
    8000404c:	7159                	addi	sp,sp,-112
    8000404e:	f486                	sd	ra,104(sp)
    80004050:	f0a2                	sd	s0,96(sp)
    80004052:	e8ca                	sd	s2,80(sp)
    80004054:	e0d2                	sd	s4,64(sp)
    80004056:	fc56                	sd	s5,56(sp)
    80004058:	f85a                	sd	s6,48(sp)
    8000405a:	f45e                	sd	s7,40(sp)
    8000405c:	1880                	addi	s0,sp,112
    8000405e:	8aaa                	mv	s5,a0
    80004060:	8bae                	mv	s7,a1
    80004062:	8a32                	mv	s4,a2
    80004064:	8936                	mv	s2,a3
    80004066:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004068:	00e687bb          	addw	a5,a3,a4
    8000406c:	0ed7ee63          	bltu	a5,a3,80004168 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004070:	00043737          	lui	a4,0x43
    80004074:	0ef76c63          	bltu	a4,a5,8000416c <writei+0x126>
    80004078:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000407a:	0c0b0d63          	beqz	s6,80004154 <writei+0x10e>
    8000407e:	eca6                	sd	s1,88(sp)
    80004080:	f062                	sd	s8,32(sp)
    80004082:	ec66                	sd	s9,24(sp)
    80004084:	e86a                	sd	s10,16(sp)
    80004086:	e46e                	sd	s11,8(sp)
    80004088:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000408a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000408e:	5c7d                	li	s8,-1
    80004090:	a091                	j	800040d4 <writei+0x8e>
    80004092:	020d1d93          	slli	s11,s10,0x20
    80004096:	020ddd93          	srli	s11,s11,0x20
    8000409a:	05848513          	addi	a0,s1,88
    8000409e:	86ee                	mv	a3,s11
    800040a0:	8652                	mv	a2,s4
    800040a2:	85de                	mv	a1,s7
    800040a4:	953a                	add	a0,a0,a4
    800040a6:	ffffe097          	auipc	ra,0xffffe
    800040aa:	64a080e7          	jalr	1610(ra) # 800026f0 <either_copyin>
    800040ae:	07850263          	beq	a0,s8,80004112 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040b2:	8526                	mv	a0,s1
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	770080e7          	jalr	1904(ra) # 80004824 <log_write>
    brelse(bp);
    800040bc:	8526                	mv	a0,s1
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	4bc080e7          	jalr	1212(ra) # 8000357a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040c6:	013d09bb          	addw	s3,s10,s3
    800040ca:	012d093b          	addw	s2,s10,s2
    800040ce:	9a6e                	add	s4,s4,s11
    800040d0:	0569f663          	bgeu	s3,s6,8000411c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800040d4:	00a9559b          	srliw	a1,s2,0xa
    800040d8:	8556                	mv	a0,s5
    800040da:	fffff097          	auipc	ra,0xfffff
    800040de:	774080e7          	jalr	1908(ra) # 8000384e <bmap>
    800040e2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800040e6:	c99d                	beqz	a1,8000411c <writei+0xd6>
    bp = bread(ip->dev, addr);
    800040e8:	000aa503          	lw	a0,0(s5)
    800040ec:	fffff097          	auipc	ra,0xfffff
    800040f0:	35e080e7          	jalr	862(ra) # 8000344a <bread>
    800040f4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040f6:	3ff97713          	andi	a4,s2,1023
    800040fa:	40ec87bb          	subw	a5,s9,a4
    800040fe:	413b06bb          	subw	a3,s6,s3
    80004102:	8d3e                	mv	s10,a5
    80004104:	2781                	sext.w	a5,a5
    80004106:	0006861b          	sext.w	a2,a3
    8000410a:	f8f674e3          	bgeu	a2,a5,80004092 <writei+0x4c>
    8000410e:	8d36                	mv	s10,a3
    80004110:	b749                	j	80004092 <writei+0x4c>
      brelse(bp);
    80004112:	8526                	mv	a0,s1
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	466080e7          	jalr	1126(ra) # 8000357a <brelse>
  }

  if(off > ip->size)
    8000411c:	04caa783          	lw	a5,76(s5)
    80004120:	0327fc63          	bgeu	a5,s2,80004158 <writei+0x112>
    ip->size = off;
    80004124:	052aa623          	sw	s2,76(s5)
    80004128:	64e6                	ld	s1,88(sp)
    8000412a:	7c02                	ld	s8,32(sp)
    8000412c:	6ce2                	ld	s9,24(sp)
    8000412e:	6d42                	ld	s10,16(sp)
    80004130:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004132:	8556                	mv	a0,s5
    80004134:	00000097          	auipc	ra,0x0
    80004138:	a7e080e7          	jalr	-1410(ra) # 80003bb2 <iupdate>

  return tot;
    8000413c:	0009851b          	sext.w	a0,s3
    80004140:	69a6                	ld	s3,72(sp)
}
    80004142:	70a6                	ld	ra,104(sp)
    80004144:	7406                	ld	s0,96(sp)
    80004146:	6946                	ld	s2,80(sp)
    80004148:	6a06                	ld	s4,64(sp)
    8000414a:	7ae2                	ld	s5,56(sp)
    8000414c:	7b42                	ld	s6,48(sp)
    8000414e:	7ba2                	ld	s7,40(sp)
    80004150:	6165                	addi	sp,sp,112
    80004152:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004154:	89da                	mv	s3,s6
    80004156:	bff1                	j	80004132 <writei+0xec>
    80004158:	64e6                	ld	s1,88(sp)
    8000415a:	7c02                	ld	s8,32(sp)
    8000415c:	6ce2                	ld	s9,24(sp)
    8000415e:	6d42                	ld	s10,16(sp)
    80004160:	6da2                	ld	s11,8(sp)
    80004162:	bfc1                	j	80004132 <writei+0xec>
    return -1;
    80004164:	557d                	li	a0,-1
}
    80004166:	8082                	ret
    return -1;
    80004168:	557d                	li	a0,-1
    8000416a:	bfe1                	j	80004142 <writei+0xfc>
    return -1;
    8000416c:	557d                	li	a0,-1
    8000416e:	bfd1                	j	80004142 <writei+0xfc>

0000000080004170 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004170:	1141                	addi	sp,sp,-16
    80004172:	e406                	sd	ra,8(sp)
    80004174:	e022                	sd	s0,0(sp)
    80004176:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004178:	4639                	li	a2,14
    8000417a:	ffffd097          	auipc	ra,0xffffd
    8000417e:	c8a080e7          	jalr	-886(ra) # 80000e04 <strncmp>
}
    80004182:	60a2                	ld	ra,8(sp)
    80004184:	6402                	ld	s0,0(sp)
    80004186:	0141                	addi	sp,sp,16
    80004188:	8082                	ret

000000008000418a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000418a:	7139                	addi	sp,sp,-64
    8000418c:	fc06                	sd	ra,56(sp)
    8000418e:	f822                	sd	s0,48(sp)
    80004190:	f426                	sd	s1,40(sp)
    80004192:	f04a                	sd	s2,32(sp)
    80004194:	ec4e                	sd	s3,24(sp)
    80004196:	e852                	sd	s4,16(sp)
    80004198:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000419a:	04451703          	lh	a4,68(a0)
    8000419e:	4785                	li	a5,1
    800041a0:	00f71a63          	bne	a4,a5,800041b4 <dirlookup+0x2a>
    800041a4:	892a                	mv	s2,a0
    800041a6:	89ae                	mv	s3,a1
    800041a8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041aa:	457c                	lw	a5,76(a0)
    800041ac:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041ae:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b0:	e79d                	bnez	a5,800041de <dirlookup+0x54>
    800041b2:	a8a5                	j	8000422a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800041b4:	00004517          	auipc	a0,0x4
    800041b8:	33c50513          	addi	a0,a0,828 # 800084f0 <etext+0x4f0>
    800041bc:	ffffc097          	auipc	ra,0xffffc
    800041c0:	3a4080e7          	jalr	932(ra) # 80000560 <panic>
      panic("dirlookup read");
    800041c4:	00004517          	auipc	a0,0x4
    800041c8:	34450513          	addi	a0,a0,836 # 80008508 <etext+0x508>
    800041cc:	ffffc097          	auipc	ra,0xffffc
    800041d0:	394080e7          	jalr	916(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041d4:	24c1                	addiw	s1,s1,16
    800041d6:	04c92783          	lw	a5,76(s2)
    800041da:	04f4f763          	bgeu	s1,a5,80004228 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041de:	4741                	li	a4,16
    800041e0:	86a6                	mv	a3,s1
    800041e2:	fc040613          	addi	a2,s0,-64
    800041e6:	4581                	li	a1,0
    800041e8:	854a                	mv	a0,s2
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	d4c080e7          	jalr	-692(ra) # 80003f36 <readi>
    800041f2:	47c1                	li	a5,16
    800041f4:	fcf518e3          	bne	a0,a5,800041c4 <dirlookup+0x3a>
    if(de.inum == 0)
    800041f8:	fc045783          	lhu	a5,-64(s0)
    800041fc:	dfe1                	beqz	a5,800041d4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041fe:	fc240593          	addi	a1,s0,-62
    80004202:	854e                	mv	a0,s3
    80004204:	00000097          	auipc	ra,0x0
    80004208:	f6c080e7          	jalr	-148(ra) # 80004170 <namecmp>
    8000420c:	f561                	bnez	a0,800041d4 <dirlookup+0x4a>
      if(poff)
    8000420e:	000a0463          	beqz	s4,80004216 <dirlookup+0x8c>
        *poff = off;
    80004212:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004216:	fc045583          	lhu	a1,-64(s0)
    8000421a:	00092503          	lw	a0,0(s2)
    8000421e:	fffff097          	auipc	ra,0xfffff
    80004222:	720080e7          	jalr	1824(ra) # 8000393e <iget>
    80004226:	a011                	j	8000422a <dirlookup+0xa0>
  return 0;
    80004228:	4501                	li	a0,0
}
    8000422a:	70e2                	ld	ra,56(sp)
    8000422c:	7442                	ld	s0,48(sp)
    8000422e:	74a2                	ld	s1,40(sp)
    80004230:	7902                	ld	s2,32(sp)
    80004232:	69e2                	ld	s3,24(sp)
    80004234:	6a42                	ld	s4,16(sp)
    80004236:	6121                	addi	sp,sp,64
    80004238:	8082                	ret

000000008000423a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000423a:	711d                	addi	sp,sp,-96
    8000423c:	ec86                	sd	ra,88(sp)
    8000423e:	e8a2                	sd	s0,80(sp)
    80004240:	e4a6                	sd	s1,72(sp)
    80004242:	e0ca                	sd	s2,64(sp)
    80004244:	fc4e                	sd	s3,56(sp)
    80004246:	f852                	sd	s4,48(sp)
    80004248:	f456                	sd	s5,40(sp)
    8000424a:	f05a                	sd	s6,32(sp)
    8000424c:	ec5e                	sd	s7,24(sp)
    8000424e:	e862                	sd	s8,16(sp)
    80004250:	e466                	sd	s9,8(sp)
    80004252:	1080                	addi	s0,sp,96
    80004254:	84aa                	mv	s1,a0
    80004256:	8b2e                	mv	s6,a1
    80004258:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000425a:	00054703          	lbu	a4,0(a0)
    8000425e:	02f00793          	li	a5,47
    80004262:	02f70263          	beq	a4,a5,80004286 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004266:	ffffe097          	auipc	ra,0xffffe
    8000426a:	814080e7          	jalr	-2028(ra) # 80001a7a <myproc>
    8000426e:	15053503          	ld	a0,336(a0)
    80004272:	00000097          	auipc	ra,0x0
    80004276:	9ce080e7          	jalr	-1586(ra) # 80003c40 <idup>
    8000427a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000427c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004280:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004282:	4b85                	li	s7,1
    80004284:	a875                	j	80004340 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004286:	4585                	li	a1,1
    80004288:	4505                	li	a0,1
    8000428a:	fffff097          	auipc	ra,0xfffff
    8000428e:	6b4080e7          	jalr	1716(ra) # 8000393e <iget>
    80004292:	8a2a                	mv	s4,a0
    80004294:	b7e5                	j	8000427c <namex+0x42>
      iunlockput(ip);
    80004296:	8552                	mv	a0,s4
    80004298:	00000097          	auipc	ra,0x0
    8000429c:	c4c080e7          	jalr	-948(ra) # 80003ee4 <iunlockput>
      return 0;
    800042a0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042a2:	8552                	mv	a0,s4
    800042a4:	60e6                	ld	ra,88(sp)
    800042a6:	6446                	ld	s0,80(sp)
    800042a8:	64a6                	ld	s1,72(sp)
    800042aa:	6906                	ld	s2,64(sp)
    800042ac:	79e2                	ld	s3,56(sp)
    800042ae:	7a42                	ld	s4,48(sp)
    800042b0:	7aa2                	ld	s5,40(sp)
    800042b2:	7b02                	ld	s6,32(sp)
    800042b4:	6be2                	ld	s7,24(sp)
    800042b6:	6c42                	ld	s8,16(sp)
    800042b8:	6ca2                	ld	s9,8(sp)
    800042ba:	6125                	addi	sp,sp,96
    800042bc:	8082                	ret
      iunlock(ip);
    800042be:	8552                	mv	a0,s4
    800042c0:	00000097          	auipc	ra,0x0
    800042c4:	a84080e7          	jalr	-1404(ra) # 80003d44 <iunlock>
      return ip;
    800042c8:	bfe9                	j	800042a2 <namex+0x68>
      iunlockput(ip);
    800042ca:	8552                	mv	a0,s4
    800042cc:	00000097          	auipc	ra,0x0
    800042d0:	c18080e7          	jalr	-1000(ra) # 80003ee4 <iunlockput>
      return 0;
    800042d4:	8a4e                	mv	s4,s3
    800042d6:	b7f1                	j	800042a2 <namex+0x68>
  len = path - s;
    800042d8:	40998633          	sub	a2,s3,s1
    800042dc:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042e0:	099c5863          	bge	s8,s9,80004370 <namex+0x136>
    memmove(name, s, DIRSIZ);
    800042e4:	4639                	li	a2,14
    800042e6:	85a6                	mv	a1,s1
    800042e8:	8556                	mv	a0,s5
    800042ea:	ffffd097          	auipc	ra,0xffffd
    800042ee:	aa6080e7          	jalr	-1370(ra) # 80000d90 <memmove>
    800042f2:	84ce                	mv	s1,s3
  while(*path == '/')
    800042f4:	0004c783          	lbu	a5,0(s1)
    800042f8:	01279763          	bne	a5,s2,80004306 <namex+0xcc>
    path++;
    800042fc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042fe:	0004c783          	lbu	a5,0(s1)
    80004302:	ff278de3          	beq	a5,s2,800042fc <namex+0xc2>
    ilock(ip);
    80004306:	8552                	mv	a0,s4
    80004308:	00000097          	auipc	ra,0x0
    8000430c:	976080e7          	jalr	-1674(ra) # 80003c7e <ilock>
    if(ip->type != T_DIR){
    80004310:	044a1783          	lh	a5,68(s4)
    80004314:	f97791e3          	bne	a5,s7,80004296 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004318:	000b0563          	beqz	s6,80004322 <namex+0xe8>
    8000431c:	0004c783          	lbu	a5,0(s1)
    80004320:	dfd9                	beqz	a5,800042be <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004322:	4601                	li	a2,0
    80004324:	85d6                	mv	a1,s5
    80004326:	8552                	mv	a0,s4
    80004328:	00000097          	auipc	ra,0x0
    8000432c:	e62080e7          	jalr	-414(ra) # 8000418a <dirlookup>
    80004330:	89aa                	mv	s3,a0
    80004332:	dd41                	beqz	a0,800042ca <namex+0x90>
    iunlockput(ip);
    80004334:	8552                	mv	a0,s4
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	bae080e7          	jalr	-1106(ra) # 80003ee4 <iunlockput>
    ip = next;
    8000433e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004340:	0004c783          	lbu	a5,0(s1)
    80004344:	01279763          	bne	a5,s2,80004352 <namex+0x118>
    path++;
    80004348:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000434a:	0004c783          	lbu	a5,0(s1)
    8000434e:	ff278de3          	beq	a5,s2,80004348 <namex+0x10e>
  if(*path == 0)
    80004352:	cb9d                	beqz	a5,80004388 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004354:	0004c783          	lbu	a5,0(s1)
    80004358:	89a6                	mv	s3,s1
  len = path - s;
    8000435a:	4c81                	li	s9,0
    8000435c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000435e:	01278963          	beq	a5,s2,80004370 <namex+0x136>
    80004362:	dbbd                	beqz	a5,800042d8 <namex+0x9e>
    path++;
    80004364:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004366:	0009c783          	lbu	a5,0(s3)
    8000436a:	ff279ce3          	bne	a5,s2,80004362 <namex+0x128>
    8000436e:	b7ad                	j	800042d8 <namex+0x9e>
    memmove(name, s, len);
    80004370:	2601                	sext.w	a2,a2
    80004372:	85a6                	mv	a1,s1
    80004374:	8556                	mv	a0,s5
    80004376:	ffffd097          	auipc	ra,0xffffd
    8000437a:	a1a080e7          	jalr	-1510(ra) # 80000d90 <memmove>
    name[len] = 0;
    8000437e:	9cd6                	add	s9,s9,s5
    80004380:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004384:	84ce                	mv	s1,s3
    80004386:	b7bd                	j	800042f4 <namex+0xba>
  if(nameiparent){
    80004388:	f00b0de3          	beqz	s6,800042a2 <namex+0x68>
    iput(ip);
    8000438c:	8552                	mv	a0,s4
    8000438e:	00000097          	auipc	ra,0x0
    80004392:	aae080e7          	jalr	-1362(ra) # 80003e3c <iput>
    return 0;
    80004396:	4a01                	li	s4,0
    80004398:	b729                	j	800042a2 <namex+0x68>

000000008000439a <dirlink>:
{
    8000439a:	7139                	addi	sp,sp,-64
    8000439c:	fc06                	sd	ra,56(sp)
    8000439e:	f822                	sd	s0,48(sp)
    800043a0:	f04a                	sd	s2,32(sp)
    800043a2:	ec4e                	sd	s3,24(sp)
    800043a4:	e852                	sd	s4,16(sp)
    800043a6:	0080                	addi	s0,sp,64
    800043a8:	892a                	mv	s2,a0
    800043aa:	8a2e                	mv	s4,a1
    800043ac:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043ae:	4601                	li	a2,0
    800043b0:	00000097          	auipc	ra,0x0
    800043b4:	dda080e7          	jalr	-550(ra) # 8000418a <dirlookup>
    800043b8:	ed25                	bnez	a0,80004430 <dirlink+0x96>
    800043ba:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043bc:	04c92483          	lw	s1,76(s2)
    800043c0:	c49d                	beqz	s1,800043ee <dirlink+0x54>
    800043c2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043c4:	4741                	li	a4,16
    800043c6:	86a6                	mv	a3,s1
    800043c8:	fc040613          	addi	a2,s0,-64
    800043cc:	4581                	li	a1,0
    800043ce:	854a                	mv	a0,s2
    800043d0:	00000097          	auipc	ra,0x0
    800043d4:	b66080e7          	jalr	-1178(ra) # 80003f36 <readi>
    800043d8:	47c1                	li	a5,16
    800043da:	06f51163          	bne	a0,a5,8000443c <dirlink+0xa2>
    if(de.inum == 0)
    800043de:	fc045783          	lhu	a5,-64(s0)
    800043e2:	c791                	beqz	a5,800043ee <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043e4:	24c1                	addiw	s1,s1,16
    800043e6:	04c92783          	lw	a5,76(s2)
    800043ea:	fcf4ede3          	bltu	s1,a5,800043c4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043ee:	4639                	li	a2,14
    800043f0:	85d2                	mv	a1,s4
    800043f2:	fc240513          	addi	a0,s0,-62
    800043f6:	ffffd097          	auipc	ra,0xffffd
    800043fa:	a44080e7          	jalr	-1468(ra) # 80000e3a <strncpy>
  de.inum = inum;
    800043fe:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004402:	4741                	li	a4,16
    80004404:	86a6                	mv	a3,s1
    80004406:	fc040613          	addi	a2,s0,-64
    8000440a:	4581                	li	a1,0
    8000440c:	854a                	mv	a0,s2
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	c38080e7          	jalr	-968(ra) # 80004046 <writei>
    80004416:	1541                	addi	a0,a0,-16
    80004418:	00a03533          	snez	a0,a0
    8000441c:	40a00533          	neg	a0,a0
    80004420:	74a2                	ld	s1,40(sp)
}
    80004422:	70e2                	ld	ra,56(sp)
    80004424:	7442                	ld	s0,48(sp)
    80004426:	7902                	ld	s2,32(sp)
    80004428:	69e2                	ld	s3,24(sp)
    8000442a:	6a42                	ld	s4,16(sp)
    8000442c:	6121                	addi	sp,sp,64
    8000442e:	8082                	ret
    iput(ip);
    80004430:	00000097          	auipc	ra,0x0
    80004434:	a0c080e7          	jalr	-1524(ra) # 80003e3c <iput>
    return -1;
    80004438:	557d                	li	a0,-1
    8000443a:	b7e5                	j	80004422 <dirlink+0x88>
      panic("dirlink read");
    8000443c:	00004517          	auipc	a0,0x4
    80004440:	0dc50513          	addi	a0,a0,220 # 80008518 <etext+0x518>
    80004444:	ffffc097          	auipc	ra,0xffffc
    80004448:	11c080e7          	jalr	284(ra) # 80000560 <panic>

000000008000444c <namei>:

struct inode*
namei(char *path)
{
    8000444c:	1101                	addi	sp,sp,-32
    8000444e:	ec06                	sd	ra,24(sp)
    80004450:	e822                	sd	s0,16(sp)
    80004452:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004454:	fe040613          	addi	a2,s0,-32
    80004458:	4581                	li	a1,0
    8000445a:	00000097          	auipc	ra,0x0
    8000445e:	de0080e7          	jalr	-544(ra) # 8000423a <namex>
}
    80004462:	60e2                	ld	ra,24(sp)
    80004464:	6442                	ld	s0,16(sp)
    80004466:	6105                	addi	sp,sp,32
    80004468:	8082                	ret

000000008000446a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000446a:	1141                	addi	sp,sp,-16
    8000446c:	e406                	sd	ra,8(sp)
    8000446e:	e022                	sd	s0,0(sp)
    80004470:	0800                	addi	s0,sp,16
    80004472:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004474:	4585                	li	a1,1
    80004476:	00000097          	auipc	ra,0x0
    8000447a:	dc4080e7          	jalr	-572(ra) # 8000423a <namex>
}
    8000447e:	60a2                	ld	ra,8(sp)
    80004480:	6402                	ld	s0,0(sp)
    80004482:	0141                	addi	sp,sp,16
    80004484:	8082                	ret

0000000080004486 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004486:	1101                	addi	sp,sp,-32
    80004488:	ec06                	sd	ra,24(sp)
    8000448a:	e822                	sd	s0,16(sp)
    8000448c:	e426                	sd	s1,8(sp)
    8000448e:	e04a                	sd	s2,0(sp)
    80004490:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004492:	00024917          	auipc	s2,0x24
    80004496:	80690913          	addi	s2,s2,-2042 # 80027c98 <log>
    8000449a:	01892583          	lw	a1,24(s2)
    8000449e:	02892503          	lw	a0,40(s2)
    800044a2:	fffff097          	auipc	ra,0xfffff
    800044a6:	fa8080e7          	jalr	-88(ra) # 8000344a <bread>
    800044aa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044ac:	02c92603          	lw	a2,44(s2)
    800044b0:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044b2:	00c05f63          	blez	a2,800044d0 <write_head+0x4a>
    800044b6:	00024717          	auipc	a4,0x24
    800044ba:	81270713          	addi	a4,a4,-2030 # 80027cc8 <log+0x30>
    800044be:	87aa                	mv	a5,a0
    800044c0:	060a                	slli	a2,a2,0x2
    800044c2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800044c4:	4314                	lw	a3,0(a4)
    800044c6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800044c8:	0711                	addi	a4,a4,4
    800044ca:	0791                	addi	a5,a5,4
    800044cc:	fec79ce3          	bne	a5,a2,800044c4 <write_head+0x3e>
  }
  bwrite(buf);
    800044d0:	8526                	mv	a0,s1
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	06a080e7          	jalr	106(ra) # 8000353c <bwrite>
  brelse(buf);
    800044da:	8526                	mv	a0,s1
    800044dc:	fffff097          	auipc	ra,0xfffff
    800044e0:	09e080e7          	jalr	158(ra) # 8000357a <brelse>
}
    800044e4:	60e2                	ld	ra,24(sp)
    800044e6:	6442                	ld	s0,16(sp)
    800044e8:	64a2                	ld	s1,8(sp)
    800044ea:	6902                	ld	s2,0(sp)
    800044ec:	6105                	addi	sp,sp,32
    800044ee:	8082                	ret

00000000800044f0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044f0:	00023797          	auipc	a5,0x23
    800044f4:	7d47a783          	lw	a5,2004(a5) # 80027cc4 <log+0x2c>
    800044f8:	0af05d63          	blez	a5,800045b2 <install_trans+0xc2>
{
    800044fc:	7139                	addi	sp,sp,-64
    800044fe:	fc06                	sd	ra,56(sp)
    80004500:	f822                	sd	s0,48(sp)
    80004502:	f426                	sd	s1,40(sp)
    80004504:	f04a                	sd	s2,32(sp)
    80004506:	ec4e                	sd	s3,24(sp)
    80004508:	e852                	sd	s4,16(sp)
    8000450a:	e456                	sd	s5,8(sp)
    8000450c:	e05a                	sd	s6,0(sp)
    8000450e:	0080                	addi	s0,sp,64
    80004510:	8b2a                	mv	s6,a0
    80004512:	00023a97          	auipc	s5,0x23
    80004516:	7b6a8a93          	addi	s5,s5,1974 # 80027cc8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000451a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000451c:	00023997          	auipc	s3,0x23
    80004520:	77c98993          	addi	s3,s3,1916 # 80027c98 <log>
    80004524:	a00d                	j	80004546 <install_trans+0x56>
    brelse(lbuf);
    80004526:	854a                	mv	a0,s2
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	052080e7          	jalr	82(ra) # 8000357a <brelse>
    brelse(dbuf);
    80004530:	8526                	mv	a0,s1
    80004532:	fffff097          	auipc	ra,0xfffff
    80004536:	048080e7          	jalr	72(ra) # 8000357a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000453a:	2a05                	addiw	s4,s4,1
    8000453c:	0a91                	addi	s5,s5,4
    8000453e:	02c9a783          	lw	a5,44(s3)
    80004542:	04fa5e63          	bge	s4,a5,8000459e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004546:	0189a583          	lw	a1,24(s3)
    8000454a:	014585bb          	addw	a1,a1,s4
    8000454e:	2585                	addiw	a1,a1,1
    80004550:	0289a503          	lw	a0,40(s3)
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	ef6080e7          	jalr	-266(ra) # 8000344a <bread>
    8000455c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000455e:	000aa583          	lw	a1,0(s5)
    80004562:	0289a503          	lw	a0,40(s3)
    80004566:	fffff097          	auipc	ra,0xfffff
    8000456a:	ee4080e7          	jalr	-284(ra) # 8000344a <bread>
    8000456e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004570:	40000613          	li	a2,1024
    80004574:	05890593          	addi	a1,s2,88
    80004578:	05850513          	addi	a0,a0,88
    8000457c:	ffffd097          	auipc	ra,0xffffd
    80004580:	814080e7          	jalr	-2028(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004584:	8526                	mv	a0,s1
    80004586:	fffff097          	auipc	ra,0xfffff
    8000458a:	fb6080e7          	jalr	-74(ra) # 8000353c <bwrite>
    if(recovering == 0)
    8000458e:	f80b1ce3          	bnez	s6,80004526 <install_trans+0x36>
      bunpin(dbuf);
    80004592:	8526                	mv	a0,s1
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	0be080e7          	jalr	190(ra) # 80003652 <bunpin>
    8000459c:	b769                	j	80004526 <install_trans+0x36>
}
    8000459e:	70e2                	ld	ra,56(sp)
    800045a0:	7442                	ld	s0,48(sp)
    800045a2:	74a2                	ld	s1,40(sp)
    800045a4:	7902                	ld	s2,32(sp)
    800045a6:	69e2                	ld	s3,24(sp)
    800045a8:	6a42                	ld	s4,16(sp)
    800045aa:	6aa2                	ld	s5,8(sp)
    800045ac:	6b02                	ld	s6,0(sp)
    800045ae:	6121                	addi	sp,sp,64
    800045b0:	8082                	ret
    800045b2:	8082                	ret

00000000800045b4 <initlog>:
{
    800045b4:	7179                	addi	sp,sp,-48
    800045b6:	f406                	sd	ra,40(sp)
    800045b8:	f022                	sd	s0,32(sp)
    800045ba:	ec26                	sd	s1,24(sp)
    800045bc:	e84a                	sd	s2,16(sp)
    800045be:	e44e                	sd	s3,8(sp)
    800045c0:	1800                	addi	s0,sp,48
    800045c2:	892a                	mv	s2,a0
    800045c4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045c6:	00023497          	auipc	s1,0x23
    800045ca:	6d248493          	addi	s1,s1,1746 # 80027c98 <log>
    800045ce:	00004597          	auipc	a1,0x4
    800045d2:	f5a58593          	addi	a1,a1,-166 # 80008528 <etext+0x528>
    800045d6:	8526                	mv	a0,s1
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	5d0080e7          	jalr	1488(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    800045e0:	0149a583          	lw	a1,20(s3)
    800045e4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800045e6:	0109a783          	lw	a5,16(s3)
    800045ea:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800045ec:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045f0:	854a                	mv	a0,s2
    800045f2:	fffff097          	auipc	ra,0xfffff
    800045f6:	e58080e7          	jalr	-424(ra) # 8000344a <bread>
  log.lh.n = lh->n;
    800045fa:	4d30                	lw	a2,88(a0)
    800045fc:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045fe:	00c05f63          	blez	a2,8000461c <initlog+0x68>
    80004602:	87aa                	mv	a5,a0
    80004604:	00023717          	auipc	a4,0x23
    80004608:	6c470713          	addi	a4,a4,1732 # 80027cc8 <log+0x30>
    8000460c:	060a                	slli	a2,a2,0x2
    8000460e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004610:	4ff4                	lw	a3,92(a5)
    80004612:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004614:	0791                	addi	a5,a5,4
    80004616:	0711                	addi	a4,a4,4
    80004618:	fec79ce3          	bne	a5,a2,80004610 <initlog+0x5c>
  brelse(buf);
    8000461c:	fffff097          	auipc	ra,0xfffff
    80004620:	f5e080e7          	jalr	-162(ra) # 8000357a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004624:	4505                	li	a0,1
    80004626:	00000097          	auipc	ra,0x0
    8000462a:	eca080e7          	jalr	-310(ra) # 800044f0 <install_trans>
  log.lh.n = 0;
    8000462e:	00023797          	auipc	a5,0x23
    80004632:	6807ab23          	sw	zero,1686(a5) # 80027cc4 <log+0x2c>
  write_head(); // clear the log
    80004636:	00000097          	auipc	ra,0x0
    8000463a:	e50080e7          	jalr	-432(ra) # 80004486 <write_head>
}
    8000463e:	70a2                	ld	ra,40(sp)
    80004640:	7402                	ld	s0,32(sp)
    80004642:	64e2                	ld	s1,24(sp)
    80004644:	6942                	ld	s2,16(sp)
    80004646:	69a2                	ld	s3,8(sp)
    80004648:	6145                	addi	sp,sp,48
    8000464a:	8082                	ret

000000008000464c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000464c:	1101                	addi	sp,sp,-32
    8000464e:	ec06                	sd	ra,24(sp)
    80004650:	e822                	sd	s0,16(sp)
    80004652:	e426                	sd	s1,8(sp)
    80004654:	e04a                	sd	s2,0(sp)
    80004656:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004658:	00023517          	auipc	a0,0x23
    8000465c:	64050513          	addi	a0,a0,1600 # 80027c98 <log>
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	5d8080e7          	jalr	1496(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    80004668:	00023497          	auipc	s1,0x23
    8000466c:	63048493          	addi	s1,s1,1584 # 80027c98 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004670:	4979                	li	s2,30
    80004672:	a039                	j	80004680 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004674:	85a6                	mv	a1,s1
    80004676:	8526                	mv	a0,s1
    80004678:	ffffe097          	auipc	ra,0xffffe
    8000467c:	c0e080e7          	jalr	-1010(ra) # 80002286 <sleep>
    if(log.committing){
    80004680:	50dc                	lw	a5,36(s1)
    80004682:	fbed                	bnez	a5,80004674 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004684:	5098                	lw	a4,32(s1)
    80004686:	2705                	addiw	a4,a4,1
    80004688:	0027179b          	slliw	a5,a4,0x2
    8000468c:	9fb9                	addw	a5,a5,a4
    8000468e:	0017979b          	slliw	a5,a5,0x1
    80004692:	54d4                	lw	a3,44(s1)
    80004694:	9fb5                	addw	a5,a5,a3
    80004696:	00f95963          	bge	s2,a5,800046a8 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000469a:	85a6                	mv	a1,s1
    8000469c:	8526                	mv	a0,s1
    8000469e:	ffffe097          	auipc	ra,0xffffe
    800046a2:	be8080e7          	jalr	-1048(ra) # 80002286 <sleep>
    800046a6:	bfe9                	j	80004680 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046a8:	00023517          	auipc	a0,0x23
    800046ac:	5f050513          	addi	a0,a0,1520 # 80027c98 <log>
    800046b0:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	63a080e7          	jalr	1594(ra) # 80000cec <release>
      break;
    }
  }
}
    800046ba:	60e2                	ld	ra,24(sp)
    800046bc:	6442                	ld	s0,16(sp)
    800046be:	64a2                	ld	s1,8(sp)
    800046c0:	6902                	ld	s2,0(sp)
    800046c2:	6105                	addi	sp,sp,32
    800046c4:	8082                	ret

00000000800046c6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046c6:	7139                	addi	sp,sp,-64
    800046c8:	fc06                	sd	ra,56(sp)
    800046ca:	f822                	sd	s0,48(sp)
    800046cc:	f426                	sd	s1,40(sp)
    800046ce:	f04a                	sd	s2,32(sp)
    800046d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046d2:	00023497          	auipc	s1,0x23
    800046d6:	5c648493          	addi	s1,s1,1478 # 80027c98 <log>
    800046da:	8526                	mv	a0,s1
    800046dc:	ffffc097          	auipc	ra,0xffffc
    800046e0:	55c080e7          	jalr	1372(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    800046e4:	509c                	lw	a5,32(s1)
    800046e6:	37fd                	addiw	a5,a5,-1
    800046e8:	0007891b          	sext.w	s2,a5
    800046ec:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046ee:	50dc                	lw	a5,36(s1)
    800046f0:	e7b9                	bnez	a5,8000473e <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800046f2:	06091163          	bnez	s2,80004754 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046f6:	00023497          	auipc	s1,0x23
    800046fa:	5a248493          	addi	s1,s1,1442 # 80027c98 <log>
    800046fe:	4785                	li	a5,1
    80004700:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004702:	8526                	mv	a0,s1
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	5e8080e7          	jalr	1512(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000470c:	54dc                	lw	a5,44(s1)
    8000470e:	06f04763          	bgtz	a5,8000477c <end_op+0xb6>
    acquire(&log.lock);
    80004712:	00023497          	auipc	s1,0x23
    80004716:	58648493          	addi	s1,s1,1414 # 80027c98 <log>
    8000471a:	8526                	mv	a0,s1
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	51c080e7          	jalr	1308(ra) # 80000c38 <acquire>
    log.committing = 0;
    80004724:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004728:	8526                	mv	a0,s1
    8000472a:	ffffe097          	auipc	ra,0xffffe
    8000472e:	bc0080e7          	jalr	-1088(ra) # 800022ea <wakeup>
    release(&log.lock);
    80004732:	8526                	mv	a0,s1
    80004734:	ffffc097          	auipc	ra,0xffffc
    80004738:	5b8080e7          	jalr	1464(ra) # 80000cec <release>
}
    8000473c:	a815                	j	80004770 <end_op+0xaa>
    8000473e:	ec4e                	sd	s3,24(sp)
    80004740:	e852                	sd	s4,16(sp)
    80004742:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004744:	00004517          	auipc	a0,0x4
    80004748:	dec50513          	addi	a0,a0,-532 # 80008530 <etext+0x530>
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	e14080e7          	jalr	-492(ra) # 80000560 <panic>
    wakeup(&log);
    80004754:	00023497          	auipc	s1,0x23
    80004758:	54448493          	addi	s1,s1,1348 # 80027c98 <log>
    8000475c:	8526                	mv	a0,s1
    8000475e:	ffffe097          	auipc	ra,0xffffe
    80004762:	b8c080e7          	jalr	-1140(ra) # 800022ea <wakeup>
  release(&log.lock);
    80004766:	8526                	mv	a0,s1
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	584080e7          	jalr	1412(ra) # 80000cec <release>
}
    80004770:	70e2                	ld	ra,56(sp)
    80004772:	7442                	ld	s0,48(sp)
    80004774:	74a2                	ld	s1,40(sp)
    80004776:	7902                	ld	s2,32(sp)
    80004778:	6121                	addi	sp,sp,64
    8000477a:	8082                	ret
    8000477c:	ec4e                	sd	s3,24(sp)
    8000477e:	e852                	sd	s4,16(sp)
    80004780:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004782:	00023a97          	auipc	s5,0x23
    80004786:	546a8a93          	addi	s5,s5,1350 # 80027cc8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000478a:	00023a17          	auipc	s4,0x23
    8000478e:	50ea0a13          	addi	s4,s4,1294 # 80027c98 <log>
    80004792:	018a2583          	lw	a1,24(s4)
    80004796:	012585bb          	addw	a1,a1,s2
    8000479a:	2585                	addiw	a1,a1,1
    8000479c:	028a2503          	lw	a0,40(s4)
    800047a0:	fffff097          	auipc	ra,0xfffff
    800047a4:	caa080e7          	jalr	-854(ra) # 8000344a <bread>
    800047a8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047aa:	000aa583          	lw	a1,0(s5)
    800047ae:	028a2503          	lw	a0,40(s4)
    800047b2:	fffff097          	auipc	ra,0xfffff
    800047b6:	c98080e7          	jalr	-872(ra) # 8000344a <bread>
    800047ba:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047bc:	40000613          	li	a2,1024
    800047c0:	05850593          	addi	a1,a0,88
    800047c4:	05848513          	addi	a0,s1,88
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	5c8080e7          	jalr	1480(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    800047d0:	8526                	mv	a0,s1
    800047d2:	fffff097          	auipc	ra,0xfffff
    800047d6:	d6a080e7          	jalr	-662(ra) # 8000353c <bwrite>
    brelse(from);
    800047da:	854e                	mv	a0,s3
    800047dc:	fffff097          	auipc	ra,0xfffff
    800047e0:	d9e080e7          	jalr	-610(ra) # 8000357a <brelse>
    brelse(to);
    800047e4:	8526                	mv	a0,s1
    800047e6:	fffff097          	auipc	ra,0xfffff
    800047ea:	d94080e7          	jalr	-620(ra) # 8000357a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ee:	2905                	addiw	s2,s2,1
    800047f0:	0a91                	addi	s5,s5,4
    800047f2:	02ca2783          	lw	a5,44(s4)
    800047f6:	f8f94ee3          	blt	s2,a5,80004792 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047fa:	00000097          	auipc	ra,0x0
    800047fe:	c8c080e7          	jalr	-884(ra) # 80004486 <write_head>
    install_trans(0); // Now install writes to home locations
    80004802:	4501                	li	a0,0
    80004804:	00000097          	auipc	ra,0x0
    80004808:	cec080e7          	jalr	-788(ra) # 800044f0 <install_trans>
    log.lh.n = 0;
    8000480c:	00023797          	auipc	a5,0x23
    80004810:	4a07ac23          	sw	zero,1208(a5) # 80027cc4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004814:	00000097          	auipc	ra,0x0
    80004818:	c72080e7          	jalr	-910(ra) # 80004486 <write_head>
    8000481c:	69e2                	ld	s3,24(sp)
    8000481e:	6a42                	ld	s4,16(sp)
    80004820:	6aa2                	ld	s5,8(sp)
    80004822:	bdc5                	j	80004712 <end_op+0x4c>

0000000080004824 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004824:	1101                	addi	sp,sp,-32
    80004826:	ec06                	sd	ra,24(sp)
    80004828:	e822                	sd	s0,16(sp)
    8000482a:	e426                	sd	s1,8(sp)
    8000482c:	e04a                	sd	s2,0(sp)
    8000482e:	1000                	addi	s0,sp,32
    80004830:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004832:	00023917          	auipc	s2,0x23
    80004836:	46690913          	addi	s2,s2,1126 # 80027c98 <log>
    8000483a:	854a                	mv	a0,s2
    8000483c:	ffffc097          	auipc	ra,0xffffc
    80004840:	3fc080e7          	jalr	1020(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004844:	02c92603          	lw	a2,44(s2)
    80004848:	47f5                	li	a5,29
    8000484a:	06c7c563          	blt	a5,a2,800048b4 <log_write+0x90>
    8000484e:	00023797          	auipc	a5,0x23
    80004852:	4667a783          	lw	a5,1126(a5) # 80027cb4 <log+0x1c>
    80004856:	37fd                	addiw	a5,a5,-1
    80004858:	04f65e63          	bge	a2,a5,800048b4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000485c:	00023797          	auipc	a5,0x23
    80004860:	45c7a783          	lw	a5,1116(a5) # 80027cb8 <log+0x20>
    80004864:	06f05063          	blez	a5,800048c4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004868:	4781                	li	a5,0
    8000486a:	06c05563          	blez	a2,800048d4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000486e:	44cc                	lw	a1,12(s1)
    80004870:	00023717          	auipc	a4,0x23
    80004874:	45870713          	addi	a4,a4,1112 # 80027cc8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004878:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000487a:	4314                	lw	a3,0(a4)
    8000487c:	04b68c63          	beq	a3,a1,800048d4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004880:	2785                	addiw	a5,a5,1
    80004882:	0711                	addi	a4,a4,4
    80004884:	fef61be3          	bne	a2,a5,8000487a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004888:	0621                	addi	a2,a2,8
    8000488a:	060a                	slli	a2,a2,0x2
    8000488c:	00023797          	auipc	a5,0x23
    80004890:	40c78793          	addi	a5,a5,1036 # 80027c98 <log>
    80004894:	97b2                	add	a5,a5,a2
    80004896:	44d8                	lw	a4,12(s1)
    80004898:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000489a:	8526                	mv	a0,s1
    8000489c:	fffff097          	auipc	ra,0xfffff
    800048a0:	d7a080e7          	jalr	-646(ra) # 80003616 <bpin>
    log.lh.n++;
    800048a4:	00023717          	auipc	a4,0x23
    800048a8:	3f470713          	addi	a4,a4,1012 # 80027c98 <log>
    800048ac:	575c                	lw	a5,44(a4)
    800048ae:	2785                	addiw	a5,a5,1
    800048b0:	d75c                	sw	a5,44(a4)
    800048b2:	a82d                	j	800048ec <log_write+0xc8>
    panic("too big a transaction");
    800048b4:	00004517          	auipc	a0,0x4
    800048b8:	c8c50513          	addi	a0,a0,-884 # 80008540 <etext+0x540>
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	ca4080e7          	jalr	-860(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    800048c4:	00004517          	auipc	a0,0x4
    800048c8:	c9450513          	addi	a0,a0,-876 # 80008558 <etext+0x558>
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	c94080e7          	jalr	-876(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    800048d4:	00878693          	addi	a3,a5,8
    800048d8:	068a                	slli	a3,a3,0x2
    800048da:	00023717          	auipc	a4,0x23
    800048de:	3be70713          	addi	a4,a4,958 # 80027c98 <log>
    800048e2:	9736                	add	a4,a4,a3
    800048e4:	44d4                	lw	a3,12(s1)
    800048e6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048e8:	faf609e3          	beq	a2,a5,8000489a <log_write+0x76>
  }
  release(&log.lock);
    800048ec:	00023517          	auipc	a0,0x23
    800048f0:	3ac50513          	addi	a0,a0,940 # 80027c98 <log>
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	3f8080e7          	jalr	1016(ra) # 80000cec <release>
}
    800048fc:	60e2                	ld	ra,24(sp)
    800048fe:	6442                	ld	s0,16(sp)
    80004900:	64a2                	ld	s1,8(sp)
    80004902:	6902                	ld	s2,0(sp)
    80004904:	6105                	addi	sp,sp,32
    80004906:	8082                	ret

0000000080004908 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004908:	1101                	addi	sp,sp,-32
    8000490a:	ec06                	sd	ra,24(sp)
    8000490c:	e822                	sd	s0,16(sp)
    8000490e:	e426                	sd	s1,8(sp)
    80004910:	e04a                	sd	s2,0(sp)
    80004912:	1000                	addi	s0,sp,32
    80004914:	84aa                	mv	s1,a0
    80004916:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004918:	00004597          	auipc	a1,0x4
    8000491c:	c6058593          	addi	a1,a1,-928 # 80008578 <etext+0x578>
    80004920:	0521                	addi	a0,a0,8
    80004922:	ffffc097          	auipc	ra,0xffffc
    80004926:	286080e7          	jalr	646(ra) # 80000ba8 <initlock>
  lk->name = name;
    8000492a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000492e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004932:	0204a423          	sw	zero,40(s1)
}
    80004936:	60e2                	ld	ra,24(sp)
    80004938:	6442                	ld	s0,16(sp)
    8000493a:	64a2                	ld	s1,8(sp)
    8000493c:	6902                	ld	s2,0(sp)
    8000493e:	6105                	addi	sp,sp,32
    80004940:	8082                	ret

0000000080004942 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004942:	1101                	addi	sp,sp,-32
    80004944:	ec06                	sd	ra,24(sp)
    80004946:	e822                	sd	s0,16(sp)
    80004948:	e426                	sd	s1,8(sp)
    8000494a:	e04a                	sd	s2,0(sp)
    8000494c:	1000                	addi	s0,sp,32
    8000494e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004950:	00850913          	addi	s2,a0,8
    80004954:	854a                	mv	a0,s2
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	2e2080e7          	jalr	738(ra) # 80000c38 <acquire>
  while (lk->locked) {
    8000495e:	409c                	lw	a5,0(s1)
    80004960:	cb89                	beqz	a5,80004972 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004962:	85ca                	mv	a1,s2
    80004964:	8526                	mv	a0,s1
    80004966:	ffffe097          	auipc	ra,0xffffe
    8000496a:	920080e7          	jalr	-1760(ra) # 80002286 <sleep>
  while (lk->locked) {
    8000496e:	409c                	lw	a5,0(s1)
    80004970:	fbed                	bnez	a5,80004962 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004972:	4785                	li	a5,1
    80004974:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004976:	ffffd097          	auipc	ra,0xffffd
    8000497a:	104080e7          	jalr	260(ra) # 80001a7a <myproc>
    8000497e:	591c                	lw	a5,48(a0)
    80004980:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004982:	854a                	mv	a0,s2
    80004984:	ffffc097          	auipc	ra,0xffffc
    80004988:	368080e7          	jalr	872(ra) # 80000cec <release>
}
    8000498c:	60e2                	ld	ra,24(sp)
    8000498e:	6442                	ld	s0,16(sp)
    80004990:	64a2                	ld	s1,8(sp)
    80004992:	6902                	ld	s2,0(sp)
    80004994:	6105                	addi	sp,sp,32
    80004996:	8082                	ret

0000000080004998 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004998:	1101                	addi	sp,sp,-32
    8000499a:	ec06                	sd	ra,24(sp)
    8000499c:	e822                	sd	s0,16(sp)
    8000499e:	e426                	sd	s1,8(sp)
    800049a0:	e04a                	sd	s2,0(sp)
    800049a2:	1000                	addi	s0,sp,32
    800049a4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049a6:	00850913          	addi	s2,a0,8
    800049aa:	854a                	mv	a0,s2
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	28c080e7          	jalr	652(ra) # 80000c38 <acquire>
  lk->locked = 0;
    800049b4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049b8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049bc:	8526                	mv	a0,s1
    800049be:	ffffe097          	auipc	ra,0xffffe
    800049c2:	92c080e7          	jalr	-1748(ra) # 800022ea <wakeup>
  release(&lk->lk);
    800049c6:	854a                	mv	a0,s2
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	324080e7          	jalr	804(ra) # 80000cec <release>
}
    800049d0:	60e2                	ld	ra,24(sp)
    800049d2:	6442                	ld	s0,16(sp)
    800049d4:	64a2                	ld	s1,8(sp)
    800049d6:	6902                	ld	s2,0(sp)
    800049d8:	6105                	addi	sp,sp,32
    800049da:	8082                	ret

00000000800049dc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049dc:	7179                	addi	sp,sp,-48
    800049de:	f406                	sd	ra,40(sp)
    800049e0:	f022                	sd	s0,32(sp)
    800049e2:	ec26                	sd	s1,24(sp)
    800049e4:	e84a                	sd	s2,16(sp)
    800049e6:	1800                	addi	s0,sp,48
    800049e8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049ea:	00850913          	addi	s2,a0,8
    800049ee:	854a                	mv	a0,s2
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	248080e7          	jalr	584(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049f8:	409c                	lw	a5,0(s1)
    800049fa:	ef91                	bnez	a5,80004a16 <holdingsleep+0x3a>
    800049fc:	4481                	li	s1,0
  release(&lk->lk);
    800049fe:	854a                	mv	a0,s2
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	2ec080e7          	jalr	748(ra) # 80000cec <release>
  return r;
}
    80004a08:	8526                	mv	a0,s1
    80004a0a:	70a2                	ld	ra,40(sp)
    80004a0c:	7402                	ld	s0,32(sp)
    80004a0e:	64e2                	ld	s1,24(sp)
    80004a10:	6942                	ld	s2,16(sp)
    80004a12:	6145                	addi	sp,sp,48
    80004a14:	8082                	ret
    80004a16:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a18:	0284a983          	lw	s3,40(s1)
    80004a1c:	ffffd097          	auipc	ra,0xffffd
    80004a20:	05e080e7          	jalr	94(ra) # 80001a7a <myproc>
    80004a24:	5904                	lw	s1,48(a0)
    80004a26:	413484b3          	sub	s1,s1,s3
    80004a2a:	0014b493          	seqz	s1,s1
    80004a2e:	69a2                	ld	s3,8(sp)
    80004a30:	b7f9                	j	800049fe <holdingsleep+0x22>

0000000080004a32 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a32:	1141                	addi	sp,sp,-16
    80004a34:	e406                	sd	ra,8(sp)
    80004a36:	e022                	sd	s0,0(sp)
    80004a38:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a3a:	00004597          	auipc	a1,0x4
    80004a3e:	b4e58593          	addi	a1,a1,-1202 # 80008588 <etext+0x588>
    80004a42:	00023517          	auipc	a0,0x23
    80004a46:	39e50513          	addi	a0,a0,926 # 80027de0 <ftable>
    80004a4a:	ffffc097          	auipc	ra,0xffffc
    80004a4e:	15e080e7          	jalr	350(ra) # 80000ba8 <initlock>
}
    80004a52:	60a2                	ld	ra,8(sp)
    80004a54:	6402                	ld	s0,0(sp)
    80004a56:	0141                	addi	sp,sp,16
    80004a58:	8082                	ret

0000000080004a5a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a5a:	1101                	addi	sp,sp,-32
    80004a5c:	ec06                	sd	ra,24(sp)
    80004a5e:	e822                	sd	s0,16(sp)
    80004a60:	e426                	sd	s1,8(sp)
    80004a62:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a64:	00023517          	auipc	a0,0x23
    80004a68:	37c50513          	addi	a0,a0,892 # 80027de0 <ftable>
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	1cc080e7          	jalr	460(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a74:	00023497          	auipc	s1,0x23
    80004a78:	38448493          	addi	s1,s1,900 # 80027df8 <ftable+0x18>
    80004a7c:	00024717          	auipc	a4,0x24
    80004a80:	31c70713          	addi	a4,a4,796 # 80028d98 <disk>
    if(f->ref == 0){
    80004a84:	40dc                	lw	a5,4(s1)
    80004a86:	cf99                	beqz	a5,80004aa4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a88:	02848493          	addi	s1,s1,40
    80004a8c:	fee49ce3          	bne	s1,a4,80004a84 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a90:	00023517          	auipc	a0,0x23
    80004a94:	35050513          	addi	a0,a0,848 # 80027de0 <ftable>
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	254080e7          	jalr	596(ra) # 80000cec <release>
  return 0;
    80004aa0:	4481                	li	s1,0
    80004aa2:	a819                	j	80004ab8 <filealloc+0x5e>
      f->ref = 1;
    80004aa4:	4785                	li	a5,1
    80004aa6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004aa8:	00023517          	auipc	a0,0x23
    80004aac:	33850513          	addi	a0,a0,824 # 80027de0 <ftable>
    80004ab0:	ffffc097          	auipc	ra,0xffffc
    80004ab4:	23c080e7          	jalr	572(ra) # 80000cec <release>
}
    80004ab8:	8526                	mv	a0,s1
    80004aba:	60e2                	ld	ra,24(sp)
    80004abc:	6442                	ld	s0,16(sp)
    80004abe:	64a2                	ld	s1,8(sp)
    80004ac0:	6105                	addi	sp,sp,32
    80004ac2:	8082                	ret

0000000080004ac4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ac4:	1101                	addi	sp,sp,-32
    80004ac6:	ec06                	sd	ra,24(sp)
    80004ac8:	e822                	sd	s0,16(sp)
    80004aca:	e426                	sd	s1,8(sp)
    80004acc:	1000                	addi	s0,sp,32
    80004ace:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ad0:	00023517          	auipc	a0,0x23
    80004ad4:	31050513          	addi	a0,a0,784 # 80027de0 <ftable>
    80004ad8:	ffffc097          	auipc	ra,0xffffc
    80004adc:	160080e7          	jalr	352(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004ae0:	40dc                	lw	a5,4(s1)
    80004ae2:	02f05263          	blez	a5,80004b06 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004ae6:	2785                	addiw	a5,a5,1
    80004ae8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004aea:	00023517          	auipc	a0,0x23
    80004aee:	2f650513          	addi	a0,a0,758 # 80027de0 <ftable>
    80004af2:	ffffc097          	auipc	ra,0xffffc
    80004af6:	1fa080e7          	jalr	506(ra) # 80000cec <release>
  return f;
}
    80004afa:	8526                	mv	a0,s1
    80004afc:	60e2                	ld	ra,24(sp)
    80004afe:	6442                	ld	s0,16(sp)
    80004b00:	64a2                	ld	s1,8(sp)
    80004b02:	6105                	addi	sp,sp,32
    80004b04:	8082                	ret
    panic("filedup");
    80004b06:	00004517          	auipc	a0,0x4
    80004b0a:	a8a50513          	addi	a0,a0,-1398 # 80008590 <etext+0x590>
    80004b0e:	ffffc097          	auipc	ra,0xffffc
    80004b12:	a52080e7          	jalr	-1454(ra) # 80000560 <panic>

0000000080004b16 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b16:	7139                	addi	sp,sp,-64
    80004b18:	fc06                	sd	ra,56(sp)
    80004b1a:	f822                	sd	s0,48(sp)
    80004b1c:	f426                	sd	s1,40(sp)
    80004b1e:	0080                	addi	s0,sp,64
    80004b20:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b22:	00023517          	auipc	a0,0x23
    80004b26:	2be50513          	addi	a0,a0,702 # 80027de0 <ftable>
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	10e080e7          	jalr	270(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004b32:	40dc                	lw	a5,4(s1)
    80004b34:	04f05c63          	blez	a5,80004b8c <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004b38:	37fd                	addiw	a5,a5,-1
    80004b3a:	0007871b          	sext.w	a4,a5
    80004b3e:	c0dc                	sw	a5,4(s1)
    80004b40:	06e04263          	bgtz	a4,80004ba4 <fileclose+0x8e>
    80004b44:	f04a                	sd	s2,32(sp)
    80004b46:	ec4e                	sd	s3,24(sp)
    80004b48:	e852                	sd	s4,16(sp)
    80004b4a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b4c:	0004a903          	lw	s2,0(s1)
    80004b50:	0094ca83          	lbu	s5,9(s1)
    80004b54:	0104ba03          	ld	s4,16(s1)
    80004b58:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b5c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b60:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b64:	00023517          	auipc	a0,0x23
    80004b68:	27c50513          	addi	a0,a0,636 # 80027de0 <ftable>
    80004b6c:	ffffc097          	auipc	ra,0xffffc
    80004b70:	180080e7          	jalr	384(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    80004b74:	4785                	li	a5,1
    80004b76:	04f90463          	beq	s2,a5,80004bbe <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b7a:	3979                	addiw	s2,s2,-2
    80004b7c:	4785                	li	a5,1
    80004b7e:	0527fb63          	bgeu	a5,s2,80004bd4 <fileclose+0xbe>
    80004b82:	7902                	ld	s2,32(sp)
    80004b84:	69e2                	ld	s3,24(sp)
    80004b86:	6a42                	ld	s4,16(sp)
    80004b88:	6aa2                	ld	s5,8(sp)
    80004b8a:	a02d                	j	80004bb4 <fileclose+0x9e>
    80004b8c:	f04a                	sd	s2,32(sp)
    80004b8e:	ec4e                	sd	s3,24(sp)
    80004b90:	e852                	sd	s4,16(sp)
    80004b92:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004b94:	00004517          	auipc	a0,0x4
    80004b98:	a0450513          	addi	a0,a0,-1532 # 80008598 <etext+0x598>
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	9c4080e7          	jalr	-1596(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004ba4:	00023517          	auipc	a0,0x23
    80004ba8:	23c50513          	addi	a0,a0,572 # 80027de0 <ftable>
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	140080e7          	jalr	320(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004bb4:	70e2                	ld	ra,56(sp)
    80004bb6:	7442                	ld	s0,48(sp)
    80004bb8:	74a2                	ld	s1,40(sp)
    80004bba:	6121                	addi	sp,sp,64
    80004bbc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004bbe:	85d6                	mv	a1,s5
    80004bc0:	8552                	mv	a0,s4
    80004bc2:	00000097          	auipc	ra,0x0
    80004bc6:	3a2080e7          	jalr	930(ra) # 80004f64 <pipeclose>
    80004bca:	7902                	ld	s2,32(sp)
    80004bcc:	69e2                	ld	s3,24(sp)
    80004bce:	6a42                	ld	s4,16(sp)
    80004bd0:	6aa2                	ld	s5,8(sp)
    80004bd2:	b7cd                	j	80004bb4 <fileclose+0x9e>
    begin_op();
    80004bd4:	00000097          	auipc	ra,0x0
    80004bd8:	a78080e7          	jalr	-1416(ra) # 8000464c <begin_op>
    iput(ff.ip);
    80004bdc:	854e                	mv	a0,s3
    80004bde:	fffff097          	auipc	ra,0xfffff
    80004be2:	25e080e7          	jalr	606(ra) # 80003e3c <iput>
    end_op();
    80004be6:	00000097          	auipc	ra,0x0
    80004bea:	ae0080e7          	jalr	-1312(ra) # 800046c6 <end_op>
    80004bee:	7902                	ld	s2,32(sp)
    80004bf0:	69e2                	ld	s3,24(sp)
    80004bf2:	6a42                	ld	s4,16(sp)
    80004bf4:	6aa2                	ld	s5,8(sp)
    80004bf6:	bf7d                	j	80004bb4 <fileclose+0x9e>

0000000080004bf8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004bf8:	715d                	addi	sp,sp,-80
    80004bfa:	e486                	sd	ra,72(sp)
    80004bfc:	e0a2                	sd	s0,64(sp)
    80004bfe:	fc26                	sd	s1,56(sp)
    80004c00:	f44e                	sd	s3,40(sp)
    80004c02:	0880                	addi	s0,sp,80
    80004c04:	84aa                	mv	s1,a0
    80004c06:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	e72080e7          	jalr	-398(ra) # 80001a7a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c10:	409c                	lw	a5,0(s1)
    80004c12:	37f9                	addiw	a5,a5,-2
    80004c14:	4705                	li	a4,1
    80004c16:	04f76863          	bltu	a4,a5,80004c66 <filestat+0x6e>
    80004c1a:	f84a                	sd	s2,48(sp)
    80004c1c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c1e:	6c88                	ld	a0,24(s1)
    80004c20:	fffff097          	auipc	ra,0xfffff
    80004c24:	05e080e7          	jalr	94(ra) # 80003c7e <ilock>
    stati(f->ip, &st);
    80004c28:	fb840593          	addi	a1,s0,-72
    80004c2c:	6c88                	ld	a0,24(s1)
    80004c2e:	fffff097          	auipc	ra,0xfffff
    80004c32:	2de080e7          	jalr	734(ra) # 80003f0c <stati>
    iunlock(f->ip);
    80004c36:	6c88                	ld	a0,24(s1)
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	10c080e7          	jalr	268(ra) # 80003d44 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c40:	46e1                	li	a3,24
    80004c42:	fb840613          	addi	a2,s0,-72
    80004c46:	85ce                	mv	a1,s3
    80004c48:	05093503          	ld	a0,80(s2)
    80004c4c:	ffffd097          	auipc	ra,0xffffd
    80004c50:	a96080e7          	jalr	-1386(ra) # 800016e2 <copyout>
    80004c54:	41f5551b          	sraiw	a0,a0,0x1f
    80004c58:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004c5a:	60a6                	ld	ra,72(sp)
    80004c5c:	6406                	ld	s0,64(sp)
    80004c5e:	74e2                	ld	s1,56(sp)
    80004c60:	79a2                	ld	s3,40(sp)
    80004c62:	6161                	addi	sp,sp,80
    80004c64:	8082                	ret
  return -1;
    80004c66:	557d                	li	a0,-1
    80004c68:	bfcd                	j	80004c5a <filestat+0x62>

0000000080004c6a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c6a:	7179                	addi	sp,sp,-48
    80004c6c:	f406                	sd	ra,40(sp)
    80004c6e:	f022                	sd	s0,32(sp)
    80004c70:	e84a                	sd	s2,16(sp)
    80004c72:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c74:	00854783          	lbu	a5,8(a0)
    80004c78:	cbc5                	beqz	a5,80004d28 <fileread+0xbe>
    80004c7a:	ec26                	sd	s1,24(sp)
    80004c7c:	e44e                	sd	s3,8(sp)
    80004c7e:	84aa                	mv	s1,a0
    80004c80:	89ae                	mv	s3,a1
    80004c82:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c84:	411c                	lw	a5,0(a0)
    80004c86:	4705                	li	a4,1
    80004c88:	04e78963          	beq	a5,a4,80004cda <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c8c:	470d                	li	a4,3
    80004c8e:	04e78f63          	beq	a5,a4,80004cec <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c92:	4709                	li	a4,2
    80004c94:	08e79263          	bne	a5,a4,80004d18 <fileread+0xae>
    ilock(f->ip);
    80004c98:	6d08                	ld	a0,24(a0)
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	fe4080e7          	jalr	-28(ra) # 80003c7e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ca2:	874a                	mv	a4,s2
    80004ca4:	5094                	lw	a3,32(s1)
    80004ca6:	864e                	mv	a2,s3
    80004ca8:	4585                	li	a1,1
    80004caa:	6c88                	ld	a0,24(s1)
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	28a080e7          	jalr	650(ra) # 80003f36 <readi>
    80004cb4:	892a                	mv	s2,a0
    80004cb6:	00a05563          	blez	a0,80004cc0 <fileread+0x56>
      f->off += r;
    80004cba:	509c                	lw	a5,32(s1)
    80004cbc:	9fa9                	addw	a5,a5,a0
    80004cbe:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004cc0:	6c88                	ld	a0,24(s1)
    80004cc2:	fffff097          	auipc	ra,0xfffff
    80004cc6:	082080e7          	jalr	130(ra) # 80003d44 <iunlock>
    80004cca:	64e2                	ld	s1,24(sp)
    80004ccc:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004cce:	854a                	mv	a0,s2
    80004cd0:	70a2                	ld	ra,40(sp)
    80004cd2:	7402                	ld	s0,32(sp)
    80004cd4:	6942                	ld	s2,16(sp)
    80004cd6:	6145                	addi	sp,sp,48
    80004cd8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cda:	6908                	ld	a0,16(a0)
    80004cdc:	00000097          	auipc	ra,0x0
    80004ce0:	400080e7          	jalr	1024(ra) # 800050dc <piperead>
    80004ce4:	892a                	mv	s2,a0
    80004ce6:	64e2                	ld	s1,24(sp)
    80004ce8:	69a2                	ld	s3,8(sp)
    80004cea:	b7d5                	j	80004cce <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004cec:	02451783          	lh	a5,36(a0)
    80004cf0:	03079693          	slli	a3,a5,0x30
    80004cf4:	92c1                	srli	a3,a3,0x30
    80004cf6:	4725                	li	a4,9
    80004cf8:	02d76a63          	bltu	a4,a3,80004d2c <fileread+0xc2>
    80004cfc:	0792                	slli	a5,a5,0x4
    80004cfe:	00023717          	auipc	a4,0x23
    80004d02:	04270713          	addi	a4,a4,66 # 80027d40 <devsw>
    80004d06:	97ba                	add	a5,a5,a4
    80004d08:	639c                	ld	a5,0(a5)
    80004d0a:	c78d                	beqz	a5,80004d34 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004d0c:	4505                	li	a0,1
    80004d0e:	9782                	jalr	a5
    80004d10:	892a                	mv	s2,a0
    80004d12:	64e2                	ld	s1,24(sp)
    80004d14:	69a2                	ld	s3,8(sp)
    80004d16:	bf65                	j	80004cce <fileread+0x64>
    panic("fileread");
    80004d18:	00004517          	auipc	a0,0x4
    80004d1c:	89050513          	addi	a0,a0,-1904 # 800085a8 <etext+0x5a8>
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	840080e7          	jalr	-1984(ra) # 80000560 <panic>
    return -1;
    80004d28:	597d                	li	s2,-1
    80004d2a:	b755                	j	80004cce <fileread+0x64>
      return -1;
    80004d2c:	597d                	li	s2,-1
    80004d2e:	64e2                	ld	s1,24(sp)
    80004d30:	69a2                	ld	s3,8(sp)
    80004d32:	bf71                	j	80004cce <fileread+0x64>
    80004d34:	597d                	li	s2,-1
    80004d36:	64e2                	ld	s1,24(sp)
    80004d38:	69a2                	ld	s3,8(sp)
    80004d3a:	bf51                	j	80004cce <fileread+0x64>

0000000080004d3c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004d3c:	00954783          	lbu	a5,9(a0)
    80004d40:	12078963          	beqz	a5,80004e72 <filewrite+0x136>
{
    80004d44:	715d                	addi	sp,sp,-80
    80004d46:	e486                	sd	ra,72(sp)
    80004d48:	e0a2                	sd	s0,64(sp)
    80004d4a:	f84a                	sd	s2,48(sp)
    80004d4c:	f052                	sd	s4,32(sp)
    80004d4e:	e85a                	sd	s6,16(sp)
    80004d50:	0880                	addi	s0,sp,80
    80004d52:	892a                	mv	s2,a0
    80004d54:	8b2e                	mv	s6,a1
    80004d56:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d58:	411c                	lw	a5,0(a0)
    80004d5a:	4705                	li	a4,1
    80004d5c:	02e78763          	beq	a5,a4,80004d8a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d60:	470d                	li	a4,3
    80004d62:	02e78a63          	beq	a5,a4,80004d96 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d66:	4709                	li	a4,2
    80004d68:	0ee79863          	bne	a5,a4,80004e58 <filewrite+0x11c>
    80004d6c:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d6e:	0cc05463          	blez	a2,80004e36 <filewrite+0xfa>
    80004d72:	fc26                	sd	s1,56(sp)
    80004d74:	ec56                	sd	s5,24(sp)
    80004d76:	e45e                	sd	s7,8(sp)
    80004d78:	e062                	sd	s8,0(sp)
    int i = 0;
    80004d7a:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004d7c:	6b85                	lui	s7,0x1
    80004d7e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004d82:	6c05                	lui	s8,0x1
    80004d84:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004d88:	a851                	j	80004e1c <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004d8a:	6908                	ld	a0,16(a0)
    80004d8c:	00000097          	auipc	ra,0x0
    80004d90:	248080e7          	jalr	584(ra) # 80004fd4 <pipewrite>
    80004d94:	a85d                	j	80004e4a <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d96:	02451783          	lh	a5,36(a0)
    80004d9a:	03079693          	slli	a3,a5,0x30
    80004d9e:	92c1                	srli	a3,a3,0x30
    80004da0:	4725                	li	a4,9
    80004da2:	0cd76a63          	bltu	a4,a3,80004e76 <filewrite+0x13a>
    80004da6:	0792                	slli	a5,a5,0x4
    80004da8:	00023717          	auipc	a4,0x23
    80004dac:	f9870713          	addi	a4,a4,-104 # 80027d40 <devsw>
    80004db0:	97ba                	add	a5,a5,a4
    80004db2:	679c                	ld	a5,8(a5)
    80004db4:	c3f9                	beqz	a5,80004e7a <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004db6:	4505                	li	a0,1
    80004db8:	9782                	jalr	a5
    80004dba:	a841                	j	80004e4a <filewrite+0x10e>
      if(n1 > max)
    80004dbc:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004dc0:	00000097          	auipc	ra,0x0
    80004dc4:	88c080e7          	jalr	-1908(ra) # 8000464c <begin_op>
      ilock(f->ip);
    80004dc8:	01893503          	ld	a0,24(s2)
    80004dcc:	fffff097          	auipc	ra,0xfffff
    80004dd0:	eb2080e7          	jalr	-334(ra) # 80003c7e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004dd4:	8756                	mv	a4,s5
    80004dd6:	02092683          	lw	a3,32(s2)
    80004dda:	01698633          	add	a2,s3,s6
    80004dde:	4585                	li	a1,1
    80004de0:	01893503          	ld	a0,24(s2)
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	262080e7          	jalr	610(ra) # 80004046 <writei>
    80004dec:	84aa                	mv	s1,a0
    80004dee:	00a05763          	blez	a0,80004dfc <filewrite+0xc0>
        f->off += r;
    80004df2:	02092783          	lw	a5,32(s2)
    80004df6:	9fa9                	addw	a5,a5,a0
    80004df8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004dfc:	01893503          	ld	a0,24(s2)
    80004e00:	fffff097          	auipc	ra,0xfffff
    80004e04:	f44080e7          	jalr	-188(ra) # 80003d44 <iunlock>
      end_op();
    80004e08:	00000097          	auipc	ra,0x0
    80004e0c:	8be080e7          	jalr	-1858(ra) # 800046c6 <end_op>

      if(r != n1){
    80004e10:	029a9563          	bne	s5,s1,80004e3a <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004e14:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e18:	0149da63          	bge	s3,s4,80004e2c <filewrite+0xf0>
      int n1 = n - i;
    80004e1c:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004e20:	0004879b          	sext.w	a5,s1
    80004e24:	f8fbdce3          	bge	s7,a5,80004dbc <filewrite+0x80>
    80004e28:	84e2                	mv	s1,s8
    80004e2a:	bf49                	j	80004dbc <filewrite+0x80>
    80004e2c:	74e2                	ld	s1,56(sp)
    80004e2e:	6ae2                	ld	s5,24(sp)
    80004e30:	6ba2                	ld	s7,8(sp)
    80004e32:	6c02                	ld	s8,0(sp)
    80004e34:	a039                	j	80004e42 <filewrite+0x106>
    int i = 0;
    80004e36:	4981                	li	s3,0
    80004e38:	a029                	j	80004e42 <filewrite+0x106>
    80004e3a:	74e2                	ld	s1,56(sp)
    80004e3c:	6ae2                	ld	s5,24(sp)
    80004e3e:	6ba2                	ld	s7,8(sp)
    80004e40:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004e42:	033a1e63          	bne	s4,s3,80004e7e <filewrite+0x142>
    80004e46:	8552                	mv	a0,s4
    80004e48:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e4a:	60a6                	ld	ra,72(sp)
    80004e4c:	6406                	ld	s0,64(sp)
    80004e4e:	7942                	ld	s2,48(sp)
    80004e50:	7a02                	ld	s4,32(sp)
    80004e52:	6b42                	ld	s6,16(sp)
    80004e54:	6161                	addi	sp,sp,80
    80004e56:	8082                	ret
    80004e58:	fc26                	sd	s1,56(sp)
    80004e5a:	f44e                	sd	s3,40(sp)
    80004e5c:	ec56                	sd	s5,24(sp)
    80004e5e:	e45e                	sd	s7,8(sp)
    80004e60:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004e62:	00003517          	auipc	a0,0x3
    80004e66:	75650513          	addi	a0,a0,1878 # 800085b8 <etext+0x5b8>
    80004e6a:	ffffb097          	auipc	ra,0xffffb
    80004e6e:	6f6080e7          	jalr	1782(ra) # 80000560 <panic>
    return -1;
    80004e72:	557d                	li	a0,-1
}
    80004e74:	8082                	ret
      return -1;
    80004e76:	557d                	li	a0,-1
    80004e78:	bfc9                	j	80004e4a <filewrite+0x10e>
    80004e7a:	557d                	li	a0,-1
    80004e7c:	b7f9                	j	80004e4a <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004e7e:	557d                	li	a0,-1
    80004e80:	79a2                	ld	s3,40(sp)
    80004e82:	b7e1                	j	80004e4a <filewrite+0x10e>

0000000080004e84 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e84:	7179                	addi	sp,sp,-48
    80004e86:	f406                	sd	ra,40(sp)
    80004e88:	f022                	sd	s0,32(sp)
    80004e8a:	ec26                	sd	s1,24(sp)
    80004e8c:	e052                	sd	s4,0(sp)
    80004e8e:	1800                	addi	s0,sp,48
    80004e90:	84aa                	mv	s1,a0
    80004e92:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e94:	0005b023          	sd	zero,0(a1)
    80004e98:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e9c:	00000097          	auipc	ra,0x0
    80004ea0:	bbe080e7          	jalr	-1090(ra) # 80004a5a <filealloc>
    80004ea4:	e088                	sd	a0,0(s1)
    80004ea6:	cd49                	beqz	a0,80004f40 <pipealloc+0xbc>
    80004ea8:	00000097          	auipc	ra,0x0
    80004eac:	bb2080e7          	jalr	-1102(ra) # 80004a5a <filealloc>
    80004eb0:	00aa3023          	sd	a0,0(s4)
    80004eb4:	c141                	beqz	a0,80004f34 <pipealloc+0xb0>
    80004eb6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004eb8:	ffffc097          	auipc	ra,0xffffc
    80004ebc:	c90080e7          	jalr	-880(ra) # 80000b48 <kalloc>
    80004ec0:	892a                	mv	s2,a0
    80004ec2:	c13d                	beqz	a0,80004f28 <pipealloc+0xa4>
    80004ec4:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004ec6:	4985                	li	s3,1
    80004ec8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ecc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ed0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ed4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ed8:	00003597          	auipc	a1,0x3
    80004edc:	6f058593          	addi	a1,a1,1776 # 800085c8 <etext+0x5c8>
    80004ee0:	ffffc097          	auipc	ra,0xffffc
    80004ee4:	cc8080e7          	jalr	-824(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004ee8:	609c                	ld	a5,0(s1)
    80004eea:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004eee:	609c                	ld	a5,0(s1)
    80004ef0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ef4:	609c                	ld	a5,0(s1)
    80004ef6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004efa:	609c                	ld	a5,0(s1)
    80004efc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f00:	000a3783          	ld	a5,0(s4)
    80004f04:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f08:	000a3783          	ld	a5,0(s4)
    80004f0c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f10:	000a3783          	ld	a5,0(s4)
    80004f14:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f18:	000a3783          	ld	a5,0(s4)
    80004f1c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f20:	4501                	li	a0,0
    80004f22:	6942                	ld	s2,16(sp)
    80004f24:	69a2                	ld	s3,8(sp)
    80004f26:	a03d                	j	80004f54 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f28:	6088                	ld	a0,0(s1)
    80004f2a:	c119                	beqz	a0,80004f30 <pipealloc+0xac>
    80004f2c:	6942                	ld	s2,16(sp)
    80004f2e:	a029                	j	80004f38 <pipealloc+0xb4>
    80004f30:	6942                	ld	s2,16(sp)
    80004f32:	a039                	j	80004f40 <pipealloc+0xbc>
    80004f34:	6088                	ld	a0,0(s1)
    80004f36:	c50d                	beqz	a0,80004f60 <pipealloc+0xdc>
    fileclose(*f0);
    80004f38:	00000097          	auipc	ra,0x0
    80004f3c:	bde080e7          	jalr	-1058(ra) # 80004b16 <fileclose>
  if(*f1)
    80004f40:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f44:	557d                	li	a0,-1
  if(*f1)
    80004f46:	c799                	beqz	a5,80004f54 <pipealloc+0xd0>
    fileclose(*f1);
    80004f48:	853e                	mv	a0,a5
    80004f4a:	00000097          	auipc	ra,0x0
    80004f4e:	bcc080e7          	jalr	-1076(ra) # 80004b16 <fileclose>
  return -1;
    80004f52:	557d                	li	a0,-1
}
    80004f54:	70a2                	ld	ra,40(sp)
    80004f56:	7402                	ld	s0,32(sp)
    80004f58:	64e2                	ld	s1,24(sp)
    80004f5a:	6a02                	ld	s4,0(sp)
    80004f5c:	6145                	addi	sp,sp,48
    80004f5e:	8082                	ret
  return -1;
    80004f60:	557d                	li	a0,-1
    80004f62:	bfcd                	j	80004f54 <pipealloc+0xd0>

0000000080004f64 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f64:	1101                	addi	sp,sp,-32
    80004f66:	ec06                	sd	ra,24(sp)
    80004f68:	e822                	sd	s0,16(sp)
    80004f6a:	e426                	sd	s1,8(sp)
    80004f6c:	e04a                	sd	s2,0(sp)
    80004f6e:	1000                	addi	s0,sp,32
    80004f70:	84aa                	mv	s1,a0
    80004f72:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	cc4080e7          	jalr	-828(ra) # 80000c38 <acquire>
  if(writable){
    80004f7c:	02090d63          	beqz	s2,80004fb6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f80:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f84:	21848513          	addi	a0,s1,536
    80004f88:	ffffd097          	auipc	ra,0xffffd
    80004f8c:	362080e7          	jalr	866(ra) # 800022ea <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f90:	2204b783          	ld	a5,544(s1)
    80004f94:	eb95                	bnez	a5,80004fc8 <pipeclose+0x64>
    release(&pi->lock);
    80004f96:	8526                	mv	a0,s1
    80004f98:	ffffc097          	auipc	ra,0xffffc
    80004f9c:	d54080e7          	jalr	-684(ra) # 80000cec <release>
    kfree((char*)pi);
    80004fa0:	8526                	mv	a0,s1
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	aa8080e7          	jalr	-1368(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004faa:	60e2                	ld	ra,24(sp)
    80004fac:	6442                	ld	s0,16(sp)
    80004fae:	64a2                	ld	s1,8(sp)
    80004fb0:	6902                	ld	s2,0(sp)
    80004fb2:	6105                	addi	sp,sp,32
    80004fb4:	8082                	ret
    pi->readopen = 0;
    80004fb6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fba:	21c48513          	addi	a0,s1,540
    80004fbe:	ffffd097          	auipc	ra,0xffffd
    80004fc2:	32c080e7          	jalr	812(ra) # 800022ea <wakeup>
    80004fc6:	b7e9                	j	80004f90 <pipeclose+0x2c>
    release(&pi->lock);
    80004fc8:	8526                	mv	a0,s1
    80004fca:	ffffc097          	auipc	ra,0xffffc
    80004fce:	d22080e7          	jalr	-734(ra) # 80000cec <release>
}
    80004fd2:	bfe1                	j	80004faa <pipeclose+0x46>

0000000080004fd4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004fd4:	711d                	addi	sp,sp,-96
    80004fd6:	ec86                	sd	ra,88(sp)
    80004fd8:	e8a2                	sd	s0,80(sp)
    80004fda:	e4a6                	sd	s1,72(sp)
    80004fdc:	e0ca                	sd	s2,64(sp)
    80004fde:	fc4e                	sd	s3,56(sp)
    80004fe0:	f852                	sd	s4,48(sp)
    80004fe2:	f456                	sd	s5,40(sp)
    80004fe4:	1080                	addi	s0,sp,96
    80004fe6:	84aa                	mv	s1,a0
    80004fe8:	8aae                	mv	s5,a1
    80004fea:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	a8e080e7          	jalr	-1394(ra) # 80001a7a <myproc>
    80004ff4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	ffffc097          	auipc	ra,0xffffc
    80004ffc:	c40080e7          	jalr	-960(ra) # 80000c38 <acquire>
  while(i < n){
    80005000:	0d405863          	blez	s4,800050d0 <pipewrite+0xfc>
    80005004:	f05a                	sd	s6,32(sp)
    80005006:	ec5e                	sd	s7,24(sp)
    80005008:	e862                	sd	s8,16(sp)
  int i = 0;
    8000500a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000500c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000500e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005012:	21c48b93          	addi	s7,s1,540
    80005016:	a089                	j	80005058 <pipewrite+0x84>
      release(&pi->lock);
    80005018:	8526                	mv	a0,s1
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	cd2080e7          	jalr	-814(ra) # 80000cec <release>
      return -1;
    80005022:	597d                	li	s2,-1
    80005024:	7b02                	ld	s6,32(sp)
    80005026:	6be2                	ld	s7,24(sp)
    80005028:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000502a:	854a                	mv	a0,s2
    8000502c:	60e6                	ld	ra,88(sp)
    8000502e:	6446                	ld	s0,80(sp)
    80005030:	64a6                	ld	s1,72(sp)
    80005032:	6906                	ld	s2,64(sp)
    80005034:	79e2                	ld	s3,56(sp)
    80005036:	7a42                	ld	s4,48(sp)
    80005038:	7aa2                	ld	s5,40(sp)
    8000503a:	6125                	addi	sp,sp,96
    8000503c:	8082                	ret
      wakeup(&pi->nread);
    8000503e:	8562                	mv	a0,s8
    80005040:	ffffd097          	auipc	ra,0xffffd
    80005044:	2aa080e7          	jalr	682(ra) # 800022ea <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005048:	85a6                	mv	a1,s1
    8000504a:	855e                	mv	a0,s7
    8000504c:	ffffd097          	auipc	ra,0xffffd
    80005050:	23a080e7          	jalr	570(ra) # 80002286 <sleep>
  while(i < n){
    80005054:	05495f63          	bge	s2,s4,800050b2 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80005058:	2204a783          	lw	a5,544(s1)
    8000505c:	dfd5                	beqz	a5,80005018 <pipewrite+0x44>
    8000505e:	854e                	mv	a0,s3
    80005060:	ffffd097          	auipc	ra,0xffffd
    80005064:	4da080e7          	jalr	1242(ra) # 8000253a <killed>
    80005068:	f945                	bnez	a0,80005018 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000506a:	2184a783          	lw	a5,536(s1)
    8000506e:	21c4a703          	lw	a4,540(s1)
    80005072:	2007879b          	addiw	a5,a5,512
    80005076:	fcf704e3          	beq	a4,a5,8000503e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000507a:	4685                	li	a3,1
    8000507c:	01590633          	add	a2,s2,s5
    80005080:	faf40593          	addi	a1,s0,-81
    80005084:	0509b503          	ld	a0,80(s3)
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	6e6080e7          	jalr	1766(ra) # 8000176e <copyin>
    80005090:	05650263          	beq	a0,s6,800050d4 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005094:	21c4a783          	lw	a5,540(s1)
    80005098:	0017871b          	addiw	a4,a5,1
    8000509c:	20e4ae23          	sw	a4,540(s1)
    800050a0:	1ff7f793          	andi	a5,a5,511
    800050a4:	97a6                	add	a5,a5,s1
    800050a6:	faf44703          	lbu	a4,-81(s0)
    800050aa:	00e78c23          	sb	a4,24(a5)
      i++;
    800050ae:	2905                	addiw	s2,s2,1
    800050b0:	b755                	j	80005054 <pipewrite+0x80>
    800050b2:	7b02                	ld	s6,32(sp)
    800050b4:	6be2                	ld	s7,24(sp)
    800050b6:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800050b8:	21848513          	addi	a0,s1,536
    800050bc:	ffffd097          	auipc	ra,0xffffd
    800050c0:	22e080e7          	jalr	558(ra) # 800022ea <wakeup>
  release(&pi->lock);
    800050c4:	8526                	mv	a0,s1
    800050c6:	ffffc097          	auipc	ra,0xffffc
    800050ca:	c26080e7          	jalr	-986(ra) # 80000cec <release>
  return i;
    800050ce:	bfb1                	j	8000502a <pipewrite+0x56>
  int i = 0;
    800050d0:	4901                	li	s2,0
    800050d2:	b7dd                	j	800050b8 <pipewrite+0xe4>
    800050d4:	7b02                	ld	s6,32(sp)
    800050d6:	6be2                	ld	s7,24(sp)
    800050d8:	6c42                	ld	s8,16(sp)
    800050da:	bff9                	j	800050b8 <pipewrite+0xe4>

00000000800050dc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800050dc:	715d                	addi	sp,sp,-80
    800050de:	e486                	sd	ra,72(sp)
    800050e0:	e0a2                	sd	s0,64(sp)
    800050e2:	fc26                	sd	s1,56(sp)
    800050e4:	f84a                	sd	s2,48(sp)
    800050e6:	f44e                	sd	s3,40(sp)
    800050e8:	f052                	sd	s4,32(sp)
    800050ea:	ec56                	sd	s5,24(sp)
    800050ec:	0880                	addi	s0,sp,80
    800050ee:	84aa                	mv	s1,a0
    800050f0:	892e                	mv	s2,a1
    800050f2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050f4:	ffffd097          	auipc	ra,0xffffd
    800050f8:	986080e7          	jalr	-1658(ra) # 80001a7a <myproc>
    800050fc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050fe:	8526                	mv	a0,s1
    80005100:	ffffc097          	auipc	ra,0xffffc
    80005104:	b38080e7          	jalr	-1224(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005108:	2184a703          	lw	a4,536(s1)
    8000510c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005110:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005114:	02f71963          	bne	a4,a5,80005146 <piperead+0x6a>
    80005118:	2244a783          	lw	a5,548(s1)
    8000511c:	cf95                	beqz	a5,80005158 <piperead+0x7c>
    if(killed(pr)){
    8000511e:	8552                	mv	a0,s4
    80005120:	ffffd097          	auipc	ra,0xffffd
    80005124:	41a080e7          	jalr	1050(ra) # 8000253a <killed>
    80005128:	e10d                	bnez	a0,8000514a <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000512a:	85a6                	mv	a1,s1
    8000512c:	854e                	mv	a0,s3
    8000512e:	ffffd097          	auipc	ra,0xffffd
    80005132:	158080e7          	jalr	344(ra) # 80002286 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005136:	2184a703          	lw	a4,536(s1)
    8000513a:	21c4a783          	lw	a5,540(s1)
    8000513e:	fcf70de3          	beq	a4,a5,80005118 <piperead+0x3c>
    80005142:	e85a                	sd	s6,16(sp)
    80005144:	a819                	j	8000515a <piperead+0x7e>
    80005146:	e85a                	sd	s6,16(sp)
    80005148:	a809                	j	8000515a <piperead+0x7e>
      release(&pi->lock);
    8000514a:	8526                	mv	a0,s1
    8000514c:	ffffc097          	auipc	ra,0xffffc
    80005150:	ba0080e7          	jalr	-1120(ra) # 80000cec <release>
      return -1;
    80005154:	59fd                	li	s3,-1
    80005156:	a0a5                	j	800051be <piperead+0xe2>
    80005158:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000515a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000515c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000515e:	05505463          	blez	s5,800051a6 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80005162:	2184a783          	lw	a5,536(s1)
    80005166:	21c4a703          	lw	a4,540(s1)
    8000516a:	02f70e63          	beq	a4,a5,800051a6 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000516e:	0017871b          	addiw	a4,a5,1
    80005172:	20e4ac23          	sw	a4,536(s1)
    80005176:	1ff7f793          	andi	a5,a5,511
    8000517a:	97a6                	add	a5,a5,s1
    8000517c:	0187c783          	lbu	a5,24(a5)
    80005180:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005184:	4685                	li	a3,1
    80005186:	fbf40613          	addi	a2,s0,-65
    8000518a:	85ca                	mv	a1,s2
    8000518c:	050a3503          	ld	a0,80(s4)
    80005190:	ffffc097          	auipc	ra,0xffffc
    80005194:	552080e7          	jalr	1362(ra) # 800016e2 <copyout>
    80005198:	01650763          	beq	a0,s6,800051a6 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000519c:	2985                	addiw	s3,s3,1
    8000519e:	0905                	addi	s2,s2,1
    800051a0:	fd3a91e3          	bne	s5,s3,80005162 <piperead+0x86>
    800051a4:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051a6:	21c48513          	addi	a0,s1,540
    800051aa:	ffffd097          	auipc	ra,0xffffd
    800051ae:	140080e7          	jalr	320(ra) # 800022ea <wakeup>
  release(&pi->lock);
    800051b2:	8526                	mv	a0,s1
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	b38080e7          	jalr	-1224(ra) # 80000cec <release>
    800051bc:	6b42                	ld	s6,16(sp)
  return i;
}
    800051be:	854e                	mv	a0,s3
    800051c0:	60a6                	ld	ra,72(sp)
    800051c2:	6406                	ld	s0,64(sp)
    800051c4:	74e2                	ld	s1,56(sp)
    800051c6:	7942                	ld	s2,48(sp)
    800051c8:	79a2                	ld	s3,40(sp)
    800051ca:	7a02                	ld	s4,32(sp)
    800051cc:	6ae2                	ld	s5,24(sp)
    800051ce:	6161                	addi	sp,sp,80
    800051d0:	8082                	ret

00000000800051d2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800051d2:	1141                	addi	sp,sp,-16
    800051d4:	e422                	sd	s0,8(sp)
    800051d6:	0800                	addi	s0,sp,16
    800051d8:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800051da:	8905                	andi	a0,a0,1
    800051dc:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    800051de:	8b89                	andi	a5,a5,2
    800051e0:	c399                	beqz	a5,800051e6 <flags2perm+0x14>
    perm |= PTE_W;
    800051e2:	00456513          	ori	a0,a0,4
  return perm;
}
    800051e6:	6422                	ld	s0,8(sp)
    800051e8:	0141                	addi	sp,sp,16
    800051ea:	8082                	ret

00000000800051ec <exec>:

int exec(char *path, char **argv)
{
    800051ec:	df010113          	addi	sp,sp,-528
    800051f0:	20113423          	sd	ra,520(sp)
    800051f4:	20813023          	sd	s0,512(sp)
    800051f8:	ffa6                	sd	s1,504(sp)
    800051fa:	fbca                	sd	s2,496(sp)
    800051fc:	0c00                	addi	s0,sp,528
    800051fe:	892a                	mv	s2,a0
    80005200:	dea43c23          	sd	a0,-520(s0)
    80005204:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005208:	ffffd097          	auipc	ra,0xffffd
    8000520c:	872080e7          	jalr	-1934(ra) # 80001a7a <myproc>
    80005210:	84aa                	mv	s1,a0

  begin_op();
    80005212:	fffff097          	auipc	ra,0xfffff
    80005216:	43a080e7          	jalr	1082(ra) # 8000464c <begin_op>

  if ((ip = namei(path)) == 0)
    8000521a:	854a                	mv	a0,s2
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	230080e7          	jalr	560(ra) # 8000444c <namei>
    80005224:	c135                	beqz	a0,80005288 <exec+0x9c>
    80005226:	f3d2                	sd	s4,480(sp)
    80005228:	8a2a                	mv	s4,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    8000522a:	fffff097          	auipc	ra,0xfffff
    8000522e:	a54080e7          	jalr	-1452(ra) # 80003c7e <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005232:	04000713          	li	a4,64
    80005236:	4681                	li	a3,0
    80005238:	e5040613          	addi	a2,s0,-432
    8000523c:	4581                	li	a1,0
    8000523e:	8552                	mv	a0,s4
    80005240:	fffff097          	auipc	ra,0xfffff
    80005244:	cf6080e7          	jalr	-778(ra) # 80003f36 <readi>
    80005248:	04000793          	li	a5,64
    8000524c:	00f51a63          	bne	a0,a5,80005260 <exec+0x74>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    80005250:	e5042703          	lw	a4,-432(s0)
    80005254:	464c47b7          	lui	a5,0x464c4
    80005258:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000525c:	02f70c63          	beq	a4,a5,80005294 <exec+0xa8>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80005260:	8552                	mv	a0,s4
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	c82080e7          	jalr	-894(ra) # 80003ee4 <iunlockput>
    end_op();
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	45c080e7          	jalr	1116(ra) # 800046c6 <end_op>
  }
  return -1;
    80005272:	557d                	li	a0,-1
    80005274:	7a1e                	ld	s4,480(sp)
}
    80005276:	20813083          	ld	ra,520(sp)
    8000527a:	20013403          	ld	s0,512(sp)
    8000527e:	74fe                	ld	s1,504(sp)
    80005280:	795e                	ld	s2,496(sp)
    80005282:	21010113          	addi	sp,sp,528
    80005286:	8082                	ret
    end_op();
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	43e080e7          	jalr	1086(ra) # 800046c6 <end_op>
    return -1;
    80005290:	557d                	li	a0,-1
    80005292:	b7d5                	j	80005276 <exec+0x8a>
    80005294:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80005296:	8526                	mv	a0,s1
    80005298:	ffffd097          	auipc	ra,0xffffd
    8000529c:	8d2080e7          	jalr	-1838(ra) # 80001b6a <proc_pagetable>
    800052a0:	8b2a                	mv	s6,a0
    800052a2:	30050f63          	beqz	a0,800055c0 <exec+0x3d4>
    800052a6:	f7ce                	sd	s3,488(sp)
    800052a8:	efd6                	sd	s5,472(sp)
    800052aa:	e7de                	sd	s7,456(sp)
    800052ac:	e3e2                	sd	s8,448(sp)
    800052ae:	ff66                	sd	s9,440(sp)
    800052b0:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800052b2:	e7042d03          	lw	s10,-400(s0)
    800052b6:	e8845783          	lhu	a5,-376(s0)
    800052ba:	14078d63          	beqz	a5,80005414 <exec+0x228>
    800052be:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052c0:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800052c2:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    800052c4:	6c85                	lui	s9,0x1
    800052c6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800052ca:	def43823          	sd	a5,-528(s0)
  for (i = 0; i < sz; i += PGSIZE)
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800052ce:	6a85                	lui	s5,0x1
    800052d0:	a0b5                	j	8000533c <exec+0x150>
      panic("loadseg: address should exist");
    800052d2:	00003517          	auipc	a0,0x3
    800052d6:	2fe50513          	addi	a0,a0,766 # 800085d0 <etext+0x5d0>
    800052da:	ffffb097          	auipc	ra,0xffffb
    800052de:	286080e7          	jalr	646(ra) # 80000560 <panic>
    if (sz - i < PGSIZE)
    800052e2:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800052e4:	8726                	mv	a4,s1
    800052e6:	012c06bb          	addw	a3,s8,s2
    800052ea:	4581                	li	a1,0
    800052ec:	8552                	mv	a0,s4
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	c48080e7          	jalr	-952(ra) # 80003f36 <readi>
    800052f6:	2501                	sext.w	a0,a0
    800052f8:	28a49863          	bne	s1,a0,80005588 <exec+0x39c>
  for (i = 0; i < sz; i += PGSIZE)
    800052fc:	012a893b          	addw	s2,s5,s2
    80005300:	03397563          	bgeu	s2,s3,8000532a <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005304:	02091593          	slli	a1,s2,0x20
    80005308:	9181                	srli	a1,a1,0x20
    8000530a:	95de                	add	a1,a1,s7
    8000530c:	855a                	mv	a0,s6
    8000530e:	ffffc097          	auipc	ra,0xffffc
    80005312:	da8080e7          	jalr	-600(ra) # 800010b6 <walkaddr>
    80005316:	862a                	mv	a2,a0
    if (pa == 0)
    80005318:	dd4d                	beqz	a0,800052d2 <exec+0xe6>
    if (sz - i < PGSIZE)
    8000531a:	412984bb          	subw	s1,s3,s2
    8000531e:	0004879b          	sext.w	a5,s1
    80005322:	fcfcf0e3          	bgeu	s9,a5,800052e2 <exec+0xf6>
    80005326:	84d6                	mv	s1,s5
    80005328:	bf6d                	j	800052e2 <exec+0xf6>
    sz = sz1;
    8000532a:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000532e:	2d85                	addiw	s11,s11,1
    80005330:	038d0d1b          	addiw	s10,s10,56
    80005334:	e8845783          	lhu	a5,-376(s0)
    80005338:	08fdd663          	bge	s11,a5,800053c4 <exec+0x1d8>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000533c:	2d01                	sext.w	s10,s10
    8000533e:	03800713          	li	a4,56
    80005342:	86ea                	mv	a3,s10
    80005344:	e1840613          	addi	a2,s0,-488
    80005348:	4581                	li	a1,0
    8000534a:	8552                	mv	a0,s4
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	bea080e7          	jalr	-1046(ra) # 80003f36 <readi>
    80005354:	03800793          	li	a5,56
    80005358:	20f51063          	bne	a0,a5,80005558 <exec+0x36c>
    if (ph.type != ELF_PROG_LOAD)
    8000535c:	e1842783          	lw	a5,-488(s0)
    80005360:	4705                	li	a4,1
    80005362:	fce796e3          	bne	a5,a4,8000532e <exec+0x142>
    if (ph.memsz < ph.filesz)
    80005366:	e4043483          	ld	s1,-448(s0)
    8000536a:	e3843783          	ld	a5,-456(s0)
    8000536e:	1ef4e963          	bltu	s1,a5,80005560 <exec+0x374>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005372:	e2843783          	ld	a5,-472(s0)
    80005376:	94be                	add	s1,s1,a5
    80005378:	1ef4e863          	bltu	s1,a5,80005568 <exec+0x37c>
    if (ph.vaddr % PGSIZE != 0)
    8000537c:	df043703          	ld	a4,-528(s0)
    80005380:	8ff9                	and	a5,a5,a4
    80005382:	1e079763          	bnez	a5,80005570 <exec+0x384>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005386:	e1c42503          	lw	a0,-484(s0)
    8000538a:	00000097          	auipc	ra,0x0
    8000538e:	e48080e7          	jalr	-440(ra) # 800051d2 <flags2perm>
    80005392:	86aa                	mv	a3,a0
    80005394:	8626                	mv	a2,s1
    80005396:	85ca                	mv	a1,s2
    80005398:	855a                	mv	a0,s6
    8000539a:	ffffc097          	auipc	ra,0xffffc
    8000539e:	0e0080e7          	jalr	224(ra) # 8000147a <uvmalloc>
    800053a2:	e0a43423          	sd	a0,-504(s0)
    800053a6:	1c050963          	beqz	a0,80005578 <exec+0x38c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053aa:	e2843b83          	ld	s7,-472(s0)
    800053ae:	e2042c03          	lw	s8,-480(s0)
    800053b2:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    800053b6:	00098463          	beqz	s3,800053be <exec+0x1d2>
    800053ba:	4901                	li	s2,0
    800053bc:	b7a1                	j	80005304 <exec+0x118>
    sz = sz1;
    800053be:	e0843903          	ld	s2,-504(s0)
    800053c2:	b7b5                	j	8000532e <exec+0x142>
    800053c4:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800053c6:	8552                	mv	a0,s4
    800053c8:	fffff097          	auipc	ra,0xfffff
    800053cc:	b1c080e7          	jalr	-1252(ra) # 80003ee4 <iunlockput>
  end_op();
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	2f6080e7          	jalr	758(ra) # 800046c6 <end_op>
  p = myproc();
    800053d8:	ffffc097          	auipc	ra,0xffffc
    800053dc:	6a2080e7          	jalr	1698(ra) # 80001a7a <myproc>
    800053e0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800053e2:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800053e6:	6985                	lui	s3,0x1
    800053e8:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800053ea:	99ca                	add	s3,s3,s2
    800053ec:	77fd                	lui	a5,0xfffff
    800053ee:	00f9f9b3          	and	s3,s3,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    800053f2:	4691                	li	a3,4
    800053f4:	6609                	lui	a2,0x2
    800053f6:	964e                	add	a2,a2,s3
    800053f8:	85ce                	mv	a1,s3
    800053fa:	855a                	mv	a0,s6
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	07e080e7          	jalr	126(ra) # 8000147a <uvmalloc>
    80005404:	892a                	mv	s2,a0
    80005406:	e0a43423          	sd	a0,-504(s0)
    8000540a:	e519                	bnez	a0,80005418 <exec+0x22c>
  if (pagetable)
    8000540c:	e1343423          	sd	s3,-504(s0)
    80005410:	4a01                	li	s4,0
    80005412:	aaa5                	j	8000558a <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005414:	4901                	li	s2,0
    80005416:	bf45                	j	800053c6 <exec+0x1da>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005418:	75f9                	lui	a1,0xffffe
    8000541a:	95aa                	add	a1,a1,a0
    8000541c:	855a                	mv	a0,s6
    8000541e:	ffffc097          	auipc	ra,0xffffc
    80005422:	292080e7          	jalr	658(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    80005426:	7bfd                	lui	s7,0xfffff
    80005428:	9bca                	add	s7,s7,s2
  for (argc = 0; argv[argc]; argc++)
    8000542a:	e0043783          	ld	a5,-512(s0)
    8000542e:	6388                	ld	a0,0(a5)
    80005430:	c52d                	beqz	a0,8000549a <exec+0x2ae>
    80005432:	e9040993          	addi	s3,s0,-368
    80005436:	f9040c13          	addi	s8,s0,-112
    8000543a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000543c:	ffffc097          	auipc	ra,0xffffc
    80005440:	a6c080e7          	jalr	-1428(ra) # 80000ea8 <strlen>
    80005444:	0015079b          	addiw	a5,a0,1
    80005448:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000544c:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    80005450:	13796863          	bltu	s2,s7,80005580 <exec+0x394>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005454:	e0043d03          	ld	s10,-512(s0)
    80005458:	000d3a03          	ld	s4,0(s10)
    8000545c:	8552                	mv	a0,s4
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	a4a080e7          	jalr	-1462(ra) # 80000ea8 <strlen>
    80005466:	0015069b          	addiw	a3,a0,1
    8000546a:	8652                	mv	a2,s4
    8000546c:	85ca                	mv	a1,s2
    8000546e:	855a                	mv	a0,s6
    80005470:	ffffc097          	auipc	ra,0xffffc
    80005474:	272080e7          	jalr	626(ra) # 800016e2 <copyout>
    80005478:	10054663          	bltz	a0,80005584 <exec+0x398>
    ustack[argc] = sp;
    8000547c:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005480:	0485                	addi	s1,s1,1
    80005482:	008d0793          	addi	a5,s10,8
    80005486:	e0f43023          	sd	a5,-512(s0)
    8000548a:	008d3503          	ld	a0,8(s10)
    8000548e:	c909                	beqz	a0,800054a0 <exec+0x2b4>
    if (argc >= MAXARG)
    80005490:	09a1                	addi	s3,s3,8
    80005492:	fb8995e3          	bne	s3,s8,8000543c <exec+0x250>
  ip = 0;
    80005496:	4a01                	li	s4,0
    80005498:	a8cd                	j	8000558a <exec+0x39e>
  sp = sz;
    8000549a:	e0843903          	ld	s2,-504(s0)
  for (argc = 0; argv[argc]; argc++)
    8000549e:	4481                	li	s1,0
  ustack[argc] = 0;
    800054a0:	00349793          	slli	a5,s1,0x3
    800054a4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd60b8>
    800054a8:	97a2                	add	a5,a5,s0
    800054aa:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    800054ae:	00148693          	addi	a3,s1,1
    800054b2:	068e                	slli	a3,a3,0x3
    800054b4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800054b8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800054bc:	e0843983          	ld	s3,-504(s0)
  if (sp < stackbase)
    800054c0:	f57966e3          	bltu	s2,s7,8000540c <exec+0x220>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    800054c4:	e9040613          	addi	a2,s0,-368
    800054c8:	85ca                	mv	a1,s2
    800054ca:	855a                	mv	a0,s6
    800054cc:	ffffc097          	auipc	ra,0xffffc
    800054d0:	216080e7          	jalr	534(ra) # 800016e2 <copyout>
    800054d4:	0e054863          	bltz	a0,800055c4 <exec+0x3d8>
  p->trapframe->a1 = sp;
    800054d8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800054dc:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800054e0:	df843783          	ld	a5,-520(s0)
    800054e4:	0007c703          	lbu	a4,0(a5)
    800054e8:	cf11                	beqz	a4,80005504 <exec+0x318>
    800054ea:	0785                	addi	a5,a5,1
    if (*s == '/')
    800054ec:	02f00693          	li	a3,47
    800054f0:	a039                	j	800054fe <exec+0x312>
      last = s + 1;
    800054f2:	def43c23          	sd	a5,-520(s0)
  for (last = s = path; *s; s++)
    800054f6:	0785                	addi	a5,a5,1
    800054f8:	fff7c703          	lbu	a4,-1(a5)
    800054fc:	c701                	beqz	a4,80005504 <exec+0x318>
    if (*s == '/')
    800054fe:	fed71ce3          	bne	a4,a3,800054f6 <exec+0x30a>
    80005502:	bfc5                	j	800054f2 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005504:	4641                	li	a2,16
    80005506:	df843583          	ld	a1,-520(s0)
    8000550a:	158a8513          	addi	a0,s5,344
    8000550e:	ffffc097          	auipc	ra,0xffffc
    80005512:	968080e7          	jalr	-1688(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    80005516:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000551a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000551e:	e0843783          	ld	a5,-504(s0)
    80005522:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005526:	058ab783          	ld	a5,88(s5)
    8000552a:	e6843703          	ld	a4,-408(s0)
    8000552e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005530:	058ab783          	ld	a5,88(s5)
    80005534:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005538:	85e6                	mv	a1,s9
    8000553a:	ffffc097          	auipc	ra,0xffffc
    8000553e:	6cc080e7          	jalr	1740(ra) # 80001c06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005542:	0004851b          	sext.w	a0,s1
    80005546:	79be                	ld	s3,488(sp)
    80005548:	7a1e                	ld	s4,480(sp)
    8000554a:	6afe                	ld	s5,472(sp)
    8000554c:	6b5e                	ld	s6,464(sp)
    8000554e:	6bbe                	ld	s7,456(sp)
    80005550:	6c1e                	ld	s8,448(sp)
    80005552:	7cfa                	ld	s9,440(sp)
    80005554:	7d5a                	ld	s10,432(sp)
    80005556:	b305                	j	80005276 <exec+0x8a>
    80005558:	e1243423          	sd	s2,-504(s0)
    8000555c:	7dba                	ld	s11,424(sp)
    8000555e:	a035                	j	8000558a <exec+0x39e>
    80005560:	e1243423          	sd	s2,-504(s0)
    80005564:	7dba                	ld	s11,424(sp)
    80005566:	a015                	j	8000558a <exec+0x39e>
    80005568:	e1243423          	sd	s2,-504(s0)
    8000556c:	7dba                	ld	s11,424(sp)
    8000556e:	a831                	j	8000558a <exec+0x39e>
    80005570:	e1243423          	sd	s2,-504(s0)
    80005574:	7dba                	ld	s11,424(sp)
    80005576:	a811                	j	8000558a <exec+0x39e>
    80005578:	e1243423          	sd	s2,-504(s0)
    8000557c:	7dba                	ld	s11,424(sp)
    8000557e:	a031                	j	8000558a <exec+0x39e>
  ip = 0;
    80005580:	4a01                	li	s4,0
    80005582:	a021                	j	8000558a <exec+0x39e>
    80005584:	4a01                	li	s4,0
  if (pagetable)
    80005586:	a011                	j	8000558a <exec+0x39e>
    80005588:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000558a:	e0843583          	ld	a1,-504(s0)
    8000558e:	855a                	mv	a0,s6
    80005590:	ffffc097          	auipc	ra,0xffffc
    80005594:	676080e7          	jalr	1654(ra) # 80001c06 <proc_freepagetable>
  return -1;
    80005598:	557d                	li	a0,-1
  if (ip)
    8000559a:	000a1b63          	bnez	s4,800055b0 <exec+0x3c4>
    8000559e:	79be                	ld	s3,488(sp)
    800055a0:	7a1e                	ld	s4,480(sp)
    800055a2:	6afe                	ld	s5,472(sp)
    800055a4:	6b5e                	ld	s6,464(sp)
    800055a6:	6bbe                	ld	s7,456(sp)
    800055a8:	6c1e                	ld	s8,448(sp)
    800055aa:	7cfa                	ld	s9,440(sp)
    800055ac:	7d5a                	ld	s10,432(sp)
    800055ae:	b1e1                	j	80005276 <exec+0x8a>
    800055b0:	79be                	ld	s3,488(sp)
    800055b2:	6afe                	ld	s5,472(sp)
    800055b4:	6b5e                	ld	s6,464(sp)
    800055b6:	6bbe                	ld	s7,456(sp)
    800055b8:	6c1e                	ld	s8,448(sp)
    800055ba:	7cfa                	ld	s9,440(sp)
    800055bc:	7d5a                	ld	s10,432(sp)
    800055be:	b14d                	j	80005260 <exec+0x74>
    800055c0:	6b5e                	ld	s6,464(sp)
    800055c2:	b979                	j	80005260 <exec+0x74>
  sz = sz1;
    800055c4:	e0843983          	ld	s3,-504(s0)
    800055c8:	b591                	j	8000540c <exec+0x220>

00000000800055ca <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055ca:	7179                	addi	sp,sp,-48
    800055cc:	f406                	sd	ra,40(sp)
    800055ce:	f022                	sd	s0,32(sp)
    800055d0:	ec26                	sd	s1,24(sp)
    800055d2:	e84a                	sd	s2,16(sp)
    800055d4:	1800                	addi	s0,sp,48
    800055d6:	892e                	mv	s2,a1
    800055d8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800055da:	fdc40593          	addi	a1,s0,-36
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	94a080e7          	jalr	-1718(ra) # 80002f28 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055e6:	fdc42703          	lw	a4,-36(s0)
    800055ea:	47bd                	li	a5,15
    800055ec:	02e7eb63          	bltu	a5,a4,80005622 <argfd+0x58>
    800055f0:	ffffc097          	auipc	ra,0xffffc
    800055f4:	48a080e7          	jalr	1162(ra) # 80001a7a <myproc>
    800055f8:	fdc42703          	lw	a4,-36(s0)
    800055fc:	01a70793          	addi	a5,a4,26
    80005600:	078e                	slli	a5,a5,0x3
    80005602:	953e                	add	a0,a0,a5
    80005604:	611c                	ld	a5,0(a0)
    80005606:	c385                	beqz	a5,80005626 <argfd+0x5c>
    return -1;
  if(pfd)
    80005608:	00090463          	beqz	s2,80005610 <argfd+0x46>
    *pfd = fd;
    8000560c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005610:	4501                	li	a0,0
  if(pf)
    80005612:	c091                	beqz	s1,80005616 <argfd+0x4c>
    *pf = f;
    80005614:	e09c                	sd	a5,0(s1)
}
    80005616:	70a2                	ld	ra,40(sp)
    80005618:	7402                	ld	s0,32(sp)
    8000561a:	64e2                	ld	s1,24(sp)
    8000561c:	6942                	ld	s2,16(sp)
    8000561e:	6145                	addi	sp,sp,48
    80005620:	8082                	ret
    return -1;
    80005622:	557d                	li	a0,-1
    80005624:	bfcd                	j	80005616 <argfd+0x4c>
    80005626:	557d                	li	a0,-1
    80005628:	b7fd                	j	80005616 <argfd+0x4c>

000000008000562a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000562a:	1101                	addi	sp,sp,-32
    8000562c:	ec06                	sd	ra,24(sp)
    8000562e:	e822                	sd	s0,16(sp)
    80005630:	e426                	sd	s1,8(sp)
    80005632:	1000                	addi	s0,sp,32
    80005634:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005636:	ffffc097          	auipc	ra,0xffffc
    8000563a:	444080e7          	jalr	1092(ra) # 80001a7a <myproc>
    8000563e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005640:	0d050793          	addi	a5,a0,208
    80005644:	4501                	li	a0,0
    80005646:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005648:	6398                	ld	a4,0(a5)
    8000564a:	cb19                	beqz	a4,80005660 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000564c:	2505                	addiw	a0,a0,1
    8000564e:	07a1                	addi	a5,a5,8
    80005650:	fed51ce3          	bne	a0,a3,80005648 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005654:	557d                	li	a0,-1
}
    80005656:	60e2                	ld	ra,24(sp)
    80005658:	6442                	ld	s0,16(sp)
    8000565a:	64a2                	ld	s1,8(sp)
    8000565c:	6105                	addi	sp,sp,32
    8000565e:	8082                	ret
      p->ofile[fd] = f;
    80005660:	01a50793          	addi	a5,a0,26
    80005664:	078e                	slli	a5,a5,0x3
    80005666:	963e                	add	a2,a2,a5
    80005668:	e204                	sd	s1,0(a2)
      return fd;
    8000566a:	b7f5                	j	80005656 <fdalloc+0x2c>

000000008000566c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000566c:	715d                	addi	sp,sp,-80
    8000566e:	e486                	sd	ra,72(sp)
    80005670:	e0a2                	sd	s0,64(sp)
    80005672:	fc26                	sd	s1,56(sp)
    80005674:	f84a                	sd	s2,48(sp)
    80005676:	f44e                	sd	s3,40(sp)
    80005678:	ec56                	sd	s5,24(sp)
    8000567a:	e85a                	sd	s6,16(sp)
    8000567c:	0880                	addi	s0,sp,80
    8000567e:	8b2e                	mv	s6,a1
    80005680:	89b2                	mv	s3,a2
    80005682:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005684:	fb040593          	addi	a1,s0,-80
    80005688:	fffff097          	auipc	ra,0xfffff
    8000568c:	de2080e7          	jalr	-542(ra) # 8000446a <nameiparent>
    80005690:	84aa                	mv	s1,a0
    80005692:	14050e63          	beqz	a0,800057ee <create+0x182>
    return 0;

  ilock(dp);
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	5e8080e7          	jalr	1512(ra) # 80003c7e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000569e:	4601                	li	a2,0
    800056a0:	fb040593          	addi	a1,s0,-80
    800056a4:	8526                	mv	a0,s1
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	ae4080e7          	jalr	-1308(ra) # 8000418a <dirlookup>
    800056ae:	8aaa                	mv	s5,a0
    800056b0:	c539                	beqz	a0,800056fe <create+0x92>
    iunlockput(dp);
    800056b2:	8526                	mv	a0,s1
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	830080e7          	jalr	-2000(ra) # 80003ee4 <iunlockput>
    ilock(ip);
    800056bc:	8556                	mv	a0,s5
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	5c0080e7          	jalr	1472(ra) # 80003c7e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056c6:	4789                	li	a5,2
    800056c8:	02fb1463          	bne	s6,a5,800056f0 <create+0x84>
    800056cc:	044ad783          	lhu	a5,68(s5)
    800056d0:	37f9                	addiw	a5,a5,-2
    800056d2:	17c2                	slli	a5,a5,0x30
    800056d4:	93c1                	srli	a5,a5,0x30
    800056d6:	4705                	li	a4,1
    800056d8:	00f76c63          	bltu	a4,a5,800056f0 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800056dc:	8556                	mv	a0,s5
    800056de:	60a6                	ld	ra,72(sp)
    800056e0:	6406                	ld	s0,64(sp)
    800056e2:	74e2                	ld	s1,56(sp)
    800056e4:	7942                	ld	s2,48(sp)
    800056e6:	79a2                	ld	s3,40(sp)
    800056e8:	6ae2                	ld	s5,24(sp)
    800056ea:	6b42                	ld	s6,16(sp)
    800056ec:	6161                	addi	sp,sp,80
    800056ee:	8082                	ret
    iunlockput(ip);
    800056f0:	8556                	mv	a0,s5
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	7f2080e7          	jalr	2034(ra) # 80003ee4 <iunlockput>
    return 0;
    800056fa:	4a81                	li	s5,0
    800056fc:	b7c5                	j	800056dc <create+0x70>
    800056fe:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005700:	85da                	mv	a1,s6
    80005702:	4088                	lw	a0,0(s1)
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	3d6080e7          	jalr	982(ra) # 80003ada <ialloc>
    8000570c:	8a2a                	mv	s4,a0
    8000570e:	c531                	beqz	a0,8000575a <create+0xee>
  ilock(ip);
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	56e080e7          	jalr	1390(ra) # 80003c7e <ilock>
  ip->major = major;
    80005718:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000571c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005720:	4905                	li	s2,1
    80005722:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005726:	8552                	mv	a0,s4
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	48a080e7          	jalr	1162(ra) # 80003bb2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005730:	032b0d63          	beq	s6,s2,8000576a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005734:	004a2603          	lw	a2,4(s4)
    80005738:	fb040593          	addi	a1,s0,-80
    8000573c:	8526                	mv	a0,s1
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	c5c080e7          	jalr	-932(ra) # 8000439a <dirlink>
    80005746:	08054163          	bltz	a0,800057c8 <create+0x15c>
  iunlockput(dp);
    8000574a:	8526                	mv	a0,s1
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	798080e7          	jalr	1944(ra) # 80003ee4 <iunlockput>
  return ip;
    80005754:	8ad2                	mv	s5,s4
    80005756:	7a02                	ld	s4,32(sp)
    80005758:	b751                	j	800056dc <create+0x70>
    iunlockput(dp);
    8000575a:	8526                	mv	a0,s1
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	788080e7          	jalr	1928(ra) # 80003ee4 <iunlockput>
    return 0;
    80005764:	8ad2                	mv	s5,s4
    80005766:	7a02                	ld	s4,32(sp)
    80005768:	bf95                	j	800056dc <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000576a:	004a2603          	lw	a2,4(s4)
    8000576e:	00003597          	auipc	a1,0x3
    80005772:	e8258593          	addi	a1,a1,-382 # 800085f0 <etext+0x5f0>
    80005776:	8552                	mv	a0,s4
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	c22080e7          	jalr	-990(ra) # 8000439a <dirlink>
    80005780:	04054463          	bltz	a0,800057c8 <create+0x15c>
    80005784:	40d0                	lw	a2,4(s1)
    80005786:	00003597          	auipc	a1,0x3
    8000578a:	e7258593          	addi	a1,a1,-398 # 800085f8 <etext+0x5f8>
    8000578e:	8552                	mv	a0,s4
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	c0a080e7          	jalr	-1014(ra) # 8000439a <dirlink>
    80005798:	02054863          	bltz	a0,800057c8 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000579c:	004a2603          	lw	a2,4(s4)
    800057a0:	fb040593          	addi	a1,s0,-80
    800057a4:	8526                	mv	a0,s1
    800057a6:	fffff097          	auipc	ra,0xfffff
    800057aa:	bf4080e7          	jalr	-1036(ra) # 8000439a <dirlink>
    800057ae:	00054d63          	bltz	a0,800057c8 <create+0x15c>
    dp->nlink++;  // for ".."
    800057b2:	04a4d783          	lhu	a5,74(s1)
    800057b6:	2785                	addiw	a5,a5,1
    800057b8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057bc:	8526                	mv	a0,s1
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	3f4080e7          	jalr	1012(ra) # 80003bb2 <iupdate>
    800057c6:	b751                	j	8000574a <create+0xde>
  ip->nlink = 0;
    800057c8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057cc:	8552                	mv	a0,s4
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	3e4080e7          	jalr	996(ra) # 80003bb2 <iupdate>
  iunlockput(ip);
    800057d6:	8552                	mv	a0,s4
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	70c080e7          	jalr	1804(ra) # 80003ee4 <iunlockput>
  iunlockput(dp);
    800057e0:	8526                	mv	a0,s1
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	702080e7          	jalr	1794(ra) # 80003ee4 <iunlockput>
  return 0;
    800057ea:	7a02                	ld	s4,32(sp)
    800057ec:	bdc5                	j	800056dc <create+0x70>
    return 0;
    800057ee:	8aaa                	mv	s5,a0
    800057f0:	b5f5                	j	800056dc <create+0x70>

00000000800057f2 <sys_dup>:
{
    800057f2:	7179                	addi	sp,sp,-48
    800057f4:	f406                	sd	ra,40(sp)
    800057f6:	f022                	sd	s0,32(sp)
    800057f8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057fa:	fd840613          	addi	a2,s0,-40
    800057fe:	4581                	li	a1,0
    80005800:	4501                	li	a0,0
    80005802:	00000097          	auipc	ra,0x0
    80005806:	dc8080e7          	jalr	-568(ra) # 800055ca <argfd>
    return -1;
    8000580a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000580c:	02054763          	bltz	a0,8000583a <sys_dup+0x48>
    80005810:	ec26                	sd	s1,24(sp)
    80005812:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005814:	fd843903          	ld	s2,-40(s0)
    80005818:	854a                	mv	a0,s2
    8000581a:	00000097          	auipc	ra,0x0
    8000581e:	e10080e7          	jalr	-496(ra) # 8000562a <fdalloc>
    80005822:	84aa                	mv	s1,a0
    return -1;
    80005824:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005826:	00054f63          	bltz	a0,80005844 <sys_dup+0x52>
  filedup(f);
    8000582a:	854a                	mv	a0,s2
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	298080e7          	jalr	664(ra) # 80004ac4 <filedup>
  return fd;
    80005834:	87a6                	mv	a5,s1
    80005836:	64e2                	ld	s1,24(sp)
    80005838:	6942                	ld	s2,16(sp)
}
    8000583a:	853e                	mv	a0,a5
    8000583c:	70a2                	ld	ra,40(sp)
    8000583e:	7402                	ld	s0,32(sp)
    80005840:	6145                	addi	sp,sp,48
    80005842:	8082                	ret
    80005844:	64e2                	ld	s1,24(sp)
    80005846:	6942                	ld	s2,16(sp)
    80005848:	bfcd                	j	8000583a <sys_dup+0x48>

000000008000584a <sys_read>:
{
    8000584a:	7179                	addi	sp,sp,-48
    8000584c:	f406                	sd	ra,40(sp)
    8000584e:	f022                	sd	s0,32(sp)
    80005850:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005852:	fd840593          	addi	a1,s0,-40
    80005856:	4505                	li	a0,1
    80005858:	ffffd097          	auipc	ra,0xffffd
    8000585c:	6f0080e7          	jalr	1776(ra) # 80002f48 <argaddr>
  argint(2, &n);
    80005860:	fe440593          	addi	a1,s0,-28
    80005864:	4509                	li	a0,2
    80005866:	ffffd097          	auipc	ra,0xffffd
    8000586a:	6c2080e7          	jalr	1730(ra) # 80002f28 <argint>
  if(argfd(0, 0, &f) < 0)
    8000586e:	fe840613          	addi	a2,s0,-24
    80005872:	4581                	li	a1,0
    80005874:	4501                	li	a0,0
    80005876:	00000097          	auipc	ra,0x0
    8000587a:	d54080e7          	jalr	-684(ra) # 800055ca <argfd>
    8000587e:	87aa                	mv	a5,a0
    return -1;
    80005880:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005882:	0007cc63          	bltz	a5,8000589a <sys_read+0x50>
  return fileread(f, p, n);
    80005886:	fe442603          	lw	a2,-28(s0)
    8000588a:	fd843583          	ld	a1,-40(s0)
    8000588e:	fe843503          	ld	a0,-24(s0)
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	3d8080e7          	jalr	984(ra) # 80004c6a <fileread>
}
    8000589a:	70a2                	ld	ra,40(sp)
    8000589c:	7402                	ld	s0,32(sp)
    8000589e:	6145                	addi	sp,sp,48
    800058a0:	8082                	ret

00000000800058a2 <sys_write>:
{
    800058a2:	7179                	addi	sp,sp,-48
    800058a4:	f406                	sd	ra,40(sp)
    800058a6:	f022                	sd	s0,32(sp)
    800058a8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800058aa:	fd840593          	addi	a1,s0,-40
    800058ae:	4505                	li	a0,1
    800058b0:	ffffd097          	auipc	ra,0xffffd
    800058b4:	698080e7          	jalr	1688(ra) # 80002f48 <argaddr>
  argint(2, &n);
    800058b8:	fe440593          	addi	a1,s0,-28
    800058bc:	4509                	li	a0,2
    800058be:	ffffd097          	auipc	ra,0xffffd
    800058c2:	66a080e7          	jalr	1642(ra) # 80002f28 <argint>
  if(argfd(0, 0, &f) < 0)
    800058c6:	fe840613          	addi	a2,s0,-24
    800058ca:	4581                	li	a1,0
    800058cc:	4501                	li	a0,0
    800058ce:	00000097          	auipc	ra,0x0
    800058d2:	cfc080e7          	jalr	-772(ra) # 800055ca <argfd>
    800058d6:	87aa                	mv	a5,a0
    return -1;
    800058d8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058da:	0007cc63          	bltz	a5,800058f2 <sys_write+0x50>
  return filewrite(f, p, n);
    800058de:	fe442603          	lw	a2,-28(s0)
    800058e2:	fd843583          	ld	a1,-40(s0)
    800058e6:	fe843503          	ld	a0,-24(s0)
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	452080e7          	jalr	1106(ra) # 80004d3c <filewrite>
}
    800058f2:	70a2                	ld	ra,40(sp)
    800058f4:	7402                	ld	s0,32(sp)
    800058f6:	6145                	addi	sp,sp,48
    800058f8:	8082                	ret

00000000800058fa <sys_close>:
{
    800058fa:	1101                	addi	sp,sp,-32
    800058fc:	ec06                	sd	ra,24(sp)
    800058fe:	e822                	sd	s0,16(sp)
    80005900:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005902:	fe040613          	addi	a2,s0,-32
    80005906:	fec40593          	addi	a1,s0,-20
    8000590a:	4501                	li	a0,0
    8000590c:	00000097          	auipc	ra,0x0
    80005910:	cbe080e7          	jalr	-834(ra) # 800055ca <argfd>
    return -1;
    80005914:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005916:	02054463          	bltz	a0,8000593e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000591a:	ffffc097          	auipc	ra,0xffffc
    8000591e:	160080e7          	jalr	352(ra) # 80001a7a <myproc>
    80005922:	fec42783          	lw	a5,-20(s0)
    80005926:	07e9                	addi	a5,a5,26
    80005928:	078e                	slli	a5,a5,0x3
    8000592a:	953e                	add	a0,a0,a5
    8000592c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005930:	fe043503          	ld	a0,-32(s0)
    80005934:	fffff097          	auipc	ra,0xfffff
    80005938:	1e2080e7          	jalr	482(ra) # 80004b16 <fileclose>
  return 0;
    8000593c:	4781                	li	a5,0
}
    8000593e:	853e                	mv	a0,a5
    80005940:	60e2                	ld	ra,24(sp)
    80005942:	6442                	ld	s0,16(sp)
    80005944:	6105                	addi	sp,sp,32
    80005946:	8082                	ret

0000000080005948 <sys_fstat>:
{
    80005948:	1101                	addi	sp,sp,-32
    8000594a:	ec06                	sd	ra,24(sp)
    8000594c:	e822                	sd	s0,16(sp)
    8000594e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005950:	fe040593          	addi	a1,s0,-32
    80005954:	4505                	li	a0,1
    80005956:	ffffd097          	auipc	ra,0xffffd
    8000595a:	5f2080e7          	jalr	1522(ra) # 80002f48 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000595e:	fe840613          	addi	a2,s0,-24
    80005962:	4581                	li	a1,0
    80005964:	4501                	li	a0,0
    80005966:	00000097          	auipc	ra,0x0
    8000596a:	c64080e7          	jalr	-924(ra) # 800055ca <argfd>
    8000596e:	87aa                	mv	a5,a0
    return -1;
    80005970:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005972:	0007ca63          	bltz	a5,80005986 <sys_fstat+0x3e>
  return filestat(f, st);
    80005976:	fe043583          	ld	a1,-32(s0)
    8000597a:	fe843503          	ld	a0,-24(s0)
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	27a080e7          	jalr	634(ra) # 80004bf8 <filestat>
}
    80005986:	60e2                	ld	ra,24(sp)
    80005988:	6442                	ld	s0,16(sp)
    8000598a:	6105                	addi	sp,sp,32
    8000598c:	8082                	ret

000000008000598e <sys_link>:
{
    8000598e:	7169                	addi	sp,sp,-304
    80005990:	f606                	sd	ra,296(sp)
    80005992:	f222                	sd	s0,288(sp)
    80005994:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005996:	08000613          	li	a2,128
    8000599a:	ed040593          	addi	a1,s0,-304
    8000599e:	4501                	li	a0,0
    800059a0:	ffffd097          	auipc	ra,0xffffd
    800059a4:	5c8080e7          	jalr	1480(ra) # 80002f68 <argstr>
    return -1;
    800059a8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059aa:	12054663          	bltz	a0,80005ad6 <sys_link+0x148>
    800059ae:	08000613          	li	a2,128
    800059b2:	f5040593          	addi	a1,s0,-176
    800059b6:	4505                	li	a0,1
    800059b8:	ffffd097          	auipc	ra,0xffffd
    800059bc:	5b0080e7          	jalr	1456(ra) # 80002f68 <argstr>
    return -1;
    800059c0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059c2:	10054a63          	bltz	a0,80005ad6 <sys_link+0x148>
    800059c6:	ee26                	sd	s1,280(sp)
  begin_op();
    800059c8:	fffff097          	auipc	ra,0xfffff
    800059cc:	c84080e7          	jalr	-892(ra) # 8000464c <begin_op>
  if((ip = namei(old)) == 0){
    800059d0:	ed040513          	addi	a0,s0,-304
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	a78080e7          	jalr	-1416(ra) # 8000444c <namei>
    800059dc:	84aa                	mv	s1,a0
    800059de:	c949                	beqz	a0,80005a70 <sys_link+0xe2>
  ilock(ip);
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	29e080e7          	jalr	670(ra) # 80003c7e <ilock>
  if(ip->type == T_DIR){
    800059e8:	04449703          	lh	a4,68(s1)
    800059ec:	4785                	li	a5,1
    800059ee:	08f70863          	beq	a4,a5,80005a7e <sys_link+0xf0>
    800059f2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800059f4:	04a4d783          	lhu	a5,74(s1)
    800059f8:	2785                	addiw	a5,a5,1
    800059fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059fe:	8526                	mv	a0,s1
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	1b2080e7          	jalr	434(ra) # 80003bb2 <iupdate>
  iunlock(ip);
    80005a08:	8526                	mv	a0,s1
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	33a080e7          	jalr	826(ra) # 80003d44 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a12:	fd040593          	addi	a1,s0,-48
    80005a16:	f5040513          	addi	a0,s0,-176
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	a50080e7          	jalr	-1456(ra) # 8000446a <nameiparent>
    80005a22:	892a                	mv	s2,a0
    80005a24:	cd35                	beqz	a0,80005aa0 <sys_link+0x112>
  ilock(dp);
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	258080e7          	jalr	600(ra) # 80003c7e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a2e:	00092703          	lw	a4,0(s2)
    80005a32:	409c                	lw	a5,0(s1)
    80005a34:	06f71163          	bne	a4,a5,80005a96 <sys_link+0x108>
    80005a38:	40d0                	lw	a2,4(s1)
    80005a3a:	fd040593          	addi	a1,s0,-48
    80005a3e:	854a                	mv	a0,s2
    80005a40:	fffff097          	auipc	ra,0xfffff
    80005a44:	95a080e7          	jalr	-1702(ra) # 8000439a <dirlink>
    80005a48:	04054763          	bltz	a0,80005a96 <sys_link+0x108>
  iunlockput(dp);
    80005a4c:	854a                	mv	a0,s2
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	496080e7          	jalr	1174(ra) # 80003ee4 <iunlockput>
  iput(ip);
    80005a56:	8526                	mv	a0,s1
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	3e4080e7          	jalr	996(ra) # 80003e3c <iput>
  end_op();
    80005a60:	fffff097          	auipc	ra,0xfffff
    80005a64:	c66080e7          	jalr	-922(ra) # 800046c6 <end_op>
  return 0;
    80005a68:	4781                	li	a5,0
    80005a6a:	64f2                	ld	s1,280(sp)
    80005a6c:	6952                	ld	s2,272(sp)
    80005a6e:	a0a5                	j	80005ad6 <sys_link+0x148>
    end_op();
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	c56080e7          	jalr	-938(ra) # 800046c6 <end_op>
    return -1;
    80005a78:	57fd                	li	a5,-1
    80005a7a:	64f2                	ld	s1,280(sp)
    80005a7c:	a8a9                	j	80005ad6 <sys_link+0x148>
    iunlockput(ip);
    80005a7e:	8526                	mv	a0,s1
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	464080e7          	jalr	1124(ra) # 80003ee4 <iunlockput>
    end_op();
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	c3e080e7          	jalr	-962(ra) # 800046c6 <end_op>
    return -1;
    80005a90:	57fd                	li	a5,-1
    80005a92:	64f2                	ld	s1,280(sp)
    80005a94:	a089                	j	80005ad6 <sys_link+0x148>
    iunlockput(dp);
    80005a96:	854a                	mv	a0,s2
    80005a98:	ffffe097          	auipc	ra,0xffffe
    80005a9c:	44c080e7          	jalr	1100(ra) # 80003ee4 <iunlockput>
  ilock(ip);
    80005aa0:	8526                	mv	a0,s1
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	1dc080e7          	jalr	476(ra) # 80003c7e <ilock>
  ip->nlink--;
    80005aaa:	04a4d783          	lhu	a5,74(s1)
    80005aae:	37fd                	addiw	a5,a5,-1
    80005ab0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ab4:	8526                	mv	a0,s1
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	0fc080e7          	jalr	252(ra) # 80003bb2 <iupdate>
  iunlockput(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	424080e7          	jalr	1060(ra) # 80003ee4 <iunlockput>
  end_op();
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	bfe080e7          	jalr	-1026(ra) # 800046c6 <end_op>
  return -1;
    80005ad0:	57fd                	li	a5,-1
    80005ad2:	64f2                	ld	s1,280(sp)
    80005ad4:	6952                	ld	s2,272(sp)
}
    80005ad6:	853e                	mv	a0,a5
    80005ad8:	70b2                	ld	ra,296(sp)
    80005ada:	7412                	ld	s0,288(sp)
    80005adc:	6155                	addi	sp,sp,304
    80005ade:	8082                	ret

0000000080005ae0 <sys_unlink>:
{
    80005ae0:	7151                	addi	sp,sp,-240
    80005ae2:	f586                	sd	ra,232(sp)
    80005ae4:	f1a2                	sd	s0,224(sp)
    80005ae6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005ae8:	08000613          	li	a2,128
    80005aec:	f3040593          	addi	a1,s0,-208
    80005af0:	4501                	li	a0,0
    80005af2:	ffffd097          	auipc	ra,0xffffd
    80005af6:	476080e7          	jalr	1142(ra) # 80002f68 <argstr>
    80005afa:	1a054a63          	bltz	a0,80005cae <sys_unlink+0x1ce>
    80005afe:	eda6                	sd	s1,216(sp)
  begin_op();
    80005b00:	fffff097          	auipc	ra,0xfffff
    80005b04:	b4c080e7          	jalr	-1204(ra) # 8000464c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b08:	fb040593          	addi	a1,s0,-80
    80005b0c:	f3040513          	addi	a0,s0,-208
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	95a080e7          	jalr	-1702(ra) # 8000446a <nameiparent>
    80005b18:	84aa                	mv	s1,a0
    80005b1a:	cd71                	beqz	a0,80005bf6 <sys_unlink+0x116>
  ilock(dp);
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	162080e7          	jalr	354(ra) # 80003c7e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b24:	00003597          	auipc	a1,0x3
    80005b28:	acc58593          	addi	a1,a1,-1332 # 800085f0 <etext+0x5f0>
    80005b2c:	fb040513          	addi	a0,s0,-80
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	640080e7          	jalr	1600(ra) # 80004170 <namecmp>
    80005b38:	14050c63          	beqz	a0,80005c90 <sys_unlink+0x1b0>
    80005b3c:	00003597          	auipc	a1,0x3
    80005b40:	abc58593          	addi	a1,a1,-1348 # 800085f8 <etext+0x5f8>
    80005b44:	fb040513          	addi	a0,s0,-80
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	628080e7          	jalr	1576(ra) # 80004170 <namecmp>
    80005b50:	14050063          	beqz	a0,80005c90 <sys_unlink+0x1b0>
    80005b54:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b56:	f2c40613          	addi	a2,s0,-212
    80005b5a:	fb040593          	addi	a1,s0,-80
    80005b5e:	8526                	mv	a0,s1
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	62a080e7          	jalr	1578(ra) # 8000418a <dirlookup>
    80005b68:	892a                	mv	s2,a0
    80005b6a:	12050263          	beqz	a0,80005c8e <sys_unlink+0x1ae>
  ilock(ip);
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	110080e7          	jalr	272(ra) # 80003c7e <ilock>
  if(ip->nlink < 1)
    80005b76:	04a91783          	lh	a5,74(s2)
    80005b7a:	08f05563          	blez	a5,80005c04 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b7e:	04491703          	lh	a4,68(s2)
    80005b82:	4785                	li	a5,1
    80005b84:	08f70963          	beq	a4,a5,80005c16 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005b88:	4641                	li	a2,16
    80005b8a:	4581                	li	a1,0
    80005b8c:	fc040513          	addi	a0,s0,-64
    80005b90:	ffffb097          	auipc	ra,0xffffb
    80005b94:	1a4080e7          	jalr	420(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b98:	4741                	li	a4,16
    80005b9a:	f2c42683          	lw	a3,-212(s0)
    80005b9e:	fc040613          	addi	a2,s0,-64
    80005ba2:	4581                	li	a1,0
    80005ba4:	8526                	mv	a0,s1
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	4a0080e7          	jalr	1184(ra) # 80004046 <writei>
    80005bae:	47c1                	li	a5,16
    80005bb0:	0af51b63          	bne	a0,a5,80005c66 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005bb4:	04491703          	lh	a4,68(s2)
    80005bb8:	4785                	li	a5,1
    80005bba:	0af70f63          	beq	a4,a5,80005c78 <sys_unlink+0x198>
  iunlockput(dp);
    80005bbe:	8526                	mv	a0,s1
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	324080e7          	jalr	804(ra) # 80003ee4 <iunlockput>
  ip->nlink--;
    80005bc8:	04a95783          	lhu	a5,74(s2)
    80005bcc:	37fd                	addiw	a5,a5,-1
    80005bce:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005bd2:	854a                	mv	a0,s2
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	fde080e7          	jalr	-34(ra) # 80003bb2 <iupdate>
  iunlockput(ip);
    80005bdc:	854a                	mv	a0,s2
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	306080e7          	jalr	774(ra) # 80003ee4 <iunlockput>
  end_op();
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	ae0080e7          	jalr	-1312(ra) # 800046c6 <end_op>
  return 0;
    80005bee:	4501                	li	a0,0
    80005bf0:	64ee                	ld	s1,216(sp)
    80005bf2:	694e                	ld	s2,208(sp)
    80005bf4:	a84d                	j	80005ca6 <sys_unlink+0x1c6>
    end_op();
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	ad0080e7          	jalr	-1328(ra) # 800046c6 <end_op>
    return -1;
    80005bfe:	557d                	li	a0,-1
    80005c00:	64ee                	ld	s1,216(sp)
    80005c02:	a055                	j	80005ca6 <sys_unlink+0x1c6>
    80005c04:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005c06:	00003517          	auipc	a0,0x3
    80005c0a:	9fa50513          	addi	a0,a0,-1542 # 80008600 <etext+0x600>
    80005c0e:	ffffb097          	auipc	ra,0xffffb
    80005c12:	952080e7          	jalr	-1710(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c16:	04c92703          	lw	a4,76(s2)
    80005c1a:	02000793          	li	a5,32
    80005c1e:	f6e7f5e3          	bgeu	a5,a4,80005b88 <sys_unlink+0xa8>
    80005c22:	e5ce                	sd	s3,200(sp)
    80005c24:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c28:	4741                	li	a4,16
    80005c2a:	86ce                	mv	a3,s3
    80005c2c:	f1840613          	addi	a2,s0,-232
    80005c30:	4581                	li	a1,0
    80005c32:	854a                	mv	a0,s2
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	302080e7          	jalr	770(ra) # 80003f36 <readi>
    80005c3c:	47c1                	li	a5,16
    80005c3e:	00f51c63          	bne	a0,a5,80005c56 <sys_unlink+0x176>
    if(de.inum != 0)
    80005c42:	f1845783          	lhu	a5,-232(s0)
    80005c46:	e7b5                	bnez	a5,80005cb2 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c48:	29c1                	addiw	s3,s3,16
    80005c4a:	04c92783          	lw	a5,76(s2)
    80005c4e:	fcf9ede3          	bltu	s3,a5,80005c28 <sys_unlink+0x148>
    80005c52:	69ae                	ld	s3,200(sp)
    80005c54:	bf15                	j	80005b88 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005c56:	00003517          	auipc	a0,0x3
    80005c5a:	9c250513          	addi	a0,a0,-1598 # 80008618 <etext+0x618>
    80005c5e:	ffffb097          	auipc	ra,0xffffb
    80005c62:	902080e7          	jalr	-1790(ra) # 80000560 <panic>
    80005c66:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005c68:	00003517          	auipc	a0,0x3
    80005c6c:	9c850513          	addi	a0,a0,-1592 # 80008630 <etext+0x630>
    80005c70:	ffffb097          	auipc	ra,0xffffb
    80005c74:	8f0080e7          	jalr	-1808(ra) # 80000560 <panic>
    dp->nlink--;
    80005c78:	04a4d783          	lhu	a5,74(s1)
    80005c7c:	37fd                	addiw	a5,a5,-1
    80005c7e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c82:	8526                	mv	a0,s1
    80005c84:	ffffe097          	auipc	ra,0xffffe
    80005c88:	f2e080e7          	jalr	-210(ra) # 80003bb2 <iupdate>
    80005c8c:	bf0d                	j	80005bbe <sys_unlink+0xde>
    80005c8e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005c90:	8526                	mv	a0,s1
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	252080e7          	jalr	594(ra) # 80003ee4 <iunlockput>
  end_op();
    80005c9a:	fffff097          	auipc	ra,0xfffff
    80005c9e:	a2c080e7          	jalr	-1492(ra) # 800046c6 <end_op>
  return -1;
    80005ca2:	557d                	li	a0,-1
    80005ca4:	64ee                	ld	s1,216(sp)
}
    80005ca6:	70ae                	ld	ra,232(sp)
    80005ca8:	740e                	ld	s0,224(sp)
    80005caa:	616d                	addi	sp,sp,240
    80005cac:	8082                	ret
    return -1;
    80005cae:	557d                	li	a0,-1
    80005cb0:	bfdd                	j	80005ca6 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005cb2:	854a                	mv	a0,s2
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	230080e7          	jalr	560(ra) # 80003ee4 <iunlockput>
    goto bad;
    80005cbc:	694e                	ld	s2,208(sp)
    80005cbe:	69ae                	ld	s3,200(sp)
    80005cc0:	bfc1                	j	80005c90 <sys_unlink+0x1b0>

0000000080005cc2 <sys_open>:

uint64
sys_open(void)
{
    80005cc2:	7131                	addi	sp,sp,-192
    80005cc4:	fd06                	sd	ra,184(sp)
    80005cc6:	f922                	sd	s0,176(sp)
    80005cc8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005cca:	f4c40593          	addi	a1,s0,-180
    80005cce:	4505                	li	a0,1
    80005cd0:	ffffd097          	auipc	ra,0xffffd
    80005cd4:	258080e7          	jalr	600(ra) # 80002f28 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005cd8:	08000613          	li	a2,128
    80005cdc:	f5040593          	addi	a1,s0,-176
    80005ce0:	4501                	li	a0,0
    80005ce2:	ffffd097          	auipc	ra,0xffffd
    80005ce6:	286080e7          	jalr	646(ra) # 80002f68 <argstr>
    80005cea:	87aa                	mv	a5,a0
    return -1;
    80005cec:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005cee:	0a07ce63          	bltz	a5,80005daa <sys_open+0xe8>
    80005cf2:	f526                	sd	s1,168(sp)

  begin_op();
    80005cf4:	fffff097          	auipc	ra,0xfffff
    80005cf8:	958080e7          	jalr	-1704(ra) # 8000464c <begin_op>

  if(omode & O_CREATE){
    80005cfc:	f4c42783          	lw	a5,-180(s0)
    80005d00:	2007f793          	andi	a5,a5,512
    80005d04:	cfd5                	beqz	a5,80005dc0 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005d06:	4681                	li	a3,0
    80005d08:	4601                	li	a2,0
    80005d0a:	4589                	li	a1,2
    80005d0c:	f5040513          	addi	a0,s0,-176
    80005d10:	00000097          	auipc	ra,0x0
    80005d14:	95c080e7          	jalr	-1700(ra) # 8000566c <create>
    80005d18:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d1a:	cd41                	beqz	a0,80005db2 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d1c:	04449703          	lh	a4,68(s1)
    80005d20:	478d                	li	a5,3
    80005d22:	00f71763          	bne	a4,a5,80005d30 <sys_open+0x6e>
    80005d26:	0464d703          	lhu	a4,70(s1)
    80005d2a:	47a5                	li	a5,9
    80005d2c:	0ee7e163          	bltu	a5,a4,80005e0e <sys_open+0x14c>
    80005d30:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	d28080e7          	jalr	-728(ra) # 80004a5a <filealloc>
    80005d3a:	892a                	mv	s2,a0
    80005d3c:	c97d                	beqz	a0,80005e32 <sys_open+0x170>
    80005d3e:	ed4e                	sd	s3,152(sp)
    80005d40:	00000097          	auipc	ra,0x0
    80005d44:	8ea080e7          	jalr	-1814(ra) # 8000562a <fdalloc>
    80005d48:	89aa                	mv	s3,a0
    80005d4a:	0c054e63          	bltz	a0,80005e26 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d4e:	04449703          	lh	a4,68(s1)
    80005d52:	478d                	li	a5,3
    80005d54:	0ef70c63          	beq	a4,a5,80005e4c <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d58:	4789                	li	a5,2
    80005d5a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005d5e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005d62:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005d66:	f4c42783          	lw	a5,-180(s0)
    80005d6a:	0017c713          	xori	a4,a5,1
    80005d6e:	8b05                	andi	a4,a4,1
    80005d70:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d74:	0037f713          	andi	a4,a5,3
    80005d78:	00e03733          	snez	a4,a4
    80005d7c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d80:	4007f793          	andi	a5,a5,1024
    80005d84:	c791                	beqz	a5,80005d90 <sys_open+0xce>
    80005d86:	04449703          	lh	a4,68(s1)
    80005d8a:	4789                	li	a5,2
    80005d8c:	0cf70763          	beq	a4,a5,80005e5a <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005d90:	8526                	mv	a0,s1
    80005d92:	ffffe097          	auipc	ra,0xffffe
    80005d96:	fb2080e7          	jalr	-78(ra) # 80003d44 <iunlock>
  end_op();
    80005d9a:	fffff097          	auipc	ra,0xfffff
    80005d9e:	92c080e7          	jalr	-1748(ra) # 800046c6 <end_op>

  return fd;
    80005da2:	854e                	mv	a0,s3
    80005da4:	74aa                	ld	s1,168(sp)
    80005da6:	790a                	ld	s2,160(sp)
    80005da8:	69ea                	ld	s3,152(sp)
}
    80005daa:	70ea                	ld	ra,184(sp)
    80005dac:	744a                	ld	s0,176(sp)
    80005dae:	6129                	addi	sp,sp,192
    80005db0:	8082                	ret
      end_op();
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	914080e7          	jalr	-1772(ra) # 800046c6 <end_op>
      return -1;
    80005dba:	557d                	li	a0,-1
    80005dbc:	74aa                	ld	s1,168(sp)
    80005dbe:	b7f5                	j	80005daa <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005dc0:	f5040513          	addi	a0,s0,-176
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	688080e7          	jalr	1672(ra) # 8000444c <namei>
    80005dcc:	84aa                	mv	s1,a0
    80005dce:	c90d                	beqz	a0,80005e00 <sys_open+0x13e>
    ilock(ip);
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	eae080e7          	jalr	-338(ra) # 80003c7e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005dd8:	04449703          	lh	a4,68(s1)
    80005ddc:	4785                	li	a5,1
    80005dde:	f2f71fe3          	bne	a4,a5,80005d1c <sys_open+0x5a>
    80005de2:	f4c42783          	lw	a5,-180(s0)
    80005de6:	d7a9                	beqz	a5,80005d30 <sys_open+0x6e>
      iunlockput(ip);
    80005de8:	8526                	mv	a0,s1
    80005dea:	ffffe097          	auipc	ra,0xffffe
    80005dee:	0fa080e7          	jalr	250(ra) # 80003ee4 <iunlockput>
      end_op();
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	8d4080e7          	jalr	-1836(ra) # 800046c6 <end_op>
      return -1;
    80005dfa:	557d                	li	a0,-1
    80005dfc:	74aa                	ld	s1,168(sp)
    80005dfe:	b775                	j	80005daa <sys_open+0xe8>
      end_op();
    80005e00:	fffff097          	auipc	ra,0xfffff
    80005e04:	8c6080e7          	jalr	-1850(ra) # 800046c6 <end_op>
      return -1;
    80005e08:	557d                	li	a0,-1
    80005e0a:	74aa                	ld	s1,168(sp)
    80005e0c:	bf79                	j	80005daa <sys_open+0xe8>
    iunlockput(ip);
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	0d4080e7          	jalr	212(ra) # 80003ee4 <iunlockput>
    end_op();
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	8ae080e7          	jalr	-1874(ra) # 800046c6 <end_op>
    return -1;
    80005e20:	557d                	li	a0,-1
    80005e22:	74aa                	ld	s1,168(sp)
    80005e24:	b759                	j	80005daa <sys_open+0xe8>
      fileclose(f);
    80005e26:	854a                	mv	a0,s2
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	cee080e7          	jalr	-786(ra) # 80004b16 <fileclose>
    80005e30:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005e32:	8526                	mv	a0,s1
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	0b0080e7          	jalr	176(ra) # 80003ee4 <iunlockput>
    end_op();
    80005e3c:	fffff097          	auipc	ra,0xfffff
    80005e40:	88a080e7          	jalr	-1910(ra) # 800046c6 <end_op>
    return -1;
    80005e44:	557d                	li	a0,-1
    80005e46:	74aa                	ld	s1,168(sp)
    80005e48:	790a                	ld	s2,160(sp)
    80005e4a:	b785                	j	80005daa <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005e4c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005e50:	04649783          	lh	a5,70(s1)
    80005e54:	02f91223          	sh	a5,36(s2)
    80005e58:	b729                	j	80005d62 <sys_open+0xa0>
    itrunc(ip);
    80005e5a:	8526                	mv	a0,s1
    80005e5c:	ffffe097          	auipc	ra,0xffffe
    80005e60:	f34080e7          	jalr	-204(ra) # 80003d90 <itrunc>
    80005e64:	b735                	j	80005d90 <sys_open+0xce>

0000000080005e66 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e66:	7175                	addi	sp,sp,-144
    80005e68:	e506                	sd	ra,136(sp)
    80005e6a:	e122                	sd	s0,128(sp)
    80005e6c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e6e:	ffffe097          	auipc	ra,0xffffe
    80005e72:	7de080e7          	jalr	2014(ra) # 8000464c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e76:	08000613          	li	a2,128
    80005e7a:	f7040593          	addi	a1,s0,-144
    80005e7e:	4501                	li	a0,0
    80005e80:	ffffd097          	auipc	ra,0xffffd
    80005e84:	0e8080e7          	jalr	232(ra) # 80002f68 <argstr>
    80005e88:	02054963          	bltz	a0,80005eba <sys_mkdir+0x54>
    80005e8c:	4681                	li	a3,0
    80005e8e:	4601                	li	a2,0
    80005e90:	4585                	li	a1,1
    80005e92:	f7040513          	addi	a0,s0,-144
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	7d6080e7          	jalr	2006(ra) # 8000566c <create>
    80005e9e:	cd11                	beqz	a0,80005eba <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	044080e7          	jalr	68(ra) # 80003ee4 <iunlockput>
  end_op();
    80005ea8:	fffff097          	auipc	ra,0xfffff
    80005eac:	81e080e7          	jalr	-2018(ra) # 800046c6 <end_op>
  return 0;
    80005eb0:	4501                	li	a0,0
}
    80005eb2:	60aa                	ld	ra,136(sp)
    80005eb4:	640a                	ld	s0,128(sp)
    80005eb6:	6149                	addi	sp,sp,144
    80005eb8:	8082                	ret
    end_op();
    80005eba:	fffff097          	auipc	ra,0xfffff
    80005ebe:	80c080e7          	jalr	-2036(ra) # 800046c6 <end_op>
    return -1;
    80005ec2:	557d                	li	a0,-1
    80005ec4:	b7fd                	j	80005eb2 <sys_mkdir+0x4c>

0000000080005ec6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ec6:	7135                	addi	sp,sp,-160
    80005ec8:	ed06                	sd	ra,152(sp)
    80005eca:	e922                	sd	s0,144(sp)
    80005ecc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	77e080e7          	jalr	1918(ra) # 8000464c <begin_op>
  argint(1, &major);
    80005ed6:	f6c40593          	addi	a1,s0,-148
    80005eda:	4505                	li	a0,1
    80005edc:	ffffd097          	auipc	ra,0xffffd
    80005ee0:	04c080e7          	jalr	76(ra) # 80002f28 <argint>
  argint(2, &minor);
    80005ee4:	f6840593          	addi	a1,s0,-152
    80005ee8:	4509                	li	a0,2
    80005eea:	ffffd097          	auipc	ra,0xffffd
    80005eee:	03e080e7          	jalr	62(ra) # 80002f28 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ef2:	08000613          	li	a2,128
    80005ef6:	f7040593          	addi	a1,s0,-144
    80005efa:	4501                	li	a0,0
    80005efc:	ffffd097          	auipc	ra,0xffffd
    80005f00:	06c080e7          	jalr	108(ra) # 80002f68 <argstr>
    80005f04:	02054b63          	bltz	a0,80005f3a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f08:	f6841683          	lh	a3,-152(s0)
    80005f0c:	f6c41603          	lh	a2,-148(s0)
    80005f10:	458d                	li	a1,3
    80005f12:	f7040513          	addi	a0,s0,-144
    80005f16:	fffff097          	auipc	ra,0xfffff
    80005f1a:	756080e7          	jalr	1878(ra) # 8000566c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f1e:	cd11                	beqz	a0,80005f3a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f20:	ffffe097          	auipc	ra,0xffffe
    80005f24:	fc4080e7          	jalr	-60(ra) # 80003ee4 <iunlockput>
  end_op();
    80005f28:	ffffe097          	auipc	ra,0xffffe
    80005f2c:	79e080e7          	jalr	1950(ra) # 800046c6 <end_op>
  return 0;
    80005f30:	4501                	li	a0,0
}
    80005f32:	60ea                	ld	ra,152(sp)
    80005f34:	644a                	ld	s0,144(sp)
    80005f36:	610d                	addi	sp,sp,160
    80005f38:	8082                	ret
    end_op();
    80005f3a:	ffffe097          	auipc	ra,0xffffe
    80005f3e:	78c080e7          	jalr	1932(ra) # 800046c6 <end_op>
    return -1;
    80005f42:	557d                	li	a0,-1
    80005f44:	b7fd                	j	80005f32 <sys_mknod+0x6c>

0000000080005f46 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f46:	7135                	addi	sp,sp,-160
    80005f48:	ed06                	sd	ra,152(sp)
    80005f4a:	e922                	sd	s0,144(sp)
    80005f4c:	e14a                	sd	s2,128(sp)
    80005f4e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f50:	ffffc097          	auipc	ra,0xffffc
    80005f54:	b2a080e7          	jalr	-1238(ra) # 80001a7a <myproc>
    80005f58:	892a                	mv	s2,a0
  
  begin_op();
    80005f5a:	ffffe097          	auipc	ra,0xffffe
    80005f5e:	6f2080e7          	jalr	1778(ra) # 8000464c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f62:	08000613          	li	a2,128
    80005f66:	f6040593          	addi	a1,s0,-160
    80005f6a:	4501                	li	a0,0
    80005f6c:	ffffd097          	auipc	ra,0xffffd
    80005f70:	ffc080e7          	jalr	-4(ra) # 80002f68 <argstr>
    80005f74:	04054d63          	bltz	a0,80005fce <sys_chdir+0x88>
    80005f78:	e526                	sd	s1,136(sp)
    80005f7a:	f6040513          	addi	a0,s0,-160
    80005f7e:	ffffe097          	auipc	ra,0xffffe
    80005f82:	4ce080e7          	jalr	1230(ra) # 8000444c <namei>
    80005f86:	84aa                	mv	s1,a0
    80005f88:	c131                	beqz	a0,80005fcc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f8a:	ffffe097          	auipc	ra,0xffffe
    80005f8e:	cf4080e7          	jalr	-780(ra) # 80003c7e <ilock>
  if(ip->type != T_DIR){
    80005f92:	04449703          	lh	a4,68(s1)
    80005f96:	4785                	li	a5,1
    80005f98:	04f71163          	bne	a4,a5,80005fda <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f9c:	8526                	mv	a0,s1
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	da6080e7          	jalr	-602(ra) # 80003d44 <iunlock>
  iput(p->cwd);
    80005fa6:	15093503          	ld	a0,336(s2)
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	e92080e7          	jalr	-366(ra) # 80003e3c <iput>
  end_op();
    80005fb2:	ffffe097          	auipc	ra,0xffffe
    80005fb6:	714080e7          	jalr	1812(ra) # 800046c6 <end_op>
  p->cwd = ip;
    80005fba:	14993823          	sd	s1,336(s2)
  return 0;
    80005fbe:	4501                	li	a0,0
    80005fc0:	64aa                	ld	s1,136(sp)
}
    80005fc2:	60ea                	ld	ra,152(sp)
    80005fc4:	644a                	ld	s0,144(sp)
    80005fc6:	690a                	ld	s2,128(sp)
    80005fc8:	610d                	addi	sp,sp,160
    80005fca:	8082                	ret
    80005fcc:	64aa                	ld	s1,136(sp)
    end_op();
    80005fce:	ffffe097          	auipc	ra,0xffffe
    80005fd2:	6f8080e7          	jalr	1784(ra) # 800046c6 <end_op>
    return -1;
    80005fd6:	557d                	li	a0,-1
    80005fd8:	b7ed                	j	80005fc2 <sys_chdir+0x7c>
    iunlockput(ip);
    80005fda:	8526                	mv	a0,s1
    80005fdc:	ffffe097          	auipc	ra,0xffffe
    80005fe0:	f08080e7          	jalr	-248(ra) # 80003ee4 <iunlockput>
    end_op();
    80005fe4:	ffffe097          	auipc	ra,0xffffe
    80005fe8:	6e2080e7          	jalr	1762(ra) # 800046c6 <end_op>
    return -1;
    80005fec:	557d                	li	a0,-1
    80005fee:	64aa                	ld	s1,136(sp)
    80005ff0:	bfc9                	j	80005fc2 <sys_chdir+0x7c>

0000000080005ff2 <sys_exec>:

uint64
sys_exec(void)
{
    80005ff2:	7121                	addi	sp,sp,-448
    80005ff4:	ff06                	sd	ra,440(sp)
    80005ff6:	fb22                	sd	s0,432(sp)
    80005ff8:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ffa:	e4840593          	addi	a1,s0,-440
    80005ffe:	4505                	li	a0,1
    80006000:	ffffd097          	auipc	ra,0xffffd
    80006004:	f48080e7          	jalr	-184(ra) # 80002f48 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006008:	08000613          	li	a2,128
    8000600c:	f5040593          	addi	a1,s0,-176
    80006010:	4501                	li	a0,0
    80006012:	ffffd097          	auipc	ra,0xffffd
    80006016:	f56080e7          	jalr	-170(ra) # 80002f68 <argstr>
    8000601a:	87aa                	mv	a5,a0
    return -1;
    8000601c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000601e:	0e07c263          	bltz	a5,80006102 <sys_exec+0x110>
    80006022:	f726                	sd	s1,424(sp)
    80006024:	f34a                	sd	s2,416(sp)
    80006026:	ef4e                	sd	s3,408(sp)
    80006028:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000602a:	10000613          	li	a2,256
    8000602e:	4581                	li	a1,0
    80006030:	e5040513          	addi	a0,s0,-432
    80006034:	ffffb097          	auipc	ra,0xffffb
    80006038:	d00080e7          	jalr	-768(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000603c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80006040:	89a6                	mv	s3,s1
    80006042:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006044:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006048:	00391513          	slli	a0,s2,0x3
    8000604c:	e4040593          	addi	a1,s0,-448
    80006050:	e4843783          	ld	a5,-440(s0)
    80006054:	953e                	add	a0,a0,a5
    80006056:	ffffd097          	auipc	ra,0xffffd
    8000605a:	e34080e7          	jalr	-460(ra) # 80002e8a <fetchaddr>
    8000605e:	02054a63          	bltz	a0,80006092 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80006062:	e4043783          	ld	a5,-448(s0)
    80006066:	c7b9                	beqz	a5,800060b4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006068:	ffffb097          	auipc	ra,0xffffb
    8000606c:	ae0080e7          	jalr	-1312(ra) # 80000b48 <kalloc>
    80006070:	85aa                	mv	a1,a0
    80006072:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006076:	cd11                	beqz	a0,80006092 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006078:	6605                	lui	a2,0x1
    8000607a:	e4043503          	ld	a0,-448(s0)
    8000607e:	ffffd097          	auipc	ra,0xffffd
    80006082:	e5e080e7          	jalr	-418(ra) # 80002edc <fetchstr>
    80006086:	00054663          	bltz	a0,80006092 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    8000608a:	0905                	addi	s2,s2,1
    8000608c:	09a1                	addi	s3,s3,8
    8000608e:	fb491de3          	bne	s2,s4,80006048 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006092:	f5040913          	addi	s2,s0,-176
    80006096:	6088                	ld	a0,0(s1)
    80006098:	c125                	beqz	a0,800060f8 <sys_exec+0x106>
    kfree(argv[i]);
    8000609a:	ffffb097          	auipc	ra,0xffffb
    8000609e:	9b0080e7          	jalr	-1616(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060a2:	04a1                	addi	s1,s1,8
    800060a4:	ff2499e3          	bne	s1,s2,80006096 <sys_exec+0xa4>
  return -1;
    800060a8:	557d                	li	a0,-1
    800060aa:	74ba                	ld	s1,424(sp)
    800060ac:	791a                	ld	s2,416(sp)
    800060ae:	69fa                	ld	s3,408(sp)
    800060b0:	6a5a                	ld	s4,400(sp)
    800060b2:	a881                	j	80006102 <sys_exec+0x110>
      argv[i] = 0;
    800060b4:	0009079b          	sext.w	a5,s2
    800060b8:	078e                	slli	a5,a5,0x3
    800060ba:	fd078793          	addi	a5,a5,-48
    800060be:	97a2                	add	a5,a5,s0
    800060c0:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800060c4:	e5040593          	addi	a1,s0,-432
    800060c8:	f5040513          	addi	a0,s0,-176
    800060cc:	fffff097          	auipc	ra,0xfffff
    800060d0:	120080e7          	jalr	288(ra) # 800051ec <exec>
    800060d4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060d6:	f5040993          	addi	s3,s0,-176
    800060da:	6088                	ld	a0,0(s1)
    800060dc:	c901                	beqz	a0,800060ec <sys_exec+0xfa>
    kfree(argv[i]);
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	96c080e7          	jalr	-1684(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060e6:	04a1                	addi	s1,s1,8
    800060e8:	ff3499e3          	bne	s1,s3,800060da <sys_exec+0xe8>
  return ret;
    800060ec:	854a                	mv	a0,s2
    800060ee:	74ba                	ld	s1,424(sp)
    800060f0:	791a                	ld	s2,416(sp)
    800060f2:	69fa                	ld	s3,408(sp)
    800060f4:	6a5a                	ld	s4,400(sp)
    800060f6:	a031                	j	80006102 <sys_exec+0x110>
  return -1;
    800060f8:	557d                	li	a0,-1
    800060fa:	74ba                	ld	s1,424(sp)
    800060fc:	791a                	ld	s2,416(sp)
    800060fe:	69fa                	ld	s3,408(sp)
    80006100:	6a5a                	ld	s4,400(sp)
}
    80006102:	70fa                	ld	ra,440(sp)
    80006104:	745a                	ld	s0,432(sp)
    80006106:	6139                	addi	sp,sp,448
    80006108:	8082                	ret

000000008000610a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000610a:	7139                	addi	sp,sp,-64
    8000610c:	fc06                	sd	ra,56(sp)
    8000610e:	f822                	sd	s0,48(sp)
    80006110:	f426                	sd	s1,40(sp)
    80006112:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006114:	ffffc097          	auipc	ra,0xffffc
    80006118:	966080e7          	jalr	-1690(ra) # 80001a7a <myproc>
    8000611c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000611e:	fd840593          	addi	a1,s0,-40
    80006122:	4501                	li	a0,0
    80006124:	ffffd097          	auipc	ra,0xffffd
    80006128:	e24080e7          	jalr	-476(ra) # 80002f48 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000612c:	fc840593          	addi	a1,s0,-56
    80006130:	fd040513          	addi	a0,s0,-48
    80006134:	fffff097          	auipc	ra,0xfffff
    80006138:	d50080e7          	jalr	-688(ra) # 80004e84 <pipealloc>
    return -1;
    8000613c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000613e:	0c054463          	bltz	a0,80006206 <sys_pipe+0xfc>
  fd0 = -1;
    80006142:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006146:	fd043503          	ld	a0,-48(s0)
    8000614a:	fffff097          	auipc	ra,0xfffff
    8000614e:	4e0080e7          	jalr	1248(ra) # 8000562a <fdalloc>
    80006152:	fca42223          	sw	a0,-60(s0)
    80006156:	08054b63          	bltz	a0,800061ec <sys_pipe+0xe2>
    8000615a:	fc843503          	ld	a0,-56(s0)
    8000615e:	fffff097          	auipc	ra,0xfffff
    80006162:	4cc080e7          	jalr	1228(ra) # 8000562a <fdalloc>
    80006166:	fca42023          	sw	a0,-64(s0)
    8000616a:	06054863          	bltz	a0,800061da <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000616e:	4691                	li	a3,4
    80006170:	fc440613          	addi	a2,s0,-60
    80006174:	fd843583          	ld	a1,-40(s0)
    80006178:	68a8                	ld	a0,80(s1)
    8000617a:	ffffb097          	auipc	ra,0xffffb
    8000617e:	568080e7          	jalr	1384(ra) # 800016e2 <copyout>
    80006182:	02054063          	bltz	a0,800061a2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006186:	4691                	li	a3,4
    80006188:	fc040613          	addi	a2,s0,-64
    8000618c:	fd843583          	ld	a1,-40(s0)
    80006190:	0591                	addi	a1,a1,4
    80006192:	68a8                	ld	a0,80(s1)
    80006194:	ffffb097          	auipc	ra,0xffffb
    80006198:	54e080e7          	jalr	1358(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000619c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000619e:	06055463          	bgez	a0,80006206 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800061a2:	fc442783          	lw	a5,-60(s0)
    800061a6:	07e9                	addi	a5,a5,26
    800061a8:	078e                	slli	a5,a5,0x3
    800061aa:	97a6                	add	a5,a5,s1
    800061ac:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800061b0:	fc042783          	lw	a5,-64(s0)
    800061b4:	07e9                	addi	a5,a5,26
    800061b6:	078e                	slli	a5,a5,0x3
    800061b8:	94be                	add	s1,s1,a5
    800061ba:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800061be:	fd043503          	ld	a0,-48(s0)
    800061c2:	fffff097          	auipc	ra,0xfffff
    800061c6:	954080e7          	jalr	-1708(ra) # 80004b16 <fileclose>
    fileclose(wf);
    800061ca:	fc843503          	ld	a0,-56(s0)
    800061ce:	fffff097          	auipc	ra,0xfffff
    800061d2:	948080e7          	jalr	-1720(ra) # 80004b16 <fileclose>
    return -1;
    800061d6:	57fd                	li	a5,-1
    800061d8:	a03d                	j	80006206 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800061da:	fc442783          	lw	a5,-60(s0)
    800061de:	0007c763          	bltz	a5,800061ec <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800061e2:	07e9                	addi	a5,a5,26
    800061e4:	078e                	slli	a5,a5,0x3
    800061e6:	97a6                	add	a5,a5,s1
    800061e8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800061ec:	fd043503          	ld	a0,-48(s0)
    800061f0:	fffff097          	auipc	ra,0xfffff
    800061f4:	926080e7          	jalr	-1754(ra) # 80004b16 <fileclose>
    fileclose(wf);
    800061f8:	fc843503          	ld	a0,-56(s0)
    800061fc:	fffff097          	auipc	ra,0xfffff
    80006200:	91a080e7          	jalr	-1766(ra) # 80004b16 <fileclose>
    return -1;
    80006204:	57fd                	li	a5,-1
}
    80006206:	853e                	mv	a0,a5
    80006208:	70e2                	ld	ra,56(sp)
    8000620a:	7442                	ld	s0,48(sp)
    8000620c:	74a2                	ld	s1,40(sp)
    8000620e:	6121                	addi	sp,sp,64
    80006210:	8082                	ret
	...

0000000080006220 <kernelvec>:
    80006220:	7111                	addi	sp,sp,-256
    80006222:	e006                	sd	ra,0(sp)
    80006224:	e40a                	sd	sp,8(sp)
    80006226:	e80e                	sd	gp,16(sp)
    80006228:	ec12                	sd	tp,24(sp)
    8000622a:	f016                	sd	t0,32(sp)
    8000622c:	f41a                	sd	t1,40(sp)
    8000622e:	f81e                	sd	t2,48(sp)
    80006230:	fc22                	sd	s0,56(sp)
    80006232:	e0a6                	sd	s1,64(sp)
    80006234:	e4aa                	sd	a0,72(sp)
    80006236:	e8ae                	sd	a1,80(sp)
    80006238:	ecb2                	sd	a2,88(sp)
    8000623a:	f0b6                	sd	a3,96(sp)
    8000623c:	f4ba                	sd	a4,104(sp)
    8000623e:	f8be                	sd	a5,112(sp)
    80006240:	fcc2                	sd	a6,120(sp)
    80006242:	e146                	sd	a7,128(sp)
    80006244:	e54a                	sd	s2,136(sp)
    80006246:	e94e                	sd	s3,144(sp)
    80006248:	ed52                	sd	s4,152(sp)
    8000624a:	f156                	sd	s5,160(sp)
    8000624c:	f55a                	sd	s6,168(sp)
    8000624e:	f95e                	sd	s7,176(sp)
    80006250:	fd62                	sd	s8,184(sp)
    80006252:	e1e6                	sd	s9,192(sp)
    80006254:	e5ea                	sd	s10,200(sp)
    80006256:	e9ee                	sd	s11,208(sp)
    80006258:	edf2                	sd	t3,216(sp)
    8000625a:	f1f6                	sd	t4,224(sp)
    8000625c:	f5fa                	sd	t5,232(sp)
    8000625e:	f9fe                	sd	t6,240(sp)
    80006260:	af7fc0ef          	jal	80002d56 <kerneltrap>
    80006264:	6082                	ld	ra,0(sp)
    80006266:	6122                	ld	sp,8(sp)
    80006268:	61c2                	ld	gp,16(sp)
    8000626a:	7282                	ld	t0,32(sp)
    8000626c:	7322                	ld	t1,40(sp)
    8000626e:	73c2                	ld	t2,48(sp)
    80006270:	7462                	ld	s0,56(sp)
    80006272:	6486                	ld	s1,64(sp)
    80006274:	6526                	ld	a0,72(sp)
    80006276:	65c6                	ld	a1,80(sp)
    80006278:	6666                	ld	a2,88(sp)
    8000627a:	7686                	ld	a3,96(sp)
    8000627c:	7726                	ld	a4,104(sp)
    8000627e:	77c6                	ld	a5,112(sp)
    80006280:	7866                	ld	a6,120(sp)
    80006282:	688a                	ld	a7,128(sp)
    80006284:	692a                	ld	s2,136(sp)
    80006286:	69ca                	ld	s3,144(sp)
    80006288:	6a6a                	ld	s4,152(sp)
    8000628a:	7a8a                	ld	s5,160(sp)
    8000628c:	7b2a                	ld	s6,168(sp)
    8000628e:	7bca                	ld	s7,176(sp)
    80006290:	7c6a                	ld	s8,184(sp)
    80006292:	6c8e                	ld	s9,192(sp)
    80006294:	6d2e                	ld	s10,200(sp)
    80006296:	6dce                	ld	s11,208(sp)
    80006298:	6e6e                	ld	t3,216(sp)
    8000629a:	7e8e                	ld	t4,224(sp)
    8000629c:	7f2e                	ld	t5,232(sp)
    8000629e:	7fce                	ld	t6,240(sp)
    800062a0:	6111                	addi	sp,sp,256
    800062a2:	10200073          	sret
    800062a6:	00000013          	nop
    800062aa:	00000013          	nop
    800062ae:	0001                	nop

00000000800062b0 <timervec>:
    800062b0:	34051573          	csrrw	a0,mscratch,a0
    800062b4:	e10c                	sd	a1,0(a0)
    800062b6:	e510                	sd	a2,8(a0)
    800062b8:	e914                	sd	a3,16(a0)
    800062ba:	6d0c                	ld	a1,24(a0)
    800062bc:	7110                	ld	a2,32(a0)
    800062be:	6194                	ld	a3,0(a1)
    800062c0:	96b2                	add	a3,a3,a2
    800062c2:	e194                	sd	a3,0(a1)
    800062c4:	4589                	li	a1,2
    800062c6:	14459073          	csrw	sip,a1
    800062ca:	6914                	ld	a3,16(a0)
    800062cc:	6510                	ld	a2,8(a0)
    800062ce:	610c                	ld	a1,0(a0)
    800062d0:	34051573          	csrrw	a0,mscratch,a0
    800062d4:	30200073          	mret
	...

00000000800062da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800062da:	1141                	addi	sp,sp,-16
    800062dc:	e422                	sd	s0,8(sp)
    800062de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062e0:	0c0007b7          	lui	a5,0xc000
    800062e4:	4705                	li	a4,1
    800062e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062e8:	0c0007b7          	lui	a5,0xc000
    800062ec:	c3d8                	sw	a4,4(a5)
}
    800062ee:	6422                	ld	s0,8(sp)
    800062f0:	0141                	addi	sp,sp,16
    800062f2:	8082                	ret

00000000800062f4 <plicinithart>:

void
plicinithart(void)
{
    800062f4:	1141                	addi	sp,sp,-16
    800062f6:	e406                	sd	ra,8(sp)
    800062f8:	e022                	sd	s0,0(sp)
    800062fa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062fc:	ffffb097          	auipc	ra,0xffffb
    80006300:	752080e7          	jalr	1874(ra) # 80001a4e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006304:	0085171b          	slliw	a4,a0,0x8
    80006308:	0c0027b7          	lui	a5,0xc002
    8000630c:	97ba                	add	a5,a5,a4
    8000630e:	40200713          	li	a4,1026
    80006312:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006316:	00d5151b          	slliw	a0,a0,0xd
    8000631a:	0c2017b7          	lui	a5,0xc201
    8000631e:	97aa                	add	a5,a5,a0
    80006320:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006324:	60a2                	ld	ra,8(sp)
    80006326:	6402                	ld	s0,0(sp)
    80006328:	0141                	addi	sp,sp,16
    8000632a:	8082                	ret

000000008000632c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000632c:	1141                	addi	sp,sp,-16
    8000632e:	e406                	sd	ra,8(sp)
    80006330:	e022                	sd	s0,0(sp)
    80006332:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006334:	ffffb097          	auipc	ra,0xffffb
    80006338:	71a080e7          	jalr	1818(ra) # 80001a4e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000633c:	00d5151b          	slliw	a0,a0,0xd
    80006340:	0c2017b7          	lui	a5,0xc201
    80006344:	97aa                	add	a5,a5,a0
  return irq;
}
    80006346:	43c8                	lw	a0,4(a5)
    80006348:	60a2                	ld	ra,8(sp)
    8000634a:	6402                	ld	s0,0(sp)
    8000634c:	0141                	addi	sp,sp,16
    8000634e:	8082                	ret

0000000080006350 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006350:	1101                	addi	sp,sp,-32
    80006352:	ec06                	sd	ra,24(sp)
    80006354:	e822                	sd	s0,16(sp)
    80006356:	e426                	sd	s1,8(sp)
    80006358:	1000                	addi	s0,sp,32
    8000635a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000635c:	ffffb097          	auipc	ra,0xffffb
    80006360:	6f2080e7          	jalr	1778(ra) # 80001a4e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006364:	00d5151b          	slliw	a0,a0,0xd
    80006368:	0c2017b7          	lui	a5,0xc201
    8000636c:	97aa                	add	a5,a5,a0
    8000636e:	c3c4                	sw	s1,4(a5)
}
    80006370:	60e2                	ld	ra,24(sp)
    80006372:	6442                	ld	s0,16(sp)
    80006374:	64a2                	ld	s1,8(sp)
    80006376:	6105                	addi	sp,sp,32
    80006378:	8082                	ret

000000008000637a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000637a:	1141                	addi	sp,sp,-16
    8000637c:	e406                	sd	ra,8(sp)
    8000637e:	e022                	sd	s0,0(sp)
    80006380:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006382:	479d                	li	a5,7
    80006384:	04a7cc63          	blt	a5,a0,800063dc <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006388:	00023797          	auipc	a5,0x23
    8000638c:	a1078793          	addi	a5,a5,-1520 # 80028d98 <disk>
    80006390:	97aa                	add	a5,a5,a0
    80006392:	0187c783          	lbu	a5,24(a5)
    80006396:	ebb9                	bnez	a5,800063ec <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006398:	00451693          	slli	a3,a0,0x4
    8000639c:	00023797          	auipc	a5,0x23
    800063a0:	9fc78793          	addi	a5,a5,-1540 # 80028d98 <disk>
    800063a4:	6398                	ld	a4,0(a5)
    800063a6:	9736                	add	a4,a4,a3
    800063a8:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800063ac:	6398                	ld	a4,0(a5)
    800063ae:	9736                	add	a4,a4,a3
    800063b0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800063b4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800063b8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800063bc:	97aa                	add	a5,a5,a0
    800063be:	4705                	li	a4,1
    800063c0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800063c4:	00023517          	auipc	a0,0x23
    800063c8:	9ec50513          	addi	a0,a0,-1556 # 80028db0 <disk+0x18>
    800063cc:	ffffc097          	auipc	ra,0xffffc
    800063d0:	f1e080e7          	jalr	-226(ra) # 800022ea <wakeup>
}
    800063d4:	60a2                	ld	ra,8(sp)
    800063d6:	6402                	ld	s0,0(sp)
    800063d8:	0141                	addi	sp,sp,16
    800063da:	8082                	ret
    panic("free_desc 1");
    800063dc:	00002517          	auipc	a0,0x2
    800063e0:	26450513          	addi	a0,a0,612 # 80008640 <etext+0x640>
    800063e4:	ffffa097          	auipc	ra,0xffffa
    800063e8:	17c080e7          	jalr	380(ra) # 80000560 <panic>
    panic("free_desc 2");
    800063ec:	00002517          	auipc	a0,0x2
    800063f0:	26450513          	addi	a0,a0,612 # 80008650 <etext+0x650>
    800063f4:	ffffa097          	auipc	ra,0xffffa
    800063f8:	16c080e7          	jalr	364(ra) # 80000560 <panic>

00000000800063fc <virtio_disk_init>:
{
    800063fc:	1101                	addi	sp,sp,-32
    800063fe:	ec06                	sd	ra,24(sp)
    80006400:	e822                	sd	s0,16(sp)
    80006402:	e426                	sd	s1,8(sp)
    80006404:	e04a                	sd	s2,0(sp)
    80006406:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006408:	00002597          	auipc	a1,0x2
    8000640c:	25858593          	addi	a1,a1,600 # 80008660 <etext+0x660>
    80006410:	00023517          	auipc	a0,0x23
    80006414:	ab050513          	addi	a0,a0,-1360 # 80028ec0 <disk+0x128>
    80006418:	ffffa097          	auipc	ra,0xffffa
    8000641c:	790080e7          	jalr	1936(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006420:	100017b7          	lui	a5,0x10001
    80006424:	4398                	lw	a4,0(a5)
    80006426:	2701                	sext.w	a4,a4
    80006428:	747277b7          	lui	a5,0x74727
    8000642c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006430:	18f71c63          	bne	a4,a5,800065c8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006434:	100017b7          	lui	a5,0x10001
    80006438:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000643a:	439c                	lw	a5,0(a5)
    8000643c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000643e:	4709                	li	a4,2
    80006440:	18e79463          	bne	a5,a4,800065c8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006444:	100017b7          	lui	a5,0x10001
    80006448:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000644a:	439c                	lw	a5,0(a5)
    8000644c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000644e:	16e79d63          	bne	a5,a4,800065c8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006452:	100017b7          	lui	a5,0x10001
    80006456:	47d8                	lw	a4,12(a5)
    80006458:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000645a:	554d47b7          	lui	a5,0x554d4
    8000645e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006462:	16f71363          	bne	a4,a5,800065c8 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006466:	100017b7          	lui	a5,0x10001
    8000646a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000646e:	4705                	li	a4,1
    80006470:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006472:	470d                	li	a4,3
    80006474:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006476:	10001737          	lui	a4,0x10001
    8000647a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000647c:	c7ffe737          	lui	a4,0xc7ffe
    80006480:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd5887>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006484:	8ef9                	and	a3,a3,a4
    80006486:	10001737          	lui	a4,0x10001
    8000648a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000648c:	472d                	li	a4,11
    8000648e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006490:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006494:	439c                	lw	a5,0(a5)
    80006496:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000649a:	8ba1                	andi	a5,a5,8
    8000649c:	12078e63          	beqz	a5,800065d8 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800064a0:	100017b7          	lui	a5,0x10001
    800064a4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800064a8:	100017b7          	lui	a5,0x10001
    800064ac:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800064b0:	439c                	lw	a5,0(a5)
    800064b2:	2781                	sext.w	a5,a5
    800064b4:	12079a63          	bnez	a5,800065e8 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800064b8:	100017b7          	lui	a5,0x10001
    800064bc:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800064c0:	439c                	lw	a5,0(a5)
    800064c2:	2781                	sext.w	a5,a5
  if(max == 0)
    800064c4:	12078a63          	beqz	a5,800065f8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    800064c8:	471d                	li	a4,7
    800064ca:	12f77f63          	bgeu	a4,a5,80006608 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    800064ce:	ffffa097          	auipc	ra,0xffffa
    800064d2:	67a080e7          	jalr	1658(ra) # 80000b48 <kalloc>
    800064d6:	00023497          	auipc	s1,0x23
    800064da:	8c248493          	addi	s1,s1,-1854 # 80028d98 <disk>
    800064de:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800064e0:	ffffa097          	auipc	ra,0xffffa
    800064e4:	668080e7          	jalr	1640(ra) # 80000b48 <kalloc>
    800064e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800064ea:	ffffa097          	auipc	ra,0xffffa
    800064ee:	65e080e7          	jalr	1630(ra) # 80000b48 <kalloc>
    800064f2:	87aa                	mv	a5,a0
    800064f4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800064f6:	6088                	ld	a0,0(s1)
    800064f8:	12050063          	beqz	a0,80006618 <virtio_disk_init+0x21c>
    800064fc:	00023717          	auipc	a4,0x23
    80006500:	8a473703          	ld	a4,-1884(a4) # 80028da0 <disk+0x8>
    80006504:	10070a63          	beqz	a4,80006618 <virtio_disk_init+0x21c>
    80006508:	10078863          	beqz	a5,80006618 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000650c:	6605                	lui	a2,0x1
    8000650e:	4581                	li	a1,0
    80006510:	ffffb097          	auipc	ra,0xffffb
    80006514:	824080e7          	jalr	-2012(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006518:	00023497          	auipc	s1,0x23
    8000651c:	88048493          	addi	s1,s1,-1920 # 80028d98 <disk>
    80006520:	6605                	lui	a2,0x1
    80006522:	4581                	li	a1,0
    80006524:	6488                	ld	a0,8(s1)
    80006526:	ffffb097          	auipc	ra,0xffffb
    8000652a:	80e080e7          	jalr	-2034(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    8000652e:	6605                	lui	a2,0x1
    80006530:	4581                	li	a1,0
    80006532:	6888                	ld	a0,16(s1)
    80006534:	ffffb097          	auipc	ra,0xffffb
    80006538:	800080e7          	jalr	-2048(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000653c:	100017b7          	lui	a5,0x10001
    80006540:	4721                	li	a4,8
    80006542:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006544:	4098                	lw	a4,0(s1)
    80006546:	100017b7          	lui	a5,0x10001
    8000654a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000654e:	40d8                	lw	a4,4(s1)
    80006550:	100017b7          	lui	a5,0x10001
    80006554:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006558:	649c                	ld	a5,8(s1)
    8000655a:	0007869b          	sext.w	a3,a5
    8000655e:	10001737          	lui	a4,0x10001
    80006562:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006566:	9781                	srai	a5,a5,0x20
    80006568:	10001737          	lui	a4,0x10001
    8000656c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006570:	689c                	ld	a5,16(s1)
    80006572:	0007869b          	sext.w	a3,a5
    80006576:	10001737          	lui	a4,0x10001
    8000657a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000657e:	9781                	srai	a5,a5,0x20
    80006580:	10001737          	lui	a4,0x10001
    80006584:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006588:	10001737          	lui	a4,0x10001
    8000658c:	4785                	li	a5,1
    8000658e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006590:	00f48c23          	sb	a5,24(s1)
    80006594:	00f48ca3          	sb	a5,25(s1)
    80006598:	00f48d23          	sb	a5,26(s1)
    8000659c:	00f48da3          	sb	a5,27(s1)
    800065a0:	00f48e23          	sb	a5,28(s1)
    800065a4:	00f48ea3          	sb	a5,29(s1)
    800065a8:	00f48f23          	sb	a5,30(s1)
    800065ac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800065b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800065b4:	100017b7          	lui	a5,0x10001
    800065b8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800065bc:	60e2                	ld	ra,24(sp)
    800065be:	6442                	ld	s0,16(sp)
    800065c0:	64a2                	ld	s1,8(sp)
    800065c2:	6902                	ld	s2,0(sp)
    800065c4:	6105                	addi	sp,sp,32
    800065c6:	8082                	ret
    panic("could not find virtio disk");
    800065c8:	00002517          	auipc	a0,0x2
    800065cc:	0a850513          	addi	a0,a0,168 # 80008670 <etext+0x670>
    800065d0:	ffffa097          	auipc	ra,0xffffa
    800065d4:	f90080e7          	jalr	-112(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    800065d8:	00002517          	auipc	a0,0x2
    800065dc:	0b850513          	addi	a0,a0,184 # 80008690 <etext+0x690>
    800065e0:	ffffa097          	auipc	ra,0xffffa
    800065e4:	f80080e7          	jalr	-128(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    800065e8:	00002517          	auipc	a0,0x2
    800065ec:	0c850513          	addi	a0,a0,200 # 800086b0 <etext+0x6b0>
    800065f0:	ffffa097          	auipc	ra,0xffffa
    800065f4:	f70080e7          	jalr	-144(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800065f8:	00002517          	auipc	a0,0x2
    800065fc:	0d850513          	addi	a0,a0,216 # 800086d0 <etext+0x6d0>
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	f60080e7          	jalr	-160(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006608:	00002517          	auipc	a0,0x2
    8000660c:	0e850513          	addi	a0,a0,232 # 800086f0 <etext+0x6f0>
    80006610:	ffffa097          	auipc	ra,0xffffa
    80006614:	f50080e7          	jalr	-176(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006618:	00002517          	auipc	a0,0x2
    8000661c:	0f850513          	addi	a0,a0,248 # 80008710 <etext+0x710>
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	f40080e7          	jalr	-192(ra) # 80000560 <panic>

0000000080006628 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006628:	7159                	addi	sp,sp,-112
    8000662a:	f486                	sd	ra,104(sp)
    8000662c:	f0a2                	sd	s0,96(sp)
    8000662e:	eca6                	sd	s1,88(sp)
    80006630:	e8ca                	sd	s2,80(sp)
    80006632:	e4ce                	sd	s3,72(sp)
    80006634:	e0d2                	sd	s4,64(sp)
    80006636:	fc56                	sd	s5,56(sp)
    80006638:	f85a                	sd	s6,48(sp)
    8000663a:	f45e                	sd	s7,40(sp)
    8000663c:	f062                	sd	s8,32(sp)
    8000663e:	ec66                	sd	s9,24(sp)
    80006640:	1880                	addi	s0,sp,112
    80006642:	8a2a                	mv	s4,a0
    80006644:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006646:	00c52c83          	lw	s9,12(a0)
    8000664a:	001c9c9b          	slliw	s9,s9,0x1
    8000664e:	1c82                	slli	s9,s9,0x20
    80006650:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006654:	00023517          	auipc	a0,0x23
    80006658:	86c50513          	addi	a0,a0,-1940 # 80028ec0 <disk+0x128>
    8000665c:	ffffa097          	auipc	ra,0xffffa
    80006660:	5dc080e7          	jalr	1500(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    80006664:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006666:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006668:	00022b17          	auipc	s6,0x22
    8000666c:	730b0b13          	addi	s6,s6,1840 # 80028d98 <disk>
  for(int i = 0; i < 3; i++){
    80006670:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006672:	00023c17          	auipc	s8,0x23
    80006676:	84ec0c13          	addi	s8,s8,-1970 # 80028ec0 <disk+0x128>
    8000667a:	a0ad                	j	800066e4 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000667c:	00fb0733          	add	a4,s6,a5
    80006680:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006684:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006686:	0207c563          	bltz	a5,800066b0 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000668a:	2905                	addiw	s2,s2,1
    8000668c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000668e:	05590f63          	beq	s2,s5,800066ec <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006692:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006694:	00022717          	auipc	a4,0x22
    80006698:	70470713          	addi	a4,a4,1796 # 80028d98 <disk>
    8000669c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000669e:	01874683          	lbu	a3,24(a4)
    800066a2:	fee9                	bnez	a3,8000667c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800066a4:	2785                	addiw	a5,a5,1
    800066a6:	0705                	addi	a4,a4,1
    800066a8:	fe979be3          	bne	a5,s1,8000669e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800066ac:	57fd                	li	a5,-1
    800066ae:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800066b0:	03205163          	blez	s2,800066d2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800066b4:	f9042503          	lw	a0,-112(s0)
    800066b8:	00000097          	auipc	ra,0x0
    800066bc:	cc2080e7          	jalr	-830(ra) # 8000637a <free_desc>
      for(int j = 0; j < i; j++)
    800066c0:	4785                	li	a5,1
    800066c2:	0127d863          	bge	a5,s2,800066d2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800066c6:	f9442503          	lw	a0,-108(s0)
    800066ca:	00000097          	auipc	ra,0x0
    800066ce:	cb0080e7          	jalr	-848(ra) # 8000637a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800066d2:	85e2                	mv	a1,s8
    800066d4:	00022517          	auipc	a0,0x22
    800066d8:	6dc50513          	addi	a0,a0,1756 # 80028db0 <disk+0x18>
    800066dc:	ffffc097          	auipc	ra,0xffffc
    800066e0:	baa080e7          	jalr	-1110(ra) # 80002286 <sleep>
  for(int i = 0; i < 3; i++){
    800066e4:	f9040613          	addi	a2,s0,-112
    800066e8:	894e                	mv	s2,s3
    800066ea:	b765                	j	80006692 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066ec:	f9042503          	lw	a0,-112(s0)
    800066f0:	00451693          	slli	a3,a0,0x4

  if(write)
    800066f4:	00022797          	auipc	a5,0x22
    800066f8:	6a478793          	addi	a5,a5,1700 # 80028d98 <disk>
    800066fc:	00a50713          	addi	a4,a0,10
    80006700:	0712                	slli	a4,a4,0x4
    80006702:	973e                	add	a4,a4,a5
    80006704:	01703633          	snez	a2,s7
    80006708:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000670a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000670e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006712:	6398                	ld	a4,0(a5)
    80006714:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006716:	0a868613          	addi	a2,a3,168
    8000671a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000671c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000671e:	6390                	ld	a2,0(a5)
    80006720:	00d605b3          	add	a1,a2,a3
    80006724:	4741                	li	a4,16
    80006726:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006728:	4805                	li	a6,1
    8000672a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000672e:	f9442703          	lw	a4,-108(s0)
    80006732:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006736:	0712                	slli	a4,a4,0x4
    80006738:	963a                	add	a2,a2,a4
    8000673a:	058a0593          	addi	a1,s4,88
    8000673e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006740:	0007b883          	ld	a7,0(a5)
    80006744:	9746                	add	a4,a4,a7
    80006746:	40000613          	li	a2,1024
    8000674a:	c710                	sw	a2,8(a4)
  if(write)
    8000674c:	001bb613          	seqz	a2,s7
    80006750:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006754:	00166613          	ori	a2,a2,1
    80006758:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000675c:	f9842583          	lw	a1,-104(s0)
    80006760:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006764:	00250613          	addi	a2,a0,2
    80006768:	0612                	slli	a2,a2,0x4
    8000676a:	963e                	add	a2,a2,a5
    8000676c:	577d                	li	a4,-1
    8000676e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006772:	0592                	slli	a1,a1,0x4
    80006774:	98ae                	add	a7,a7,a1
    80006776:	03068713          	addi	a4,a3,48
    8000677a:	973e                	add	a4,a4,a5
    8000677c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006780:	6398                	ld	a4,0(a5)
    80006782:	972e                	add	a4,a4,a1
    80006784:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006788:	4689                	li	a3,2
    8000678a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    8000678e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006792:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006796:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000679a:	6794                	ld	a3,8(a5)
    8000679c:	0026d703          	lhu	a4,2(a3)
    800067a0:	8b1d                	andi	a4,a4,7
    800067a2:	0706                	slli	a4,a4,0x1
    800067a4:	96ba                	add	a3,a3,a4
    800067a6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800067aa:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800067ae:	6798                	ld	a4,8(a5)
    800067b0:	00275783          	lhu	a5,2(a4)
    800067b4:	2785                	addiw	a5,a5,1
    800067b6:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800067ba:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800067be:	100017b7          	lui	a5,0x10001
    800067c2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800067c6:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800067ca:	00022917          	auipc	s2,0x22
    800067ce:	6f690913          	addi	s2,s2,1782 # 80028ec0 <disk+0x128>
  while(b->disk == 1) {
    800067d2:	4485                	li	s1,1
    800067d4:	01079c63          	bne	a5,a6,800067ec <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800067d8:	85ca                	mv	a1,s2
    800067da:	8552                	mv	a0,s4
    800067dc:	ffffc097          	auipc	ra,0xffffc
    800067e0:	aaa080e7          	jalr	-1366(ra) # 80002286 <sleep>
  while(b->disk == 1) {
    800067e4:	004a2783          	lw	a5,4(s4)
    800067e8:	fe9788e3          	beq	a5,s1,800067d8 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800067ec:	f9042903          	lw	s2,-112(s0)
    800067f0:	00290713          	addi	a4,s2,2
    800067f4:	0712                	slli	a4,a4,0x4
    800067f6:	00022797          	auipc	a5,0x22
    800067fa:	5a278793          	addi	a5,a5,1442 # 80028d98 <disk>
    800067fe:	97ba                	add	a5,a5,a4
    80006800:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006804:	00022997          	auipc	s3,0x22
    80006808:	59498993          	addi	s3,s3,1428 # 80028d98 <disk>
    8000680c:	00491713          	slli	a4,s2,0x4
    80006810:	0009b783          	ld	a5,0(s3)
    80006814:	97ba                	add	a5,a5,a4
    80006816:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000681a:	854a                	mv	a0,s2
    8000681c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006820:	00000097          	auipc	ra,0x0
    80006824:	b5a080e7          	jalr	-1190(ra) # 8000637a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006828:	8885                	andi	s1,s1,1
    8000682a:	f0ed                	bnez	s1,8000680c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000682c:	00022517          	auipc	a0,0x22
    80006830:	69450513          	addi	a0,a0,1684 # 80028ec0 <disk+0x128>
    80006834:	ffffa097          	auipc	ra,0xffffa
    80006838:	4b8080e7          	jalr	1208(ra) # 80000cec <release>
}
    8000683c:	70a6                	ld	ra,104(sp)
    8000683e:	7406                	ld	s0,96(sp)
    80006840:	64e6                	ld	s1,88(sp)
    80006842:	6946                	ld	s2,80(sp)
    80006844:	69a6                	ld	s3,72(sp)
    80006846:	6a06                	ld	s4,64(sp)
    80006848:	7ae2                	ld	s5,56(sp)
    8000684a:	7b42                	ld	s6,48(sp)
    8000684c:	7ba2                	ld	s7,40(sp)
    8000684e:	7c02                	ld	s8,32(sp)
    80006850:	6ce2                	ld	s9,24(sp)
    80006852:	6165                	addi	sp,sp,112
    80006854:	8082                	ret

0000000080006856 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006856:	1101                	addi	sp,sp,-32
    80006858:	ec06                	sd	ra,24(sp)
    8000685a:	e822                	sd	s0,16(sp)
    8000685c:	e426                	sd	s1,8(sp)
    8000685e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006860:	00022497          	auipc	s1,0x22
    80006864:	53848493          	addi	s1,s1,1336 # 80028d98 <disk>
    80006868:	00022517          	auipc	a0,0x22
    8000686c:	65850513          	addi	a0,a0,1624 # 80028ec0 <disk+0x128>
    80006870:	ffffa097          	auipc	ra,0xffffa
    80006874:	3c8080e7          	jalr	968(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006878:	100017b7          	lui	a5,0x10001
    8000687c:	53b8                	lw	a4,96(a5)
    8000687e:	8b0d                	andi	a4,a4,3
    80006880:	100017b7          	lui	a5,0x10001
    80006884:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006886:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000688a:	689c                	ld	a5,16(s1)
    8000688c:	0204d703          	lhu	a4,32(s1)
    80006890:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006894:	04f70863          	beq	a4,a5,800068e4 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006898:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000689c:	6898                	ld	a4,16(s1)
    8000689e:	0204d783          	lhu	a5,32(s1)
    800068a2:	8b9d                	andi	a5,a5,7
    800068a4:	078e                	slli	a5,a5,0x3
    800068a6:	97ba                	add	a5,a5,a4
    800068a8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068aa:	00278713          	addi	a4,a5,2
    800068ae:	0712                	slli	a4,a4,0x4
    800068b0:	9726                	add	a4,a4,s1
    800068b2:	01074703          	lbu	a4,16(a4)
    800068b6:	e721                	bnez	a4,800068fe <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800068b8:	0789                	addi	a5,a5,2
    800068ba:	0792                	slli	a5,a5,0x4
    800068bc:	97a6                	add	a5,a5,s1
    800068be:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800068c0:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800068c4:	ffffc097          	auipc	ra,0xffffc
    800068c8:	a26080e7          	jalr	-1498(ra) # 800022ea <wakeup>

    disk.used_idx += 1;
    800068cc:	0204d783          	lhu	a5,32(s1)
    800068d0:	2785                	addiw	a5,a5,1
    800068d2:	17c2                	slli	a5,a5,0x30
    800068d4:	93c1                	srli	a5,a5,0x30
    800068d6:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800068da:	6898                	ld	a4,16(s1)
    800068dc:	00275703          	lhu	a4,2(a4)
    800068e0:	faf71ce3          	bne	a4,a5,80006898 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    800068e4:	00022517          	auipc	a0,0x22
    800068e8:	5dc50513          	addi	a0,a0,1500 # 80028ec0 <disk+0x128>
    800068ec:	ffffa097          	auipc	ra,0xffffa
    800068f0:	400080e7          	jalr	1024(ra) # 80000cec <release>
}
    800068f4:	60e2                	ld	ra,24(sp)
    800068f6:	6442                	ld	s0,16(sp)
    800068f8:	64a2                	ld	s1,8(sp)
    800068fa:	6105                	addi	sp,sp,32
    800068fc:	8082                	ret
      panic("virtio_disk_intr status");
    800068fe:	00002517          	auipc	a0,0x2
    80006902:	e2a50513          	addi	a0,a0,-470 # 80008728 <etext+0x728>
    80006906:	ffffa097          	auipc	ra,0xffffa
    8000690a:	c5a080e7          	jalr	-934(ra) # 80000560 <panic>
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
