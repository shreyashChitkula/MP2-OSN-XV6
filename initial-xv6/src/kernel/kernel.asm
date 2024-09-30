
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	24013103          	ld	sp,576(sp) # 8000b240 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	25070713          	addi	a4,a4,592 # 8000b2a0 <timer_scratch>
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
    80000066:	fbe78793          	addi	a5,a5,-66 # 80006020 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd6c2f>
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
    8000012e:	46e080e7          	jalr	1134(ra) # 80002598 <either_copyin>
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
    80000190:	25450513          	addi	a0,a0,596 # 800133e0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	24448493          	addi	s1,s1,580 # 800133e0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	2d490913          	addi	s2,s2,724 # 80013478 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	88e080e7          	jalr	-1906(ra) # 80001a4a <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	21e080e7          	jalr	542(ra) # 800023e2 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	f5c080e7          	jalr	-164(ra) # 8000212e <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	1f870713          	addi	a4,a4,504 # 800133e0 <cons>
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
    8000021e:	328080e7          	jalr	808(ra) # 80002542 <either_copyout>
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
    8000023a:	1aa50513          	addi	a0,a0,426 # 800133e0 <cons>
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
    80000268:	20f72a23          	sw	a5,532(a4) # 80013478 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	16650513          	addi	a0,a0,358 # 800133e0 <cons>
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
    800002e6:	0fe50513          	addi	a0,a0,254 # 800133e0 <cons>
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
    8000030c:	2e6080e7          	jalr	742(ra) # 800025ee <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	0d050513          	addi	a0,a0,208 # 800133e0 <cons>
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
    80000336:	0ae70713          	addi	a4,a4,174 # 800133e0 <cons>
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
    80000360:	08478793          	addi	a5,a5,132 # 800133e0 <cons>
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
    8000038e:	0ee7a783          	lw	a5,238(a5) # 80013478 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	04070713          	addi	a4,a4,64 # 800133e0 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	03048493          	addi	s1,s1,48 # 800133e0 <cons>
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
    800003fa:	fea70713          	addi	a4,a4,-22 # 800133e0 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	06f72a23          	sw	a5,116(a4) # 80013480 <cons+0xa0>
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
    80000436:	fae78793          	addi	a5,a5,-82 # 800133e0 <cons>
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
    8000045a:	02c7a323          	sw	a2,38(a5) # 8001347c <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	01a50513          	addi	a0,a0,26 # 80013478 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	d2c080e7          	jalr	-724(ra) # 80002192 <wakeup>
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
    80000484:	f6050513          	addi	a0,a0,-160 # 800133e0 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00026797          	auipc	a5,0x26
    8000049c:	5a078793          	addi	a5,a5,1440 # 80026a38 <devsw>
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
    800004da:	25260613          	addi	a2,a2,594 # 80008728 <digits>
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
    80000570:	f207aa23          	sw	zero,-204(a5) # 800134a0 <pr+0x18>
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
    800005a4:	ccf72023          	sw	a5,-832(a4) # 8000b260 <panicked>
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
    800005ce:	ed6d2d03          	lw	s10,-298(s10) # 800134a0 <pr+0x18>
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
    8000060c:	120a8a93          	addi	s5,s5,288 # 80008728 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00013517          	auipc	a0,0x13
    8000061e:	e6e50513          	addi	a0,a0,-402 # 80013488 <pr>
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
    800007a4:	ce850513          	addi	a0,a0,-792 # 80013488 <pr>
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
    800007c0:	ccc48493          	addi	s1,s1,-820 # 80013488 <pr>
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
    8000082c:	c8050513          	addi	a0,a0,-896 # 800134a8 <uart_tx_lock>
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
    80000858:	a0c7a783          	lw	a5,-1524(a5) # 8000b260 <panicked>
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
    80000892:	9da7b783          	ld	a5,-1574(a5) # 8000b268 <uart_tx_r>
    80000896:	0000b717          	auipc	a4,0xb
    8000089a:	9da73703          	ld	a4,-1574(a4) # 8000b270 <uart_tx_w>
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
    800008c0:	beca8a93          	addi	s5,s5,-1044 # 800134a8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	0000b497          	auipc	s1,0xb
    800008c8:	9a448493          	addi	s1,s1,-1628 # 8000b268 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	0000b997          	auipc	s3,0xb
    800008d4:	9a098993          	addi	s3,s3,-1632 # 8000b270 <uart_tx_w>
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
    800008f6:	8a0080e7          	jalr	-1888(ra) # 80002192 <wakeup>
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
    80000934:	b7850513          	addi	a0,a0,-1160 # 800134a8 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	0000b797          	auipc	a5,0xb
    80000944:	9207a783          	lw	a5,-1760(a5) # 8000b260 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	0000b717          	auipc	a4,0xb
    8000094e:	92673703          	ld	a4,-1754(a4) # 8000b270 <uart_tx_w>
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	9167b783          	ld	a5,-1770(a5) # 8000b268 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00013997          	auipc	s3,0x13
    80000962:	b4a98993          	addi	s3,s3,-1206 # 800134a8 <uart_tx_lock>
    80000966:	0000b497          	auipc	s1,0xb
    8000096a:	90248493          	addi	s1,s1,-1790 # 8000b268 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	0000b917          	auipc	s2,0xb
    80000972:	90290913          	addi	s2,s2,-1790 # 8000b270 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00001097          	auipc	ra,0x1
    80000982:	7b0080e7          	jalr	1968(ra) # 8000212e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00013497          	auipc	s1,0x13
    80000998:	b1448493          	addi	s1,s1,-1260 # 800134a8 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	0000b797          	auipc	a5,0xb
    800009ac:	8ce7b423          	sd	a4,-1848(a5) # 8000b270 <uart_tx_w>
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
    80000a20:	a8c48493          	addi	s1,s1,-1396 # 800134a8 <uart_tx_lock>
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
    80000a5e:	00027797          	auipc	a5,0x27
    80000a62:	17278793          	addi	a5,a5,370 # 80027bd0 <end>
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
    80000a82:	a6290913          	addi	s2,s2,-1438 # 800134e0 <kmem>
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
    80000b20:	9c450513          	addi	a0,a0,-1596 # 800134e0 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00027517          	auipc	a0,0x27
    80000b34:	0a050513          	addi	a0,a0,160 # 80027bd0 <end>
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
    80000b56:	98e48493          	addi	s1,s1,-1650 # 800134e0 <kmem>
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
    80000b6e:	97650513          	addi	a0,a0,-1674 # 800134e0 <kmem>
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
    80000b9a:	94a50513          	addi	a0,a0,-1718 # 800134e0 <kmem>
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
    80000bd6:	e5c080e7          	jalr	-420(ra) # 80001a2e <mycpu>
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
    80000c08:	e2a080e7          	jalr	-470(ra) # 80001a2e <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e1e080e7          	jalr	-482(ra) # 80001a2e <mycpu>
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
    80000c2c:	e06080e7          	jalr	-506(ra) # 80001a2e <mycpu>
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
    80000c6c:	dc6080e7          	jalr	-570(ra) # 80001a2e <mycpu>
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
    80000c98:	d9a080e7          	jalr	-614(ra) # 80001a2e <mycpu>
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
    80000da8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd7431>
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
    80000ede:	b44080e7          	jalr	-1212(ra) # 80001a1e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	0000a717          	auipc	a4,0xa
    80000ee6:	39670713          	addi	a4,a4,918 # 8000b278 <started>
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
    80000efa:	b28080e7          	jalr	-1240(ra) # 80001a1e <cpuid>
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
    80000f1c:	9c2080e7          	jalr	-1598(ra) # 800028da <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	144080e7          	jalr	324(ra) # 80006064 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	054080e7          	jalr	84(ra) # 80001f7c <scheduler>
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
    80000f8c:	9d4080e7          	jalr	-1580(ra) # 8000195c <procinit>
    trapinit();      // trap vectors
    80000f90:	00002097          	auipc	ra,0x2
    80000f94:	922080e7          	jalr	-1758(ra) # 800028b2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	942080e7          	jalr	-1726(ra) # 800028da <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	0aa080e7          	jalr	170(ra) # 8000604a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	0bc080e7          	jalr	188(ra) # 80006064 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	18a080e7          	jalr	394(ra) # 8000313a <binit>
    iinit();         // inode table
    80000fb8:	00003097          	auipc	ra,0x3
    80000fbc:	840080e7          	jalr	-1984(ra) # 800037f8 <iinit>
    fileinit();      // file table
    80000fc0:	00003097          	auipc	ra,0x3
    80000fc4:	7f0080e7          	jalr	2032(ra) # 800047b0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	1a4080e7          	jalr	420(ra) # 8000616c <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	d78080e7          	jalr	-648(ra) # 80001d48 <userinit>
    __sync_synchronize();
    80000fd8:	0330000f          	fence	rw,rw
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	0000a717          	auipc	a4,0xa
    80000fe2:	28f72d23          	sw	a5,666(a4) # 8000b278 <started>
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
    80000ff6:	28e7b783          	ld	a5,654(a5) # 8000b280 <kernel_pagetable>
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
    80001070:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd7427>
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
    800012b2:	fca7b923          	sd	a0,-46(a5) # 8000b280 <kernel_pagetable>
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
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd7430>
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
    800018d2:	06248493          	addi	s1,s1,98 # 80013930 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018d6:	8b26                	mv	s6,s1
    800018d8:	0193d937          	lui	s2,0x193d
    800018dc:	4bb90913          	addi	s2,s2,1211 # 193d4bb <_entry-0x7e6c2b45>
    800018e0:	0932                	slli	s2,s2,0xc
    800018e2:	7e390913          	addi	s2,s2,2019
    800018e6:	0932                	slli	s2,s2,0xc
    800018e8:	27b90913          	addi	s2,s2,635
    800018ec:	0932                	slli	s2,s2,0xc
    800018ee:	97790913          	addi	s2,s2,-1673
    800018f2:	040009b7          	lui	s3,0x4000
    800018f6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f8:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800018fa:	0001ba97          	auipc	s5,0x1b
    800018fe:	e36a8a93          	addi	s5,s5,-458 # 8001c730 <tickslock>
    char *pa = kalloc();
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	246080e7          	jalr	582(ra) # 80000b48 <kalloc>
    8000190a:	862a                	mv	a2,a0
    if (pa == 0)
    8000190c:	c121                	beqz	a0,8000194c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int)(p - proc));
    8000190e:	416485b3          	sub	a1,s1,s6
    80001912:	858d                	srai	a1,a1,0x3
    80001914:	032585b3          	mul	a1,a1,s2
    80001918:	2585                	addiw	a1,a1,1
    8000191a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191e:	4719                	li	a4,6
    80001920:	6685                	lui	a3,0x1
    80001922:	40b985b3          	sub	a1,s3,a1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	870080e7          	jalr	-1936(ra) # 80001198 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001930:	23848493          	addi	s1,s1,568
    80001934:	fd5497e3          	bne	s1,s5,80001902 <proc_mapstacks+0x4a>
  }
}
    80001938:	70e2                	ld	ra,56(sp)
    8000193a:	7442                	ld	s0,48(sp)
    8000193c:	74a2                	ld	s1,40(sp)
    8000193e:	7902                	ld	s2,32(sp)
    80001940:	69e2                	ld	s3,24(sp)
    80001942:	6a42                	ld	s4,16(sp)
    80001944:	6aa2                	ld	s5,8(sp)
    80001946:	6b02                	ld	s6,0(sp)
    80001948:	6121                	addi	sp,sp,64
    8000194a:	8082                	ret
      panic("kalloc");
    8000194c:	00007517          	auipc	a0,0x7
    80001950:	86c50513          	addi	a0,a0,-1940 # 800081b8 <etext+0x1b8>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	c0c080e7          	jalr	-1012(ra) # 80000560 <panic>

000000008000195c <procinit>:

// initialize the proc table.
void procinit(void)
{
    8000195c:	7139                	addi	sp,sp,-64
    8000195e:	fc06                	sd	ra,56(sp)
    80001960:	f822                	sd	s0,48(sp)
    80001962:	f426                	sd	s1,40(sp)
    80001964:	f04a                	sd	s2,32(sp)
    80001966:	ec4e                	sd	s3,24(sp)
    80001968:	e852                	sd	s4,16(sp)
    8000196a:	e456                	sd	s5,8(sp)
    8000196c:	e05a                	sd	s6,0(sp)
    8000196e:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001970:	00007597          	auipc	a1,0x7
    80001974:	85058593          	addi	a1,a1,-1968 # 800081c0 <etext+0x1c0>
    80001978:	00012517          	auipc	a0,0x12
    8000197c:	b8850513          	addi	a0,a0,-1144 # 80013500 <pid_lock>
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	228080e7          	jalr	552(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001988:	00007597          	auipc	a1,0x7
    8000198c:	84058593          	addi	a1,a1,-1984 # 800081c8 <etext+0x1c8>
    80001990:	00012517          	auipc	a0,0x12
    80001994:	b8850513          	addi	a0,a0,-1144 # 80013518 <wait_lock>
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	210080e7          	jalr	528(ra) # 80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    800019a0:	00012497          	auipc	s1,0x12
    800019a4:	f9048493          	addi	s1,s1,-112 # 80013930 <proc>
  {
    initlock(&p->lock, "proc");
    800019a8:	00007b17          	auipc	s6,0x7
    800019ac:	830b0b13          	addi	s6,s6,-2000 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800019b0:	8aa6                	mv	s5,s1
    800019b2:	0193d937          	lui	s2,0x193d
    800019b6:	4bb90913          	addi	s2,s2,1211 # 193d4bb <_entry-0x7e6c2b45>
    800019ba:	0932                	slli	s2,s2,0xc
    800019bc:	7e390913          	addi	s2,s2,2019
    800019c0:	0932                	slli	s2,s2,0xc
    800019c2:	27b90913          	addi	s2,s2,635
    800019c6:	0932                	slli	s2,s2,0xc
    800019c8:	97790913          	addi	s2,s2,-1673
    800019cc:	040009b7          	lui	s3,0x4000
    800019d0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019d4:	0001ba17          	auipc	s4,0x1b
    800019d8:	d5ca0a13          	addi	s4,s4,-676 # 8001c730 <tickslock>
    initlock(&p->lock, "proc");
    800019dc:	85da                	mv	a1,s6
    800019de:	8526                	mv	a0,s1
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	1c8080e7          	jalr	456(ra) # 80000ba8 <initlock>
    p->state = UNUSED;
    800019e8:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800019ec:	415487b3          	sub	a5,s1,s5
    800019f0:	878d                	srai	a5,a5,0x3
    800019f2:	032787b3          	mul	a5,a5,s2
    800019f6:	2785                	addiw	a5,a5,1
    800019f8:	00d7979b          	slliw	a5,a5,0xd
    800019fc:	40f987b3          	sub	a5,s3,a5
    80001a00:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001a02:	23848493          	addi	s1,s1,568
    80001a06:	fd449be3          	bne	s1,s4,800019dc <procinit+0x80>
  }
}
    80001a0a:	70e2                	ld	ra,56(sp)
    80001a0c:	7442                	ld	s0,48(sp)
    80001a0e:	74a2                	ld	s1,40(sp)
    80001a10:	7902                	ld	s2,32(sp)
    80001a12:	69e2                	ld	s3,24(sp)
    80001a14:	6a42                	ld	s4,16(sp)
    80001a16:	6aa2                	ld	s5,8(sp)
    80001a18:	6b02                	ld	s6,0(sp)
    80001a1a:	6121                	addi	sp,sp,64
    80001a1c:	8082                	ret

0000000080001a1e <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001a1e:	1141                	addi	sp,sp,-16
    80001a20:	e422                	sd	s0,8(sp)
    80001a22:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a24:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a26:	2501                	sext.w	a0,a0
    80001a28:	6422                	ld	s0,8(sp)
    80001a2a:	0141                	addi	sp,sp,16
    80001a2c:	8082                	ret

0000000080001a2e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001a2e:	1141                	addi	sp,sp,-16
    80001a30:	e422                	sd	s0,8(sp)
    80001a32:	0800                	addi	s0,sp,16
    80001a34:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a36:	2781                	sext.w	a5,a5
    80001a38:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a3a:	00012517          	auipc	a0,0x12
    80001a3e:	af650513          	addi	a0,a0,-1290 # 80013530 <cpus>
    80001a42:	953e                	add	a0,a0,a5
    80001a44:	6422                	ld	s0,8(sp)
    80001a46:	0141                	addi	sp,sp,16
    80001a48:	8082                	ret

0000000080001a4a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001a4a:	1101                	addi	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	1000                	addi	s0,sp,32
  push_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	198080e7          	jalr	408(ra) # 80000bec <push_off>
    80001a5c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a5e:	2781                	sext.w	a5,a5
    80001a60:	079e                	slli	a5,a5,0x7
    80001a62:	00012717          	auipc	a4,0x12
    80001a66:	a9e70713          	addi	a4,a4,-1378 # 80013500 <pid_lock>
    80001a6a:	97ba                	add	a5,a5,a4
    80001a6c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	21e080e7          	jalr	542(ra) # 80000c8c <pop_off>
  return p;
}
    80001a76:	8526                	mv	a0,s1
    80001a78:	60e2                	ld	ra,24(sp)
    80001a7a:	6442                	ld	s0,16(sp)
    80001a7c:	64a2                	ld	s1,8(sp)
    80001a7e:	6105                	addi	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001a82:	1141                	addi	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	fc0080e7          	jalr	-64(ra) # 80001a4a <myproc>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	25a080e7          	jalr	602(ra) # 80000cec <release>

  if (first)
    80001a9a:	00009797          	auipc	a5,0x9
    80001a9e:	7567a783          	lw	a5,1878(a5) # 8000b1f0 <first.1>
    80001aa2:	eb89                	bnez	a5,80001ab4 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	e4e080e7          	jalr	-434(ra) # 800028f2 <usertrapret>
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	addi	sp,sp,16
    80001ab2:	8082                	ret
    first = 0;
    80001ab4:	00009797          	auipc	a5,0x9
    80001ab8:	7207ae23          	sw	zero,1852(a5) # 8000b1f0 <first.1>
    fsinit(ROOTDEV);
    80001abc:	4505                	li	a0,1
    80001abe:	00002097          	auipc	ra,0x2
    80001ac2:	cba080e7          	jalr	-838(ra) # 80003778 <fsinit>
    80001ac6:	bff9                	j	80001aa4 <forkret+0x22>

0000000080001ac8 <allocpid>:
{
    80001ac8:	1101                	addi	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ad4:	00012917          	auipc	s2,0x12
    80001ad8:	a2c90913          	addi	s2,s2,-1492 # 80013500 <pid_lock>
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	15a080e7          	jalr	346(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001ae6:	00009797          	auipc	a5,0x9
    80001aea:	70e78793          	addi	a5,a5,1806 # 8000b1f4 <nextpid>
    80001aee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af0:	0014871b          	addiw	a4,s1,1
    80001af4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af6:	854a                	mv	a0,s2
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	1f4080e7          	jalr	500(ra) # 80000cec <release>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	addi	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <proc_pagetable>:
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	addi	s0,sp,32
    80001b1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	876080e7          	jalr	-1930(ra) # 80001392 <uvmcreate>
    80001b24:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b26:	c121                	beqz	a0,80001b66 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b28:	4729                	li	a4,10
    80001b2a:	00005697          	auipc	a3,0x5
    80001b2e:	4d668693          	addi	a3,a3,1238 # 80007000 <_trampoline>
    80001b32:	6605                	lui	a2,0x1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3a:	05b2                	slli	a1,a1,0xc
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	5bc080e7          	jalr	1468(ra) # 800010f8 <mappages>
    80001b44:	02054863          	bltz	a0,80001b74 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b48:	4719                	li	a4,6
    80001b4a:	05893683          	ld	a3,88(s2)
    80001b4e:	6605                	lui	a2,0x1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b56:	05b6                	slli	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	59e080e7          	jalr	1438(ra) # 800010f8 <mappages>
    80001b62:	02054163          	bltz	a0,80001b84 <proc_pagetable+0x76>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a2c080e7          	jalr	-1492(ra) # 800015a4 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7d5                	j	80001b66 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	05b2                	slli	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	72c080e7          	jalr	1836(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001b9a:	4581                	li	a1,0
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	a06080e7          	jalr	-1530(ra) # 800015a4 <uvmfree>
    return 0;
    80001ba6:	4481                	li	s1,0
    80001ba8:	bf7d                	j	80001b66 <proc_pagetable+0x58>

0000000080001baa <proc_freepagetable>:
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	addi	s0,sp,32
    80001bb6:	84aa                	mv	s1,a0
    80001bb8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	040005b7          	lui	a1,0x4000
    80001bc2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bc4:	05b2                	slli	a1,a1,0xc
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	6f8080e7          	jalr	1784(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	020005b7          	lui	a1,0x2000
    80001bd6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bd8:	05b6                	slli	a1,a1,0xd
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	6e2080e7          	jalr	1762(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001be4:	85ca                	mv	a1,s2
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	9bc080e7          	jalr	-1604(ra) # 800015a4 <uvmfree>
}
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <freeproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	addi	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c08:	6d28                	ld	a0,88(a0)
    80001c0a:	c509                	beqz	a0,80001c14 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	e3e080e7          	jalr	-450(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c14:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c18:	68a8                	ld	a0,80(s1)
    80001c1a:	c511                	beqz	a0,80001c26 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1c:	64ac                	ld	a1,72(s1)
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	f8c080e7          	jalr	-116(ra) # 80001baa <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001c60:	00012497          	auipc	s1,0x12
    80001c64:	cd048493          	addi	s1,s1,-816 # 80013930 <proc>
    80001c68:	0001b917          	auipc	s2,0x1b
    80001c6c:	ac890913          	addi	s2,s2,-1336 # 8001c730 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	fc6080e7          	jalr	-58(ra) # 80000c38 <acquire>
    if (p->state == UNUSED)
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	06c080e7          	jalr	108(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c88:	23848493          	addi	s1,s1,568
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a8a5                	j	80001d0a <allocproc+0xb6>
  p->pid = allocpid();
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e34080e7          	jalr	-460(ra) # 80001ac8 <allocpid>
    80001c9c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c9e:	4785                	li	a5,1
    80001ca0:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	ea6080e7          	jalr	-346(ra) # 80000b48 <kalloc>
    80001caa:	892a                	mv	s2,a0
    80001cac:	eca8                	sd	a0,88(s1)
    80001cae:	c52d                	beqz	a0,80001d18 <allocproc+0xc4>
  p->pagetable = proc_pagetable(p);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	e5c080e7          	jalr	-420(ra) # 80001b0e <proc_pagetable>
    80001cba:	892a                	mv	s2,a0
    80001cbc:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001cbe:	c92d                	beqz	a0,80001d30 <allocproc+0xdc>
  memset(&p->context, 0, sizeof(p->context));
    80001cc0:	07000613          	li	a2,112
    80001cc4:	4581                	li	a1,0
    80001cc6:	06048513          	addi	a0,s1,96
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	06a080e7          	jalr	106(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001cd2:	00000797          	auipc	a5,0x0
    80001cd6:	db078793          	addi	a5,a5,-592 # 80001a82 <forkret>
    80001cda:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cdc:	60bc                	ld	a5,64(s1)
    80001cde:	6705                	lui	a4,0x1
    80001ce0:	97ba                	add	a5,a5,a4
    80001ce2:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001ce4:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001ce8:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001cec:	00009797          	auipc	a5,0x9
    80001cf0:	5a47a783          	lw	a5,1444(a5) # 8000b290 <ticks>
    80001cf4:	16f4a623          	sw	a5,364(s1)
  memset(&p->syscall_counts, 0, sizeof(p->syscall_counts));
    80001cf8:	0c000613          	li	a2,192
    80001cfc:	4581                	li	a1,0
    80001cfe:	17848513          	addi	a0,s1,376
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	032080e7          	jalr	50(ra) # 80000d34 <memset>
}
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6902                	ld	s2,0(sp)
    80001d14:	6105                	addi	sp,sp,32
    80001d16:	8082                	ret
    freeproc(p);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	00000097          	auipc	ra,0x0
    80001d1e:	ee2080e7          	jalr	-286(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d22:	8526                	mv	a0,s1
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	fc8080e7          	jalr	-56(ra) # 80000cec <release>
    return 0;
    80001d2c:	84ca                	mv	s1,s2
    80001d2e:	bff1                	j	80001d0a <allocproc+0xb6>
    freeproc(p);
    80001d30:	8526                	mv	a0,s1
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	eca080e7          	jalr	-310(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	fb0080e7          	jalr	-80(ra) # 80000cec <release>
    return 0;
    80001d44:	84ca                	mv	s1,s2
    80001d46:	b7d1                	j	80001d0a <allocproc+0xb6>

0000000080001d48 <userinit>:
{
    80001d48:	1101                	addi	sp,sp,-32
    80001d4a:	ec06                	sd	ra,24(sp)
    80001d4c:	e822                	sd	s0,16(sp)
    80001d4e:	e426                	sd	s1,8(sp)
    80001d50:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d52:	00000097          	auipc	ra,0x0
    80001d56:	f02080e7          	jalr	-254(ra) # 80001c54 <allocproc>
    80001d5a:	84aa                	mv	s1,a0
  initproc = p;
    80001d5c:	00009797          	auipc	a5,0x9
    80001d60:	52a7b623          	sd	a0,1324(a5) # 8000b288 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d64:	03400613          	li	a2,52
    80001d68:	00009597          	auipc	a1,0x9
    80001d6c:	49858593          	addi	a1,a1,1176 # 8000b200 <initcode>
    80001d70:	6928                	ld	a0,80(a0)
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	64e080e7          	jalr	1614(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001d7a:	6785                	lui	a5,0x1
    80001d7c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d7e:	6cb8                	ld	a4,88(s1)
    80001d80:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d84:	6cb8                	ld	a4,88(s1)
    80001d86:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d88:	4641                	li	a2,16
    80001d8a:	00006597          	auipc	a1,0x6
    80001d8e:	45658593          	addi	a1,a1,1110 # 800081e0 <etext+0x1e0>
    80001d92:	15848513          	addi	a0,s1,344
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	0e0080e7          	jalr	224(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001d9e:	00006517          	auipc	a0,0x6
    80001da2:	45250513          	addi	a0,a0,1106 # 800081f0 <etext+0x1f0>
    80001da6:	00002097          	auipc	ra,0x2
    80001daa:	424080e7          	jalr	1060(ra) # 800041ca <namei>
    80001dae:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001db2:	478d                	li	a5,3
    80001db4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001db6:	8526                	mv	a0,s1
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	f34080e7          	jalr	-204(ra) # 80000cec <release>
}
    80001dc0:	60e2                	ld	ra,24(sp)
    80001dc2:	6442                	ld	s0,16(sp)
    80001dc4:	64a2                	ld	s1,8(sp)
    80001dc6:	6105                	addi	sp,sp,32
    80001dc8:	8082                	ret

0000000080001dca <growproc>:
{
    80001dca:	1101                	addi	sp,sp,-32
    80001dcc:	ec06                	sd	ra,24(sp)
    80001dce:	e822                	sd	s0,16(sp)
    80001dd0:	e426                	sd	s1,8(sp)
    80001dd2:	e04a                	sd	s2,0(sp)
    80001dd4:	1000                	addi	s0,sp,32
    80001dd6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001dd8:	00000097          	auipc	ra,0x0
    80001ddc:	c72080e7          	jalr	-910(ra) # 80001a4a <myproc>
    80001de0:	84aa                	mv	s1,a0
  sz = p->sz;
    80001de2:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001de4:	01204c63          	bgtz	s2,80001dfc <growproc+0x32>
  else if (n < 0)
    80001de8:	02094663          	bltz	s2,80001e14 <growproc+0x4a>
  p->sz = sz;
    80001dec:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dee:	4501                	li	a0,0
}
    80001df0:	60e2                	ld	ra,24(sp)
    80001df2:	6442                	ld	s0,16(sp)
    80001df4:	64a2                	ld	s1,8(sp)
    80001df6:	6902                	ld	s2,0(sp)
    80001df8:	6105                	addi	sp,sp,32
    80001dfa:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001dfc:	4691                	li	a3,4
    80001dfe:	00b90633          	add	a2,s2,a1
    80001e02:	6928                	ld	a0,80(a0)
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	676080e7          	jalr	1654(ra) # 8000147a <uvmalloc>
    80001e0c:	85aa                	mv	a1,a0
    80001e0e:	fd79                	bnez	a0,80001dec <growproc+0x22>
      return -1;
    80001e10:	557d                	li	a0,-1
    80001e12:	bff9                	j	80001df0 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e14:	00b90633          	add	a2,s2,a1
    80001e18:	6928                	ld	a0,80(a0)
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	618080e7          	jalr	1560(ra) # 80001432 <uvmdealloc>
    80001e22:	85aa                	mv	a1,a0
    80001e24:	b7e1                	j	80001dec <growproc+0x22>

0000000080001e26 <fork>:
{
    80001e26:	7139                	addi	sp,sp,-64
    80001e28:	fc06                	sd	ra,56(sp)
    80001e2a:	f822                	sd	s0,48(sp)
    80001e2c:	f04a                	sd	s2,32(sp)
    80001e2e:	e456                	sd	s5,8(sp)
    80001e30:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e32:	00000097          	auipc	ra,0x0
    80001e36:	c18080e7          	jalr	-1000(ra) # 80001a4a <myproc>
    80001e3a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	e18080e7          	jalr	-488(ra) # 80001c54 <allocproc>
    80001e44:	12050a63          	beqz	a0,80001f78 <fork+0x152>
    80001e48:	ec4e                	sd	s3,24(sp)
    80001e4a:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e4c:	048ab603          	ld	a2,72(s5)
    80001e50:	692c                	ld	a1,80(a0)
    80001e52:	050ab503          	ld	a0,80(s5)
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	788080e7          	jalr	1928(ra) # 800015de <uvmcopy>
    80001e5e:	04054a63          	bltz	a0,80001eb2 <fork+0x8c>
    80001e62:	f426                	sd	s1,40(sp)
    80001e64:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001e66:	048ab783          	ld	a5,72(s5)
    80001e6a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e6e:	058ab683          	ld	a3,88(s5)
    80001e72:	87b6                	mv	a5,a3
    80001e74:	0589b703          	ld	a4,88(s3)
    80001e78:	12068693          	addi	a3,a3,288
    80001e7c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e80:	6788                	ld	a0,8(a5)
    80001e82:	6b8c                	ld	a1,16(a5)
    80001e84:	6f90                	ld	a2,24(a5)
    80001e86:	01073023          	sd	a6,0(a4)
    80001e8a:	e708                	sd	a0,8(a4)
    80001e8c:	eb0c                	sd	a1,16(a4)
    80001e8e:	ef10                	sd	a2,24(a4)
    80001e90:	02078793          	addi	a5,a5,32
    80001e94:	02070713          	addi	a4,a4,32
    80001e98:	fed792e3          	bne	a5,a3,80001e7c <fork+0x56>
  np->trapframe->a0 = 0;
    80001e9c:	0589b783          	ld	a5,88(s3)
    80001ea0:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ea4:	0d0a8493          	addi	s1,s5,208
    80001ea8:	0d098913          	addi	s2,s3,208
    80001eac:	150a8a13          	addi	s4,s5,336
    80001eb0:	a015                	j	80001ed4 <fork+0xae>
    freeproc(np);
    80001eb2:	854e                	mv	a0,s3
    80001eb4:	00000097          	auipc	ra,0x0
    80001eb8:	d48080e7          	jalr	-696(ra) # 80001bfc <freeproc>
    release(&np->lock);
    80001ebc:	854e                	mv	a0,s3
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	e2e080e7          	jalr	-466(ra) # 80000cec <release>
    return -1;
    80001ec6:	597d                	li	s2,-1
    80001ec8:	69e2                	ld	s3,24(sp)
    80001eca:	a045                	j	80001f6a <fork+0x144>
  for (i = 0; i < NOFILE; i++)
    80001ecc:	04a1                	addi	s1,s1,8
    80001ece:	0921                	addi	s2,s2,8
    80001ed0:	01448b63          	beq	s1,s4,80001ee6 <fork+0xc0>
    if (p->ofile[i])
    80001ed4:	6088                	ld	a0,0(s1)
    80001ed6:	d97d                	beqz	a0,80001ecc <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ed8:	00003097          	auipc	ra,0x3
    80001edc:	96a080e7          	jalr	-1686(ra) # 80004842 <filedup>
    80001ee0:	00a93023          	sd	a0,0(s2)
    80001ee4:	b7e5                	j	80001ecc <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ee6:	150ab503          	ld	a0,336(s5)
    80001eea:	00002097          	auipc	ra,0x2
    80001eee:	ad4080e7          	jalr	-1324(ra) # 800039be <idup>
    80001ef2:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ef6:	4641                	li	a2,16
    80001ef8:	158a8593          	addi	a1,s5,344
    80001efc:	15898513          	addi	a0,s3,344
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	f76080e7          	jalr	-138(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001f08:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f0c:	854e                	mv	a0,s3
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	dde080e7          	jalr	-546(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001f16:	00011497          	auipc	s1,0x11
    80001f1a:	60248493          	addi	s1,s1,1538 # 80013518 <wait_lock>
    80001f1e:	8526                	mv	a0,s1
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	d18080e7          	jalr	-744(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f28:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	fffff097          	auipc	ra,0xfffff
    80001f32:	dbe080e7          	jalr	-578(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f36:	854e                	mv	a0,s3
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	d00080e7          	jalr	-768(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001f40:	478d                	li	a5,3
    80001f42:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f46:	854e                	mv	a0,s3
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	da4080e7          	jalr	-604(ra) # 80000cec <release>
  memmove(&np->syscall_counts, &p->syscall_counts, sizeof(p->syscall_counts));
    80001f50:	0c000613          	li	a2,192
    80001f54:	178a8593          	addi	a1,s5,376
    80001f58:	17898513          	addi	a0,s3,376
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	e34080e7          	jalr	-460(ra) # 80000d90 <memmove>
  return pid;
    80001f64:	74a2                	ld	s1,40(sp)
    80001f66:	69e2                	ld	s3,24(sp)
    80001f68:	6a42                	ld	s4,16(sp)
}
    80001f6a:	854a                	mv	a0,s2
    80001f6c:	70e2                	ld	ra,56(sp)
    80001f6e:	7442                	ld	s0,48(sp)
    80001f70:	7902                	ld	s2,32(sp)
    80001f72:	6aa2                	ld	s5,8(sp)
    80001f74:	6121                	addi	sp,sp,64
    80001f76:	8082                	ret
    return -1;
    80001f78:	597d                	li	s2,-1
    80001f7a:	bfc5                	j	80001f6a <fork+0x144>

0000000080001f7c <scheduler>:
{
    80001f7c:	7139                	addi	sp,sp,-64
    80001f7e:	fc06                	sd	ra,56(sp)
    80001f80:	f822                	sd	s0,48(sp)
    80001f82:	f426                	sd	s1,40(sp)
    80001f84:	f04a                	sd	s2,32(sp)
    80001f86:	ec4e                	sd	s3,24(sp)
    80001f88:	e852                	sd	s4,16(sp)
    80001f8a:	e456                	sd	s5,8(sp)
    80001f8c:	e05a                	sd	s6,0(sp)
    80001f8e:	0080                	addi	s0,sp,64
    80001f90:	8792                	mv	a5,tp
  int id = r_tp();
    80001f92:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f94:	00779a93          	slli	s5,a5,0x7
    80001f98:	00011717          	auipc	a4,0x11
    80001f9c:	56870713          	addi	a4,a4,1384 # 80013500 <pid_lock>
    80001fa0:	9756                	add	a4,a4,s5
    80001fa2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fa6:	00011717          	auipc	a4,0x11
    80001faa:	59270713          	addi	a4,a4,1426 # 80013538 <cpus+0x8>
    80001fae:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001fb0:	498d                	li	s3,3
        p->state = RUNNING;
    80001fb2:	4b11                	li	s6,4
        c->proc = p;
    80001fb4:	079e                	slli	a5,a5,0x7
    80001fb6:	00011a17          	auipc	s4,0x11
    80001fba:	54aa0a13          	addi	s4,s4,1354 # 80013500 <pid_lock>
    80001fbe:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001fc0:	0001a917          	auipc	s2,0x1a
    80001fc4:	77090913          	addi	s2,s2,1904 # 8001c730 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fcc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fd0:	10079073          	csrw	sstatus,a5
    80001fd4:	00012497          	auipc	s1,0x12
    80001fd8:	95c48493          	addi	s1,s1,-1700 # 80013930 <proc>
    80001fdc:	a811                	j	80001ff0 <scheduler+0x74>
      release(&p->lock);
    80001fde:	8526                	mv	a0,s1
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	d0c080e7          	jalr	-756(ra) # 80000cec <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001fe8:	23848493          	addi	s1,s1,568
    80001fec:	fd248ee3          	beq	s1,s2,80001fc8 <scheduler+0x4c>
      acquire(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	c46080e7          	jalr	-954(ra) # 80000c38 <acquire>
      if (p->state == RUNNABLE)
    80001ffa:	4c9c                	lw	a5,24(s1)
    80001ffc:	ff3791e3          	bne	a5,s3,80001fde <scheduler+0x62>
        p->state = RUNNING;
    80002000:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002004:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002008:	06048593          	addi	a1,s1,96
    8000200c:	8556                	mv	a0,s5
    8000200e:	00001097          	auipc	ra,0x1
    80002012:	83a080e7          	jalr	-1990(ra) # 80002848 <swtch>
        c->proc = 0;
    80002016:	020a3823          	sd	zero,48(s4)
    8000201a:	b7d1                	j	80001fde <scheduler+0x62>

000000008000201c <sched>:
{
    8000201c:	7179                	addi	sp,sp,-48
    8000201e:	f406                	sd	ra,40(sp)
    80002020:	f022                	sd	s0,32(sp)
    80002022:	ec26                	sd	s1,24(sp)
    80002024:	e84a                	sd	s2,16(sp)
    80002026:	e44e                	sd	s3,8(sp)
    80002028:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000202a:	00000097          	auipc	ra,0x0
    8000202e:	a20080e7          	jalr	-1504(ra) # 80001a4a <myproc>
    80002032:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	b8a080e7          	jalr	-1142(ra) # 80000bbe <holding>
    8000203c:	c93d                	beqz	a0,800020b2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000203e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002040:	2781                	sext.w	a5,a5
    80002042:	079e                	slli	a5,a5,0x7
    80002044:	00011717          	auipc	a4,0x11
    80002048:	4bc70713          	addi	a4,a4,1212 # 80013500 <pid_lock>
    8000204c:	97ba                	add	a5,a5,a4
    8000204e:	0a87a703          	lw	a4,168(a5)
    80002052:	4785                	li	a5,1
    80002054:	06f71763          	bne	a4,a5,800020c2 <sched+0xa6>
  if (p->state == RUNNING)
    80002058:	4c98                	lw	a4,24(s1)
    8000205a:	4791                	li	a5,4
    8000205c:	06f70b63          	beq	a4,a5,800020d2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002060:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002064:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002066:	efb5                	bnez	a5,800020e2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002068:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000206a:	00011917          	auipc	s2,0x11
    8000206e:	49690913          	addi	s2,s2,1174 # 80013500 <pid_lock>
    80002072:	2781                	sext.w	a5,a5
    80002074:	079e                	slli	a5,a5,0x7
    80002076:	97ca                	add	a5,a5,s2
    80002078:	0ac7a983          	lw	s3,172(a5)
    8000207c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000207e:	2781                	sext.w	a5,a5
    80002080:	079e                	slli	a5,a5,0x7
    80002082:	00011597          	auipc	a1,0x11
    80002086:	4b658593          	addi	a1,a1,1206 # 80013538 <cpus+0x8>
    8000208a:	95be                	add	a1,a1,a5
    8000208c:	06048513          	addi	a0,s1,96
    80002090:	00000097          	auipc	ra,0x0
    80002094:	7b8080e7          	jalr	1976(ra) # 80002848 <swtch>
    80002098:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000209a:	2781                	sext.w	a5,a5
    8000209c:	079e                	slli	a5,a5,0x7
    8000209e:	993e                	add	s2,s2,a5
    800020a0:	0b392623          	sw	s3,172(s2)
}
    800020a4:	70a2                	ld	ra,40(sp)
    800020a6:	7402                	ld	s0,32(sp)
    800020a8:	64e2                	ld	s1,24(sp)
    800020aa:	6942                	ld	s2,16(sp)
    800020ac:	69a2                	ld	s3,8(sp)
    800020ae:	6145                	addi	sp,sp,48
    800020b0:	8082                	ret
    panic("sched p->lock");
    800020b2:	00006517          	auipc	a0,0x6
    800020b6:	14650513          	addi	a0,a0,326 # 800081f8 <etext+0x1f8>
    800020ba:	ffffe097          	auipc	ra,0xffffe
    800020be:	4a6080e7          	jalr	1190(ra) # 80000560 <panic>
    panic("sched locks");
    800020c2:	00006517          	auipc	a0,0x6
    800020c6:	14650513          	addi	a0,a0,326 # 80008208 <etext+0x208>
    800020ca:	ffffe097          	auipc	ra,0xffffe
    800020ce:	496080e7          	jalr	1174(ra) # 80000560 <panic>
    panic("sched running");
    800020d2:	00006517          	auipc	a0,0x6
    800020d6:	14650513          	addi	a0,a0,326 # 80008218 <etext+0x218>
    800020da:	ffffe097          	auipc	ra,0xffffe
    800020de:	486080e7          	jalr	1158(ra) # 80000560 <panic>
    panic("sched interruptible");
    800020e2:	00006517          	auipc	a0,0x6
    800020e6:	14650513          	addi	a0,a0,326 # 80008228 <etext+0x228>
    800020ea:	ffffe097          	auipc	ra,0xffffe
    800020ee:	476080e7          	jalr	1142(ra) # 80000560 <panic>

00000000800020f2 <yield>:
{
    800020f2:	1101                	addi	sp,sp,-32
    800020f4:	ec06                	sd	ra,24(sp)
    800020f6:	e822                	sd	s0,16(sp)
    800020f8:	e426                	sd	s1,8(sp)
    800020fa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	94e080e7          	jalr	-1714(ra) # 80001a4a <myproc>
    80002104:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	b32080e7          	jalr	-1230(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    8000210e:	478d                	li	a5,3
    80002110:	cc9c                	sw	a5,24(s1)
  sched();
    80002112:	00000097          	auipc	ra,0x0
    80002116:	f0a080e7          	jalr	-246(ra) # 8000201c <sched>
  release(&p->lock);
    8000211a:	8526                	mv	a0,s1
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	bd0080e7          	jalr	-1072(ra) # 80000cec <release>
}
    80002124:	60e2                	ld	ra,24(sp)
    80002126:	6442                	ld	s0,16(sp)
    80002128:	64a2                	ld	s1,8(sp)
    8000212a:	6105                	addi	sp,sp,32
    8000212c:	8082                	ret

000000008000212e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000212e:	7179                	addi	sp,sp,-48
    80002130:	f406                	sd	ra,40(sp)
    80002132:	f022                	sd	s0,32(sp)
    80002134:	ec26                	sd	s1,24(sp)
    80002136:	e84a                	sd	s2,16(sp)
    80002138:	e44e                	sd	s3,8(sp)
    8000213a:	1800                	addi	s0,sp,48
    8000213c:	89aa                	mv	s3,a0
    8000213e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002140:	00000097          	auipc	ra,0x0
    80002144:	90a080e7          	jalr	-1782(ra) # 80001a4a <myproc>
    80002148:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	aee080e7          	jalr	-1298(ra) # 80000c38 <acquire>
  release(lk);
    80002152:	854a                	mv	a0,s2
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	b98080e7          	jalr	-1128(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    8000215c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002160:	4789                	li	a5,2
    80002162:	cc9c                	sw	a5,24(s1)

  sched();
    80002164:	00000097          	auipc	ra,0x0
    80002168:	eb8080e7          	jalr	-328(ra) # 8000201c <sched>

  // Tidy up.
  p->chan = 0;
    8000216c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002170:	8526                	mv	a0,s1
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	b7a080e7          	jalr	-1158(ra) # 80000cec <release>
  acquire(lk);
    8000217a:	854a                	mv	a0,s2
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	abc080e7          	jalr	-1348(ra) # 80000c38 <acquire>
}
    80002184:	70a2                	ld	ra,40(sp)
    80002186:	7402                	ld	s0,32(sp)
    80002188:	64e2                	ld	s1,24(sp)
    8000218a:	6942                	ld	s2,16(sp)
    8000218c:	69a2                	ld	s3,8(sp)
    8000218e:	6145                	addi	sp,sp,48
    80002190:	8082                	ret

0000000080002192 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002192:	7139                	addi	sp,sp,-64
    80002194:	fc06                	sd	ra,56(sp)
    80002196:	f822                	sd	s0,48(sp)
    80002198:	f426                	sd	s1,40(sp)
    8000219a:	f04a                	sd	s2,32(sp)
    8000219c:	ec4e                	sd	s3,24(sp)
    8000219e:	e852                	sd	s4,16(sp)
    800021a0:	e456                	sd	s5,8(sp)
    800021a2:	0080                	addi	s0,sp,64
    800021a4:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800021a6:	00011497          	auipc	s1,0x11
    800021aa:	78a48493          	addi	s1,s1,1930 # 80013930 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800021ae:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800021b0:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800021b2:	0001a917          	auipc	s2,0x1a
    800021b6:	57e90913          	addi	s2,s2,1406 # 8001c730 <tickslock>
    800021ba:	a811                	j	800021ce <wakeup+0x3c>
      }
      release(&p->lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	b2e080e7          	jalr	-1234(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800021c6:	23848493          	addi	s1,s1,568
    800021ca:	03248663          	beq	s1,s2,800021f6 <wakeup+0x64>
    if (p != myproc())
    800021ce:	00000097          	auipc	ra,0x0
    800021d2:	87c080e7          	jalr	-1924(ra) # 80001a4a <myproc>
    800021d6:	fea488e3          	beq	s1,a0,800021c6 <wakeup+0x34>
      acquire(&p->lock);
    800021da:	8526                	mv	a0,s1
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	a5c080e7          	jalr	-1444(ra) # 80000c38 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800021e4:	4c9c                	lw	a5,24(s1)
    800021e6:	fd379be3          	bne	a5,s3,800021bc <wakeup+0x2a>
    800021ea:	709c                	ld	a5,32(s1)
    800021ec:	fd4798e3          	bne	a5,s4,800021bc <wakeup+0x2a>
        p->state = RUNNABLE;
    800021f0:	0154ac23          	sw	s5,24(s1)
    800021f4:	b7e1                	j	800021bc <wakeup+0x2a>
    }
  }
}
    800021f6:	70e2                	ld	ra,56(sp)
    800021f8:	7442                	ld	s0,48(sp)
    800021fa:	74a2                	ld	s1,40(sp)
    800021fc:	7902                	ld	s2,32(sp)
    800021fe:	69e2                	ld	s3,24(sp)
    80002200:	6a42                	ld	s4,16(sp)
    80002202:	6aa2                	ld	s5,8(sp)
    80002204:	6121                	addi	sp,sp,64
    80002206:	8082                	ret

0000000080002208 <reparent>:
{
    80002208:	7179                	addi	sp,sp,-48
    8000220a:	f406                	sd	ra,40(sp)
    8000220c:	f022                	sd	s0,32(sp)
    8000220e:	ec26                	sd	s1,24(sp)
    80002210:	e84a                	sd	s2,16(sp)
    80002212:	e44e                	sd	s3,8(sp)
    80002214:	e052                	sd	s4,0(sp)
    80002216:	1800                	addi	s0,sp,48
    80002218:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000221a:	00011497          	auipc	s1,0x11
    8000221e:	71648493          	addi	s1,s1,1814 # 80013930 <proc>
      pp->parent = initproc;
    80002222:	00009a17          	auipc	s4,0x9
    80002226:	066a0a13          	addi	s4,s4,102 # 8000b288 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000222a:	0001a997          	auipc	s3,0x1a
    8000222e:	50698993          	addi	s3,s3,1286 # 8001c730 <tickslock>
    80002232:	a029                	j	8000223c <reparent+0x34>
    80002234:	23848493          	addi	s1,s1,568
    80002238:	01348d63          	beq	s1,s3,80002252 <reparent+0x4a>
    if (pp->parent == p)
    8000223c:	7c9c                	ld	a5,56(s1)
    8000223e:	ff279be3          	bne	a5,s2,80002234 <reparent+0x2c>
      pp->parent = initproc;
    80002242:	000a3503          	ld	a0,0(s4)
    80002246:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002248:	00000097          	auipc	ra,0x0
    8000224c:	f4a080e7          	jalr	-182(ra) # 80002192 <wakeup>
    80002250:	b7d5                	j	80002234 <reparent+0x2c>
}
    80002252:	70a2                	ld	ra,40(sp)
    80002254:	7402                	ld	s0,32(sp)
    80002256:	64e2                	ld	s1,24(sp)
    80002258:	6942                	ld	s2,16(sp)
    8000225a:	69a2                	ld	s3,8(sp)
    8000225c:	6a02                	ld	s4,0(sp)
    8000225e:	6145                	addi	sp,sp,48
    80002260:	8082                	ret

0000000080002262 <exit>:
{
    80002262:	7179                	addi	sp,sp,-48
    80002264:	f406                	sd	ra,40(sp)
    80002266:	f022                	sd	s0,32(sp)
    80002268:	ec26                	sd	s1,24(sp)
    8000226a:	e84a                	sd	s2,16(sp)
    8000226c:	e44e                	sd	s3,8(sp)
    8000226e:	e052                	sd	s4,0(sp)
    80002270:	1800                	addi	s0,sp,48
    80002272:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	7d6080e7          	jalr	2006(ra) # 80001a4a <myproc>
    8000227c:	89aa                	mv	s3,a0
  if (p == initproc)
    8000227e:	00009797          	auipc	a5,0x9
    80002282:	00a7b783          	ld	a5,10(a5) # 8000b288 <initproc>
    80002286:	0d050493          	addi	s1,a0,208
    8000228a:	15050913          	addi	s2,a0,336
    8000228e:	02a79363          	bne	a5,a0,800022b4 <exit+0x52>
    panic("init exiting");
    80002292:	00006517          	auipc	a0,0x6
    80002296:	fae50513          	addi	a0,a0,-82 # 80008240 <etext+0x240>
    8000229a:	ffffe097          	auipc	ra,0xffffe
    8000229e:	2c6080e7          	jalr	710(ra) # 80000560 <panic>
      fileclose(f);
    800022a2:	00002097          	auipc	ra,0x2
    800022a6:	5f2080e7          	jalr	1522(ra) # 80004894 <fileclose>
      p->ofile[fd] = 0;
    800022aa:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800022ae:	04a1                	addi	s1,s1,8
    800022b0:	01248563          	beq	s1,s2,800022ba <exit+0x58>
    if (p->ofile[fd])
    800022b4:	6088                	ld	a0,0(s1)
    800022b6:	f575                	bnez	a0,800022a2 <exit+0x40>
    800022b8:	bfdd                	j	800022ae <exit+0x4c>
  begin_op();
    800022ba:	00002097          	auipc	ra,0x2
    800022be:	110080e7          	jalr	272(ra) # 800043ca <begin_op>
  iput(p->cwd);
    800022c2:	1509b503          	ld	a0,336(s3)
    800022c6:	00002097          	auipc	ra,0x2
    800022ca:	8f4080e7          	jalr	-1804(ra) # 80003bba <iput>
  end_op();
    800022ce:	00002097          	auipc	ra,0x2
    800022d2:	176080e7          	jalr	374(ra) # 80004444 <end_op>
  p->cwd = 0;
    800022d6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022da:	00011497          	auipc	s1,0x11
    800022de:	23e48493          	addi	s1,s1,574 # 80013518 <wait_lock>
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	954080e7          	jalr	-1708(ra) # 80000c38 <acquire>
  reparent(p);
    800022ec:	854e                	mv	a0,s3
    800022ee:	00000097          	auipc	ra,0x0
    800022f2:	f1a080e7          	jalr	-230(ra) # 80002208 <reparent>
  wakeup(p->parent);
    800022f6:	0389b503          	ld	a0,56(s3)
    800022fa:	00000097          	auipc	ra,0x0
    800022fe:	e98080e7          	jalr	-360(ra) # 80002192 <wakeup>
  acquire(&p->lock);
    80002302:	854e                	mv	a0,s3
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	934080e7          	jalr	-1740(ra) # 80000c38 <acquire>
  p->xstate = status;
    8000230c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002310:	4795                	li	a5,5
    80002312:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002316:	00009797          	auipc	a5,0x9
    8000231a:	f7a7a783          	lw	a5,-134(a5) # 8000b290 <ticks>
    8000231e:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    80002322:	8526                	mv	a0,s1
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	9c8080e7          	jalr	-1592(ra) # 80000cec <release>
  sched();
    8000232c:	00000097          	auipc	ra,0x0
    80002330:	cf0080e7          	jalr	-784(ra) # 8000201c <sched>
  panic("zombie exit");
    80002334:	00006517          	auipc	a0,0x6
    80002338:	f1c50513          	addi	a0,a0,-228 # 80008250 <etext+0x250>
    8000233c:	ffffe097          	auipc	ra,0xffffe
    80002340:	224080e7          	jalr	548(ra) # 80000560 <panic>

0000000080002344 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002344:	7179                	addi	sp,sp,-48
    80002346:	f406                	sd	ra,40(sp)
    80002348:	f022                	sd	s0,32(sp)
    8000234a:	ec26                	sd	s1,24(sp)
    8000234c:	e84a                	sd	s2,16(sp)
    8000234e:	e44e                	sd	s3,8(sp)
    80002350:	1800                	addi	s0,sp,48
    80002352:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002354:	00011497          	auipc	s1,0x11
    80002358:	5dc48493          	addi	s1,s1,1500 # 80013930 <proc>
    8000235c:	0001a997          	auipc	s3,0x1a
    80002360:	3d498993          	addi	s3,s3,980 # 8001c730 <tickslock>
  {
    acquire(&p->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	8d2080e7          	jalr	-1838(ra) # 80000c38 <acquire>
    if (p->pid == pid)
    8000236e:	589c                	lw	a5,48(s1)
    80002370:	01278d63          	beq	a5,s2,8000238a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	976080e7          	jalr	-1674(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000237e:	23848493          	addi	s1,s1,568
    80002382:	ff3491e3          	bne	s1,s3,80002364 <kill+0x20>
  }
  return -1;
    80002386:	557d                	li	a0,-1
    80002388:	a829                	j	800023a2 <kill+0x5e>
      p->killed = 1;
    8000238a:	4785                	li	a5,1
    8000238c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000238e:	4c98                	lw	a4,24(s1)
    80002390:	4789                	li	a5,2
    80002392:	00f70f63          	beq	a4,a5,800023b0 <kill+0x6c>
      release(&p->lock);
    80002396:	8526                	mv	a0,s1
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	954080e7          	jalr	-1708(ra) # 80000cec <release>
      return 0;
    800023a0:	4501                	li	a0,0
}
    800023a2:	70a2                	ld	ra,40(sp)
    800023a4:	7402                	ld	s0,32(sp)
    800023a6:	64e2                	ld	s1,24(sp)
    800023a8:	6942                	ld	s2,16(sp)
    800023aa:	69a2                	ld	s3,8(sp)
    800023ac:	6145                	addi	sp,sp,48
    800023ae:	8082                	ret
        p->state = RUNNABLE;
    800023b0:	478d                	li	a5,3
    800023b2:	cc9c                	sw	a5,24(s1)
    800023b4:	b7cd                	j	80002396 <kill+0x52>

00000000800023b6 <setkilled>:

void setkilled(struct proc *p)
{
    800023b6:	1101                	addi	sp,sp,-32
    800023b8:	ec06                	sd	ra,24(sp)
    800023ba:	e822                	sd	s0,16(sp)
    800023bc:	e426                	sd	s1,8(sp)
    800023be:	1000                	addi	s0,sp,32
    800023c0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	876080e7          	jalr	-1930(ra) # 80000c38 <acquire>
  p->killed = 1;
    800023ca:	4785                	li	a5,1
    800023cc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	91c080e7          	jalr	-1764(ra) # 80000cec <release>
}
    800023d8:	60e2                	ld	ra,24(sp)
    800023da:	6442                	ld	s0,16(sp)
    800023dc:	64a2                	ld	s1,8(sp)
    800023de:	6105                	addi	sp,sp,32
    800023e0:	8082                	ret

00000000800023e2 <killed>:

int killed(struct proc *p)
{
    800023e2:	1101                	addi	sp,sp,-32
    800023e4:	ec06                	sd	ra,24(sp)
    800023e6:	e822                	sd	s0,16(sp)
    800023e8:	e426                	sd	s1,8(sp)
    800023ea:	e04a                	sd	s2,0(sp)
    800023ec:	1000                	addi	s0,sp,32
    800023ee:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	848080e7          	jalr	-1976(ra) # 80000c38 <acquire>
  k = p->killed;
    800023f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023fc:	8526                	mv	a0,s1
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	8ee080e7          	jalr	-1810(ra) # 80000cec <release>
  return k;
}
    80002406:	854a                	mv	a0,s2
    80002408:	60e2                	ld	ra,24(sp)
    8000240a:	6442                	ld	s0,16(sp)
    8000240c:	64a2                	ld	s1,8(sp)
    8000240e:	6902                	ld	s2,0(sp)
    80002410:	6105                	addi	sp,sp,32
    80002412:	8082                	ret

0000000080002414 <wait>:
{
    80002414:	715d                	addi	sp,sp,-80
    80002416:	e486                	sd	ra,72(sp)
    80002418:	e0a2                	sd	s0,64(sp)
    8000241a:	fc26                	sd	s1,56(sp)
    8000241c:	f84a                	sd	s2,48(sp)
    8000241e:	f44e                	sd	s3,40(sp)
    80002420:	f052                	sd	s4,32(sp)
    80002422:	ec56                	sd	s5,24(sp)
    80002424:	e85a                	sd	s6,16(sp)
    80002426:	e45e                	sd	s7,8(sp)
    80002428:	e062                	sd	s8,0(sp)
    8000242a:	0880                	addi	s0,sp,80
    8000242c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	61c080e7          	jalr	1564(ra) # 80001a4a <myproc>
    80002436:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002438:	00011517          	auipc	a0,0x11
    8000243c:	0e050513          	addi	a0,a0,224 # 80013518 <wait_lock>
    80002440:	ffffe097          	auipc	ra,0xffffe
    80002444:	7f8080e7          	jalr	2040(ra) # 80000c38 <acquire>
    havekids = 0;
    80002448:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    8000244a:	4a15                	li	s4,5
        havekids = 1;
    8000244c:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000244e:	0001a997          	auipc	s3,0x1a
    80002452:	2e298993          	addi	s3,s3,738 # 8001c730 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002456:	00011c17          	auipc	s8,0x11
    8000245a:	0c2c0c13          	addi	s8,s8,194 # 80013518 <wait_lock>
    8000245e:	a0d1                	j	80002522 <wait+0x10e>
          pid = pp->pid;
    80002460:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002464:	000b0e63          	beqz	s6,80002480 <wait+0x6c>
    80002468:	4691                	li	a3,4
    8000246a:	02c48613          	addi	a2,s1,44
    8000246e:	85da                	mv	a1,s6
    80002470:	05093503          	ld	a0,80(s2)
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	26e080e7          	jalr	622(ra) # 800016e2 <copyout>
    8000247c:	04054163          	bltz	a0,800024be <wait+0xaa>
          freeproc(pp);
    80002480:	8526                	mv	a0,s1
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	77a080e7          	jalr	1914(ra) # 80001bfc <freeproc>
          release(&pp->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	860080e7          	jalr	-1952(ra) # 80000cec <release>
          release(&wait_lock);
    80002494:	00011517          	auipc	a0,0x11
    80002498:	08450513          	addi	a0,a0,132 # 80013518 <wait_lock>
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	850080e7          	jalr	-1968(ra) # 80000cec <release>
}
    800024a4:	854e                	mv	a0,s3
    800024a6:	60a6                	ld	ra,72(sp)
    800024a8:	6406                	ld	s0,64(sp)
    800024aa:	74e2                	ld	s1,56(sp)
    800024ac:	7942                	ld	s2,48(sp)
    800024ae:	79a2                	ld	s3,40(sp)
    800024b0:	7a02                	ld	s4,32(sp)
    800024b2:	6ae2                	ld	s5,24(sp)
    800024b4:	6b42                	ld	s6,16(sp)
    800024b6:	6ba2                	ld	s7,8(sp)
    800024b8:	6c02                	ld	s8,0(sp)
    800024ba:	6161                	addi	sp,sp,80
    800024bc:	8082                	ret
            release(&pp->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	fffff097          	auipc	ra,0xfffff
    800024c4:	82c080e7          	jalr	-2004(ra) # 80000cec <release>
            release(&wait_lock);
    800024c8:	00011517          	auipc	a0,0x11
    800024cc:	05050513          	addi	a0,a0,80 # 80013518 <wait_lock>
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	81c080e7          	jalr	-2020(ra) # 80000cec <release>
            return -1;
    800024d8:	59fd                	li	s3,-1
    800024da:	b7e9                	j	800024a4 <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024dc:	23848493          	addi	s1,s1,568
    800024e0:	03348463          	beq	s1,s3,80002508 <wait+0xf4>
      if (pp->parent == p)
    800024e4:	7c9c                	ld	a5,56(s1)
    800024e6:	ff279be3          	bne	a5,s2,800024dc <wait+0xc8>
        acquire(&pp->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	74c080e7          	jalr	1868(ra) # 80000c38 <acquire>
        if (pp->state == ZOMBIE)
    800024f4:	4c9c                	lw	a5,24(s1)
    800024f6:	f74785e3          	beq	a5,s4,80002460 <wait+0x4c>
        release(&pp->lock);
    800024fa:	8526                	mv	a0,s1
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	7f0080e7          	jalr	2032(ra) # 80000cec <release>
        havekids = 1;
    80002504:	8756                	mv	a4,s5
    80002506:	bfd9                	j	800024dc <wait+0xc8>
    if (!havekids || killed(p))
    80002508:	c31d                	beqz	a4,8000252e <wait+0x11a>
    8000250a:	854a                	mv	a0,s2
    8000250c:	00000097          	auipc	ra,0x0
    80002510:	ed6080e7          	jalr	-298(ra) # 800023e2 <killed>
    80002514:	ed09                	bnez	a0,8000252e <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002516:	85e2                	mv	a1,s8
    80002518:	854a                	mv	a0,s2
    8000251a:	00000097          	auipc	ra,0x0
    8000251e:	c14080e7          	jalr	-1004(ra) # 8000212e <sleep>
    havekids = 0;
    80002522:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002524:	00011497          	auipc	s1,0x11
    80002528:	40c48493          	addi	s1,s1,1036 # 80013930 <proc>
    8000252c:	bf65                	j	800024e4 <wait+0xd0>
      release(&wait_lock);
    8000252e:	00011517          	auipc	a0,0x11
    80002532:	fea50513          	addi	a0,a0,-22 # 80013518 <wait_lock>
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	7b6080e7          	jalr	1974(ra) # 80000cec <release>
      return -1;
    8000253e:	59fd                	li	s3,-1
    80002540:	b795                	j	800024a4 <wait+0x90>

0000000080002542 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002542:	7179                	addi	sp,sp,-48
    80002544:	f406                	sd	ra,40(sp)
    80002546:	f022                	sd	s0,32(sp)
    80002548:	ec26                	sd	s1,24(sp)
    8000254a:	e84a                	sd	s2,16(sp)
    8000254c:	e44e                	sd	s3,8(sp)
    8000254e:	e052                	sd	s4,0(sp)
    80002550:	1800                	addi	s0,sp,48
    80002552:	84aa                	mv	s1,a0
    80002554:	892e                	mv	s2,a1
    80002556:	89b2                	mv	s3,a2
    80002558:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000255a:	fffff097          	auipc	ra,0xfffff
    8000255e:	4f0080e7          	jalr	1264(ra) # 80001a4a <myproc>
  if (user_dst)
    80002562:	c08d                	beqz	s1,80002584 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002564:	86d2                	mv	a3,s4
    80002566:	864e                	mv	a2,s3
    80002568:	85ca                	mv	a1,s2
    8000256a:	6928                	ld	a0,80(a0)
    8000256c:	fffff097          	auipc	ra,0xfffff
    80002570:	176080e7          	jalr	374(ra) # 800016e2 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002574:	70a2                	ld	ra,40(sp)
    80002576:	7402                	ld	s0,32(sp)
    80002578:	64e2                	ld	s1,24(sp)
    8000257a:	6942                	ld	s2,16(sp)
    8000257c:	69a2                	ld	s3,8(sp)
    8000257e:	6a02                	ld	s4,0(sp)
    80002580:	6145                	addi	sp,sp,48
    80002582:	8082                	ret
    memmove((char *)dst, src, len);
    80002584:	000a061b          	sext.w	a2,s4
    80002588:	85ce                	mv	a1,s3
    8000258a:	854a                	mv	a0,s2
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	804080e7          	jalr	-2044(ra) # 80000d90 <memmove>
    return 0;
    80002594:	8526                	mv	a0,s1
    80002596:	bff9                	j	80002574 <either_copyout+0x32>

0000000080002598 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002598:	7179                	addi	sp,sp,-48
    8000259a:	f406                	sd	ra,40(sp)
    8000259c:	f022                	sd	s0,32(sp)
    8000259e:	ec26                	sd	s1,24(sp)
    800025a0:	e84a                	sd	s2,16(sp)
    800025a2:	e44e                	sd	s3,8(sp)
    800025a4:	e052                	sd	s4,0(sp)
    800025a6:	1800                	addi	s0,sp,48
    800025a8:	892a                	mv	s2,a0
    800025aa:	84ae                	mv	s1,a1
    800025ac:	89b2                	mv	s3,a2
    800025ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	49a080e7          	jalr	1178(ra) # 80001a4a <myproc>
  if (user_src)
    800025b8:	c08d                	beqz	s1,800025da <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800025ba:	86d2                	mv	a3,s4
    800025bc:	864e                	mv	a2,s3
    800025be:	85ca                	mv	a1,s2
    800025c0:	6928                	ld	a0,80(a0)
    800025c2:	fffff097          	auipc	ra,0xfffff
    800025c6:	1ac080e7          	jalr	428(ra) # 8000176e <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800025ca:	70a2                	ld	ra,40(sp)
    800025cc:	7402                	ld	s0,32(sp)
    800025ce:	64e2                	ld	s1,24(sp)
    800025d0:	6942                	ld	s2,16(sp)
    800025d2:	69a2                	ld	s3,8(sp)
    800025d4:	6a02                	ld	s4,0(sp)
    800025d6:	6145                	addi	sp,sp,48
    800025d8:	8082                	ret
    memmove(dst, (char *)src, len);
    800025da:	000a061b          	sext.w	a2,s4
    800025de:	85ce                	mv	a1,s3
    800025e0:	854a                	mv	a0,s2
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	7ae080e7          	jalr	1966(ra) # 80000d90 <memmove>
    return 0;
    800025ea:	8526                	mv	a0,s1
    800025ec:	bff9                	j	800025ca <either_copyin+0x32>

00000000800025ee <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025ee:	715d                	addi	sp,sp,-80
    800025f0:	e486                	sd	ra,72(sp)
    800025f2:	e0a2                	sd	s0,64(sp)
    800025f4:	fc26                	sd	s1,56(sp)
    800025f6:	f84a                	sd	s2,48(sp)
    800025f8:	f44e                	sd	s3,40(sp)
    800025fa:	f052                	sd	s4,32(sp)
    800025fc:	ec56                	sd	s5,24(sp)
    800025fe:	e85a                	sd	s6,16(sp)
    80002600:	e45e                	sd	s7,8(sp)
    80002602:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002604:	00006517          	auipc	a0,0x6
    80002608:	a0c50513          	addi	a0,a0,-1524 # 80008010 <etext+0x10>
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	f9e080e7          	jalr	-98(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002614:	00011497          	auipc	s1,0x11
    80002618:	47448493          	addi	s1,s1,1140 # 80013a88 <proc+0x158>
    8000261c:	0001a917          	auipc	s2,0x1a
    80002620:	26c90913          	addi	s2,s2,620 # 8001c888 <bcache+0x80>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002624:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002626:	00006997          	auipc	s3,0x6
    8000262a:	c3a98993          	addi	s3,s3,-966 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    8000262e:	00006a97          	auipc	s5,0x6
    80002632:	c3aa8a93          	addi	s5,s5,-966 # 80008268 <etext+0x268>
    printf("\n");
    80002636:	00006a17          	auipc	s4,0x6
    8000263a:	9daa0a13          	addi	s4,s4,-1574 # 80008010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000263e:	00006b97          	auipc	s7,0x6
    80002642:	102b8b93          	addi	s7,s7,258 # 80008740 <states.0>
    80002646:	a00d                	j	80002668 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002648:	ed86a583          	lw	a1,-296(a3)
    8000264c:	8556                	mv	a0,s5
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	f5c080e7          	jalr	-164(ra) # 800005aa <printf>
    printf("\n");
    80002656:	8552                	mv	a0,s4
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	f52080e7          	jalr	-174(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002660:	23848493          	addi	s1,s1,568
    80002664:	03248263          	beq	s1,s2,80002688 <procdump+0x9a>
    if (p->state == UNUSED)
    80002668:	86a6                	mv	a3,s1
    8000266a:	ec04a783          	lw	a5,-320(s1)
    8000266e:	dbed                	beqz	a5,80002660 <procdump+0x72>
      state = "???";
    80002670:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002672:	fcfb6be3          	bltu	s6,a5,80002648 <procdump+0x5a>
    80002676:	02079713          	slli	a4,a5,0x20
    8000267a:	01d75793          	srli	a5,a4,0x1d
    8000267e:	97de                	add	a5,a5,s7
    80002680:	6390                	ld	a2,0(a5)
    80002682:	f279                	bnez	a2,80002648 <procdump+0x5a>
      state = "???";
    80002684:	864e                	mv	a2,s3
    80002686:	b7c9                	j	80002648 <procdump+0x5a>
  }
}
    80002688:	60a6                	ld	ra,72(sp)
    8000268a:	6406                	ld	s0,64(sp)
    8000268c:	74e2                	ld	s1,56(sp)
    8000268e:	7942                	ld	s2,48(sp)
    80002690:	79a2                	ld	s3,40(sp)
    80002692:	7a02                	ld	s4,32(sp)
    80002694:	6ae2                	ld	s5,24(sp)
    80002696:	6b42                	ld	s6,16(sp)
    80002698:	6ba2                	ld	s7,8(sp)
    8000269a:	6161                	addi	sp,sp,80
    8000269c:	8082                	ret

000000008000269e <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    8000269e:	711d                	addi	sp,sp,-96
    800026a0:	ec86                	sd	ra,88(sp)
    800026a2:	e8a2                	sd	s0,80(sp)
    800026a4:	e4a6                	sd	s1,72(sp)
    800026a6:	e0ca                	sd	s2,64(sp)
    800026a8:	fc4e                	sd	s3,56(sp)
    800026aa:	f852                	sd	s4,48(sp)
    800026ac:	f456                	sd	s5,40(sp)
    800026ae:	f05a                	sd	s6,32(sp)
    800026b0:	ec5e                	sd	s7,24(sp)
    800026b2:	e862                	sd	s8,16(sp)
    800026b4:	e466                	sd	s9,8(sp)
    800026b6:	e06a                	sd	s10,0(sp)
    800026b8:	1080                	addi	s0,sp,96
    800026ba:	8b2a                	mv	s6,a0
    800026bc:	8bae                	mv	s7,a1
    800026be:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800026c0:	fffff097          	auipc	ra,0xfffff
    800026c4:	38a080e7          	jalr	906(ra) # 80001a4a <myproc>
    800026c8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800026ca:	00011517          	auipc	a0,0x11
    800026ce:	e4e50513          	addi	a0,a0,-434 # 80013518 <wait_lock>
    800026d2:	ffffe097          	auipc	ra,0xffffe
    800026d6:	566080e7          	jalr	1382(ra) # 80000c38 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800026da:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800026dc:	4a15                	li	s4,5
        havekids = 1;
    800026de:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800026e0:	0001a997          	auipc	s3,0x1a
    800026e4:	05098993          	addi	s3,s3,80 # 8001c730 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800026e8:	00011d17          	auipc	s10,0x11
    800026ec:	e30d0d13          	addi	s10,s10,-464 # 80013518 <wait_lock>
    800026f0:	a8e9                	j	800027ca <waitx+0x12c>
          pid = np->pid;
    800026f2:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800026f6:	1684a783          	lw	a5,360(s1)
    800026fa:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800026fe:	16c4a703          	lw	a4,364(s1)
    80002702:	9f3d                	addw	a4,a4,a5
    80002704:	1704a783          	lw	a5,368(s1)
    80002708:	9f99                	subw	a5,a5,a4
    8000270a:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000270e:	000b0e63          	beqz	s6,8000272a <waitx+0x8c>
    80002712:	4691                	li	a3,4
    80002714:	02c48613          	addi	a2,s1,44
    80002718:	85da                	mv	a1,s6
    8000271a:	05093503          	ld	a0,80(s2)
    8000271e:	fffff097          	auipc	ra,0xfffff
    80002722:	fc4080e7          	jalr	-60(ra) # 800016e2 <copyout>
    80002726:	04054363          	bltz	a0,8000276c <waitx+0xce>
          freeproc(np);
    8000272a:	8526                	mv	a0,s1
    8000272c:	fffff097          	auipc	ra,0xfffff
    80002730:	4d0080e7          	jalr	1232(ra) # 80001bfc <freeproc>
          release(&np->lock);
    80002734:	8526                	mv	a0,s1
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	5b6080e7          	jalr	1462(ra) # 80000cec <release>
          release(&wait_lock);
    8000273e:	00011517          	auipc	a0,0x11
    80002742:	dda50513          	addi	a0,a0,-550 # 80013518 <wait_lock>
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	5a6080e7          	jalr	1446(ra) # 80000cec <release>
  }
}
    8000274e:	854e                	mv	a0,s3
    80002750:	60e6                	ld	ra,88(sp)
    80002752:	6446                	ld	s0,80(sp)
    80002754:	64a6                	ld	s1,72(sp)
    80002756:	6906                	ld	s2,64(sp)
    80002758:	79e2                	ld	s3,56(sp)
    8000275a:	7a42                	ld	s4,48(sp)
    8000275c:	7aa2                	ld	s5,40(sp)
    8000275e:	7b02                	ld	s6,32(sp)
    80002760:	6be2                	ld	s7,24(sp)
    80002762:	6c42                	ld	s8,16(sp)
    80002764:	6ca2                	ld	s9,8(sp)
    80002766:	6d02                	ld	s10,0(sp)
    80002768:	6125                	addi	sp,sp,96
    8000276a:	8082                	ret
            release(&np->lock);
    8000276c:	8526                	mv	a0,s1
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	57e080e7          	jalr	1406(ra) # 80000cec <release>
            release(&wait_lock);
    80002776:	00011517          	auipc	a0,0x11
    8000277a:	da250513          	addi	a0,a0,-606 # 80013518 <wait_lock>
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	56e080e7          	jalr	1390(ra) # 80000cec <release>
            return -1;
    80002786:	59fd                	li	s3,-1
    80002788:	b7d9                	j	8000274e <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    8000278a:	23848493          	addi	s1,s1,568
    8000278e:	03348463          	beq	s1,s3,800027b6 <waitx+0x118>
      if (np->parent == p)
    80002792:	7c9c                	ld	a5,56(s1)
    80002794:	ff279be3          	bne	a5,s2,8000278a <waitx+0xec>
        acquire(&np->lock);
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	49e080e7          	jalr	1182(ra) # 80000c38 <acquire>
        if (np->state == ZOMBIE)
    800027a2:	4c9c                	lw	a5,24(s1)
    800027a4:	f54787e3          	beq	a5,s4,800026f2 <waitx+0x54>
        release(&np->lock);
    800027a8:	8526                	mv	a0,s1
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	542080e7          	jalr	1346(ra) # 80000cec <release>
        havekids = 1;
    800027b2:	8756                	mv	a4,s5
    800027b4:	bfd9                	j	8000278a <waitx+0xec>
    if (!havekids || p->killed)
    800027b6:	c305                	beqz	a4,800027d6 <waitx+0x138>
    800027b8:	02892783          	lw	a5,40(s2)
    800027bc:	ef89                	bnez	a5,800027d6 <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027be:	85ea                	mv	a1,s10
    800027c0:	854a                	mv	a0,s2
    800027c2:	00000097          	auipc	ra,0x0
    800027c6:	96c080e7          	jalr	-1684(ra) # 8000212e <sleep>
    havekids = 0;
    800027ca:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800027cc:	00011497          	auipc	s1,0x11
    800027d0:	16448493          	addi	s1,s1,356 # 80013930 <proc>
    800027d4:	bf7d                	j	80002792 <waitx+0xf4>
      release(&wait_lock);
    800027d6:	00011517          	auipc	a0,0x11
    800027da:	d4250513          	addi	a0,a0,-702 # 80013518 <wait_lock>
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	50e080e7          	jalr	1294(ra) # 80000cec <release>
      return -1;
    800027e6:	59fd                	li	s3,-1
    800027e8:	b79d                	j	8000274e <waitx+0xb0>

00000000800027ea <update_time>:

void update_time()
{
    800027ea:	7179                	addi	sp,sp,-48
    800027ec:	f406                	sd	ra,40(sp)
    800027ee:	f022                	sd	s0,32(sp)
    800027f0:	ec26                	sd	s1,24(sp)
    800027f2:	e84a                	sd	s2,16(sp)
    800027f4:	e44e                	sd	s3,8(sp)
    800027f6:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800027f8:	00011497          	auipc	s1,0x11
    800027fc:	13848493          	addi	s1,s1,312 # 80013930 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002800:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002802:	0001a917          	auipc	s2,0x1a
    80002806:	f2e90913          	addi	s2,s2,-210 # 8001c730 <tickslock>
    8000280a:	a811                	j	8000281e <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    8000280c:	8526                	mv	a0,s1
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	4de080e7          	jalr	1246(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002816:	23848493          	addi	s1,s1,568
    8000281a:	03248063          	beq	s1,s2,8000283a <update_time+0x50>
    acquire(&p->lock);
    8000281e:	8526                	mv	a0,s1
    80002820:	ffffe097          	auipc	ra,0xffffe
    80002824:	418080e7          	jalr	1048(ra) # 80000c38 <acquire>
    if (p->state == RUNNING)
    80002828:	4c9c                	lw	a5,24(s1)
    8000282a:	ff3791e3          	bne	a5,s3,8000280c <update_time+0x22>
      p->rtime++;
    8000282e:	1684a783          	lw	a5,360(s1)
    80002832:	2785                	addiw	a5,a5,1
    80002834:	16f4a423          	sw	a5,360(s1)
    80002838:	bfd1                	j	8000280c <update_time+0x22>
  }
    8000283a:	70a2                	ld	ra,40(sp)
    8000283c:	7402                	ld	s0,32(sp)
    8000283e:	64e2                	ld	s1,24(sp)
    80002840:	6942                	ld	s2,16(sp)
    80002842:	69a2                	ld	s3,8(sp)
    80002844:	6145                	addi	sp,sp,48
    80002846:	8082                	ret

0000000080002848 <swtch>:
    80002848:	00153023          	sd	ra,0(a0)
    8000284c:	00253423          	sd	sp,8(a0)
    80002850:	e900                	sd	s0,16(a0)
    80002852:	ed04                	sd	s1,24(a0)
    80002854:	03253023          	sd	s2,32(a0)
    80002858:	03353423          	sd	s3,40(a0)
    8000285c:	03453823          	sd	s4,48(a0)
    80002860:	03553c23          	sd	s5,56(a0)
    80002864:	05653023          	sd	s6,64(a0)
    80002868:	05753423          	sd	s7,72(a0)
    8000286c:	05853823          	sd	s8,80(a0)
    80002870:	05953c23          	sd	s9,88(a0)
    80002874:	07a53023          	sd	s10,96(a0)
    80002878:	07b53423          	sd	s11,104(a0)
    8000287c:	0005b083          	ld	ra,0(a1)
    80002880:	0085b103          	ld	sp,8(a1)
    80002884:	6980                	ld	s0,16(a1)
    80002886:	6d84                	ld	s1,24(a1)
    80002888:	0205b903          	ld	s2,32(a1)
    8000288c:	0285b983          	ld	s3,40(a1)
    80002890:	0305ba03          	ld	s4,48(a1)
    80002894:	0385ba83          	ld	s5,56(a1)
    80002898:	0405bb03          	ld	s6,64(a1)
    8000289c:	0485bb83          	ld	s7,72(a1)
    800028a0:	0505bc03          	ld	s8,80(a1)
    800028a4:	0585bc83          	ld	s9,88(a1)
    800028a8:	0605bd03          	ld	s10,96(a1)
    800028ac:	0685bd83          	ld	s11,104(a1)
    800028b0:	8082                	ret

00000000800028b2 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800028b2:	1141                	addi	sp,sp,-16
    800028b4:	e406                	sd	ra,8(sp)
    800028b6:	e022                	sd	s0,0(sp)
    800028b8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028ba:	00006597          	auipc	a1,0x6
    800028be:	9ee58593          	addi	a1,a1,-1554 # 800082a8 <etext+0x2a8>
    800028c2:	0001a517          	auipc	a0,0x1a
    800028c6:	e6e50513          	addi	a0,a0,-402 # 8001c730 <tickslock>
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	2de080e7          	jalr	734(ra) # 80000ba8 <initlock>
}
    800028d2:	60a2                	ld	ra,8(sp)
    800028d4:	6402                	ld	s0,0(sp)
    800028d6:	0141                	addi	sp,sp,16
    800028d8:	8082                	ret

00000000800028da <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800028da:	1141                	addi	sp,sp,-16
    800028dc:	e422                	sd	s0,8(sp)
    800028de:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028e0:	00003797          	auipc	a5,0x3
    800028e4:	6b078793          	addi	a5,a5,1712 # 80005f90 <kernelvec>
    800028e8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028ec:	6422                	ld	s0,8(sp)
    800028ee:	0141                	addi	sp,sp,16
    800028f0:	8082                	ret

00000000800028f2 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800028f2:	1141                	addi	sp,sp,-16
    800028f4:	e406                	sd	ra,8(sp)
    800028f6:	e022                	sd	s0,0(sp)
    800028f8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028fa:	fffff097          	auipc	ra,0xfffff
    800028fe:	150080e7          	jalr	336(ra) # 80001a4a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002902:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002906:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002908:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000290c:	00004697          	auipc	a3,0x4
    80002910:	6f468693          	addi	a3,a3,1780 # 80007000 <_trampoline>
    80002914:	00004717          	auipc	a4,0x4
    80002918:	6ec70713          	addi	a4,a4,1772 # 80007000 <_trampoline>
    8000291c:	8f15                	sub	a4,a4,a3
    8000291e:	040007b7          	lui	a5,0x4000
    80002922:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002924:	07b2                	slli	a5,a5,0xc
    80002926:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002928:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000292c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000292e:	18002673          	csrr	a2,satp
    80002932:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002934:	6d30                	ld	a2,88(a0)
    80002936:	6138                	ld	a4,64(a0)
    80002938:	6585                	lui	a1,0x1
    8000293a:	972e                	add	a4,a4,a1
    8000293c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000293e:	6d38                	ld	a4,88(a0)
    80002940:	00000617          	auipc	a2,0x0
    80002944:	14660613          	addi	a2,a2,326 # 80002a86 <usertrap>
    80002948:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000294a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000294c:	8612                	mv	a2,tp
    8000294e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002950:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002954:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002958:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000295c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002960:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002962:	6f18                	ld	a4,24(a4)
    80002964:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002968:	6928                	ld	a0,80(a0)
    8000296a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000296c:	00004717          	auipc	a4,0x4
    80002970:	73070713          	addi	a4,a4,1840 # 8000709c <userret>
    80002974:	8f15                	sub	a4,a4,a3
    80002976:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002978:	577d                	li	a4,-1
    8000297a:	177e                	slli	a4,a4,0x3f
    8000297c:	8d59                	or	a0,a0,a4
    8000297e:	9782                	jalr	a5
}
    80002980:	60a2                	ld	ra,8(sp)
    80002982:	6402                	ld	s0,0(sp)
    80002984:	0141                	addi	sp,sp,16
    80002986:	8082                	ret

0000000080002988 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002988:	1101                	addi	sp,sp,-32
    8000298a:	ec06                	sd	ra,24(sp)
    8000298c:	e822                	sd	s0,16(sp)
    8000298e:	e426                	sd	s1,8(sp)
    80002990:	e04a                	sd	s2,0(sp)
    80002992:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002994:	0001a917          	auipc	s2,0x1a
    80002998:	d9c90913          	addi	s2,s2,-612 # 8001c730 <tickslock>
    8000299c:	854a                	mv	a0,s2
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	29a080e7          	jalr	666(ra) # 80000c38 <acquire>
  ticks++;
    800029a6:	00009497          	auipc	s1,0x9
    800029aa:	8ea48493          	addi	s1,s1,-1814 # 8000b290 <ticks>
    800029ae:	409c                	lw	a5,0(s1)
    800029b0:	2785                	addiw	a5,a5,1
    800029b2:	c09c                	sw	a5,0(s1)
  update_time();
    800029b4:	00000097          	auipc	ra,0x0
    800029b8:	e36080e7          	jalr	-458(ra) # 800027ea <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    800029bc:	8526                	mv	a0,s1
    800029be:	fffff097          	auipc	ra,0xfffff
    800029c2:	7d4080e7          	jalr	2004(ra) # 80002192 <wakeup>
  release(&tickslock);
    800029c6:	854a                	mv	a0,s2
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	324080e7          	jalr	804(ra) # 80000cec <release>
}
    800029d0:	60e2                	ld	ra,24(sp)
    800029d2:	6442                	ld	s0,16(sp)
    800029d4:	64a2                	ld	s1,8(sp)
    800029d6:	6902                	ld	s2,0(sp)
    800029d8:	6105                	addi	sp,sp,32
    800029da:	8082                	ret

00000000800029dc <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029dc:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    800029e0:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    800029e2:	0a07d163          	bgez	a5,80002a84 <devintr+0xa8>
{
    800029e6:	1101                	addi	sp,sp,-32
    800029e8:	ec06                	sd	ra,24(sp)
    800029ea:	e822                	sd	s0,16(sp)
    800029ec:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    800029ee:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    800029f2:	46a5                	li	a3,9
    800029f4:	00d70c63          	beq	a4,a3,80002a0c <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    800029f8:	577d                	li	a4,-1
    800029fa:	177e                	slli	a4,a4,0x3f
    800029fc:	0705                	addi	a4,a4,1
    return 0;
    800029fe:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002a00:	06e78163          	beq	a5,a4,80002a62 <devintr+0x86>
  }
}
    80002a04:	60e2                	ld	ra,24(sp)
    80002a06:	6442                	ld	s0,16(sp)
    80002a08:	6105                	addi	sp,sp,32
    80002a0a:	8082                	ret
    80002a0c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a0e:	00003097          	auipc	ra,0x3
    80002a12:	68e080e7          	jalr	1678(ra) # 8000609c <plic_claim>
    80002a16:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002a18:	47a9                	li	a5,10
    80002a1a:	00f50963          	beq	a0,a5,80002a2c <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002a1e:	4785                	li	a5,1
    80002a20:	00f50b63          	beq	a0,a5,80002a36 <devintr+0x5a>
    return 1;
    80002a24:	4505                	li	a0,1
    else if (irq)
    80002a26:	ec89                	bnez	s1,80002a40 <devintr+0x64>
    80002a28:	64a2                	ld	s1,8(sp)
    80002a2a:	bfe9                	j	80002a04 <devintr+0x28>
      uartintr();
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	fce080e7          	jalr	-50(ra) # 800009fa <uartintr>
    if (irq)
    80002a34:	a839                	j	80002a52 <devintr+0x76>
      virtio_disk_intr();
    80002a36:	00004097          	auipc	ra,0x4
    80002a3a:	b90080e7          	jalr	-1136(ra) # 800065c6 <virtio_disk_intr>
    if (irq)
    80002a3e:	a811                	j	80002a52 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a40:	85a6                	mv	a1,s1
    80002a42:	00006517          	auipc	a0,0x6
    80002a46:	86e50513          	addi	a0,a0,-1938 # 800082b0 <etext+0x2b0>
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	b60080e7          	jalr	-1184(ra) # 800005aa <printf>
      plic_complete(irq);
    80002a52:	8526                	mv	a0,s1
    80002a54:	00003097          	auipc	ra,0x3
    80002a58:	66c080e7          	jalr	1644(ra) # 800060c0 <plic_complete>
    return 1;
    80002a5c:	4505                	li	a0,1
    80002a5e:	64a2                	ld	s1,8(sp)
    80002a60:	b755                	j	80002a04 <devintr+0x28>
    if (cpuid() == 0)
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	fbc080e7          	jalr	-68(ra) # 80001a1e <cpuid>
    80002a6a:	c901                	beqz	a0,80002a7a <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a6c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a70:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a72:	14479073          	csrw	sip,a5
    return 2;
    80002a76:	4509                	li	a0,2
    80002a78:	b771                	j	80002a04 <devintr+0x28>
      clockintr();
    80002a7a:	00000097          	auipc	ra,0x0
    80002a7e:	f0e080e7          	jalr	-242(ra) # 80002988 <clockintr>
    80002a82:	b7ed                	j	80002a6c <devintr+0x90>
}
    80002a84:	8082                	ret

0000000080002a86 <usertrap>:
{
    80002a86:	1101                	addi	sp,sp,-32
    80002a88:	ec06                	sd	ra,24(sp)
    80002a8a:	e822                	sd	s0,16(sp)
    80002a8c:	e426                	sd	s1,8(sp)
    80002a8e:	e04a                	sd	s2,0(sp)
    80002a90:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a92:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a96:	1007f793          	andi	a5,a5,256
    80002a9a:	e3b1                	bnez	a5,80002ade <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9c:	00003797          	auipc	a5,0x3
    80002aa0:	4f478793          	addi	a5,a5,1268 # 80005f90 <kernelvec>
    80002aa4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	fa2080e7          	jalr	-94(ra) # 80001a4a <myproc>
    80002ab0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ab2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ab4:	14102773          	csrr	a4,sepc
    80002ab8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aba:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002abe:	47a1                	li	a5,8
    80002ac0:	02f70763          	beq	a4,a5,80002aee <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002ac4:	00000097          	auipc	ra,0x0
    80002ac8:	f18080e7          	jalr	-232(ra) # 800029dc <devintr>
    80002acc:	892a                	mv	s2,a0
    80002ace:	c151                	beqz	a0,80002b52 <usertrap+0xcc>
  if (killed(p))
    80002ad0:	8526                	mv	a0,s1
    80002ad2:	00000097          	auipc	ra,0x0
    80002ad6:	910080e7          	jalr	-1776(ra) # 800023e2 <killed>
    80002ada:	c929                	beqz	a0,80002b2c <usertrap+0xa6>
    80002adc:	a099                	j	80002b22 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ade:	00005517          	auipc	a0,0x5
    80002ae2:	7f250513          	addi	a0,a0,2034 # 800082d0 <etext+0x2d0>
    80002ae6:	ffffe097          	auipc	ra,0xffffe
    80002aea:	a7a080e7          	jalr	-1414(ra) # 80000560 <panic>
    if (killed(p))
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	8f4080e7          	jalr	-1804(ra) # 800023e2 <killed>
    80002af6:	e921                	bnez	a0,80002b46 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002af8:	6cb8                	ld	a4,88(s1)
    80002afa:	6f1c                	ld	a5,24(a4)
    80002afc:	0791                	addi	a5,a5,4
    80002afe:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b00:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b04:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b08:	10079073          	csrw	sstatus,a5
    syscall();
    80002b0c:	00000097          	auipc	ra,0x0
    80002b10:	2d4080e7          	jalr	724(ra) # 80002de0 <syscall>
  if (killed(p))
    80002b14:	8526                	mv	a0,s1
    80002b16:	00000097          	auipc	ra,0x0
    80002b1a:	8cc080e7          	jalr	-1844(ra) # 800023e2 <killed>
    80002b1e:	c911                	beqz	a0,80002b32 <usertrap+0xac>
    80002b20:	4901                	li	s2,0
    exit(-1);
    80002b22:	557d                	li	a0,-1
    80002b24:	fffff097          	auipc	ra,0xfffff
    80002b28:	73e080e7          	jalr	1854(ra) # 80002262 <exit>
  if (which_dev == 2)
    80002b2c:	4789                	li	a5,2
    80002b2e:	04f90f63          	beq	s2,a5,80002b8c <usertrap+0x106>
  usertrapret();
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	dc0080e7          	jalr	-576(ra) # 800028f2 <usertrapret>
}
    80002b3a:	60e2                	ld	ra,24(sp)
    80002b3c:	6442                	ld	s0,16(sp)
    80002b3e:	64a2                	ld	s1,8(sp)
    80002b40:	6902                	ld	s2,0(sp)
    80002b42:	6105                	addi	sp,sp,32
    80002b44:	8082                	ret
      exit(-1);
    80002b46:	557d                	li	a0,-1
    80002b48:	fffff097          	auipc	ra,0xfffff
    80002b4c:	71a080e7          	jalr	1818(ra) # 80002262 <exit>
    80002b50:	b765                	j	80002af8 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b52:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b56:	5890                	lw	a2,48(s1)
    80002b58:	00005517          	auipc	a0,0x5
    80002b5c:	79850513          	addi	a0,a0,1944 # 800082f0 <etext+0x2f0>
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	a4a080e7          	jalr	-1462(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b68:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b6c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b70:	00005517          	auipc	a0,0x5
    80002b74:	7b050513          	addi	a0,a0,1968 # 80008320 <etext+0x320>
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	a32080e7          	jalr	-1486(ra) # 800005aa <printf>
    setkilled(p);
    80002b80:	8526                	mv	a0,s1
    80002b82:	00000097          	auipc	ra,0x0
    80002b86:	834080e7          	jalr	-1996(ra) # 800023b6 <setkilled>
    80002b8a:	b769                	j	80002b14 <usertrap+0x8e>
    yield();
    80002b8c:	fffff097          	auipc	ra,0xfffff
    80002b90:	566080e7          	jalr	1382(ra) # 800020f2 <yield>
    80002b94:	bf79                	j	80002b32 <usertrap+0xac>

0000000080002b96 <kerneltrap>:
{
    80002b96:	7179                	addi	sp,sp,-48
    80002b98:	f406                	sd	ra,40(sp)
    80002b9a:	f022                	sd	s0,32(sp)
    80002b9c:	ec26                	sd	s1,24(sp)
    80002b9e:	e84a                	sd	s2,16(sp)
    80002ba0:	e44e                	sd	s3,8(sp)
    80002ba2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bac:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002bb0:	1004f793          	andi	a5,s1,256
    80002bb4:	cb85                	beqz	a5,80002be4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bba:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002bbc:	ef85                	bnez	a5,80002bf4 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002bbe:	00000097          	auipc	ra,0x0
    80002bc2:	e1e080e7          	jalr	-482(ra) # 800029dc <devintr>
    80002bc6:	cd1d                	beqz	a0,80002c04 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bc8:	4789                	li	a5,2
    80002bca:	06f50a63          	beq	a0,a5,80002c3e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bce:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bd2:	10049073          	csrw	sstatus,s1
}
    80002bd6:	70a2                	ld	ra,40(sp)
    80002bd8:	7402                	ld	s0,32(sp)
    80002bda:	64e2                	ld	s1,24(sp)
    80002bdc:	6942                	ld	s2,16(sp)
    80002bde:	69a2                	ld	s3,8(sp)
    80002be0:	6145                	addi	sp,sp,48
    80002be2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002be4:	00005517          	auipc	a0,0x5
    80002be8:	75c50513          	addi	a0,a0,1884 # 80008340 <etext+0x340>
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	974080e7          	jalr	-1676(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bf4:	00005517          	auipc	a0,0x5
    80002bf8:	77450513          	addi	a0,a0,1908 # 80008368 <etext+0x368>
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	964080e7          	jalr	-1692(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002c04:	85ce                	mv	a1,s3
    80002c06:	00005517          	auipc	a0,0x5
    80002c0a:	78250513          	addi	a0,a0,1922 # 80008388 <etext+0x388>
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	99c080e7          	jalr	-1636(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c16:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c1a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c1e:	00005517          	auipc	a0,0x5
    80002c22:	77a50513          	addi	a0,a0,1914 # 80008398 <etext+0x398>
    80002c26:	ffffe097          	auipc	ra,0xffffe
    80002c2a:	984080e7          	jalr	-1660(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002c2e:	00005517          	auipc	a0,0x5
    80002c32:	78250513          	addi	a0,a0,1922 # 800083b0 <etext+0x3b0>
    80002c36:	ffffe097          	auipc	ra,0xffffe
    80002c3a:	92a080e7          	jalr	-1750(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	e0c080e7          	jalr	-500(ra) # 80001a4a <myproc>
    80002c46:	d541                	beqz	a0,80002bce <kerneltrap+0x38>
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	e02080e7          	jalr	-510(ra) # 80001a4a <myproc>
    80002c50:	4d18                	lw	a4,24(a0)
    80002c52:	4791                	li	a5,4
    80002c54:	f6f71de3          	bne	a4,a5,80002bce <kerneltrap+0x38>
    yield();
    80002c58:	fffff097          	auipc	ra,0xfffff
    80002c5c:	49a080e7          	jalr	1178(ra) # 800020f2 <yield>
    80002c60:	b7bd                	j	80002bce <kerneltrap+0x38>

0000000080002c62 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c62:	1101                	addi	sp,sp,-32
    80002c64:	ec06                	sd	ra,24(sp)
    80002c66:	e822                	sd	s0,16(sp)
    80002c68:	e426                	sd	s1,8(sp)
    80002c6a:	1000                	addi	s0,sp,32
    80002c6c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c6e:	fffff097          	auipc	ra,0xfffff
    80002c72:	ddc080e7          	jalr	-548(ra) # 80001a4a <myproc>
  switch (n)
    80002c76:	4795                	li	a5,5
    80002c78:	0497e163          	bltu	a5,s1,80002cba <argraw+0x58>
    80002c7c:	048a                	slli	s1,s1,0x2
    80002c7e:	00006717          	auipc	a4,0x6
    80002c82:	af270713          	addi	a4,a4,-1294 # 80008770 <states.0+0x30>
    80002c86:	94ba                	add	s1,s1,a4
    80002c88:	409c                	lw	a5,0(s1)
    80002c8a:	97ba                	add	a5,a5,a4
    80002c8c:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002c8e:	6d3c                	ld	a5,88(a0)
    80002c90:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c92:	60e2                	ld	ra,24(sp)
    80002c94:	6442                	ld	s0,16(sp)
    80002c96:	64a2                	ld	s1,8(sp)
    80002c98:	6105                	addi	sp,sp,32
    80002c9a:	8082                	ret
    return p->trapframe->a1;
    80002c9c:	6d3c                	ld	a5,88(a0)
    80002c9e:	7fa8                	ld	a0,120(a5)
    80002ca0:	bfcd                	j	80002c92 <argraw+0x30>
    return p->trapframe->a2;
    80002ca2:	6d3c                	ld	a5,88(a0)
    80002ca4:	63c8                	ld	a0,128(a5)
    80002ca6:	b7f5                	j	80002c92 <argraw+0x30>
    return p->trapframe->a3;
    80002ca8:	6d3c                	ld	a5,88(a0)
    80002caa:	67c8                	ld	a0,136(a5)
    80002cac:	b7dd                	j	80002c92 <argraw+0x30>
    return p->trapframe->a4;
    80002cae:	6d3c                	ld	a5,88(a0)
    80002cb0:	6bc8                	ld	a0,144(a5)
    80002cb2:	b7c5                	j	80002c92 <argraw+0x30>
    return p->trapframe->a5;
    80002cb4:	6d3c                	ld	a5,88(a0)
    80002cb6:	6fc8                	ld	a0,152(a5)
    80002cb8:	bfe9                	j	80002c92 <argraw+0x30>
  panic("argraw");
    80002cba:	00005517          	auipc	a0,0x5
    80002cbe:	70650513          	addi	a0,a0,1798 # 800083c0 <etext+0x3c0>
    80002cc2:	ffffe097          	auipc	ra,0xffffe
    80002cc6:	89e080e7          	jalr	-1890(ra) # 80000560 <panic>

0000000080002cca <fetchaddr>:
{
    80002cca:	1101                	addi	sp,sp,-32
    80002ccc:	ec06                	sd	ra,24(sp)
    80002cce:	e822                	sd	s0,16(sp)
    80002cd0:	e426                	sd	s1,8(sp)
    80002cd2:	e04a                	sd	s2,0(sp)
    80002cd4:	1000                	addi	s0,sp,32
    80002cd6:	84aa                	mv	s1,a0
    80002cd8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	d70080e7          	jalr	-656(ra) # 80001a4a <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ce2:	653c                	ld	a5,72(a0)
    80002ce4:	02f4f863          	bgeu	s1,a5,80002d14 <fetchaddr+0x4a>
    80002ce8:	00848713          	addi	a4,s1,8
    80002cec:	02e7e663          	bltu	a5,a4,80002d18 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cf0:	46a1                	li	a3,8
    80002cf2:	8626                	mv	a2,s1
    80002cf4:	85ca                	mv	a1,s2
    80002cf6:	6928                	ld	a0,80(a0)
    80002cf8:	fffff097          	auipc	ra,0xfffff
    80002cfc:	a76080e7          	jalr	-1418(ra) # 8000176e <copyin>
    80002d00:	00a03533          	snez	a0,a0
    80002d04:	40a00533          	neg	a0,a0
}
    80002d08:	60e2                	ld	ra,24(sp)
    80002d0a:	6442                	ld	s0,16(sp)
    80002d0c:	64a2                	ld	s1,8(sp)
    80002d0e:	6902                	ld	s2,0(sp)
    80002d10:	6105                	addi	sp,sp,32
    80002d12:	8082                	ret
    return -1;
    80002d14:	557d                	li	a0,-1
    80002d16:	bfcd                	j	80002d08 <fetchaddr+0x3e>
    80002d18:	557d                	li	a0,-1
    80002d1a:	b7fd                	j	80002d08 <fetchaddr+0x3e>

0000000080002d1c <fetchstr>:
{
    80002d1c:	7179                	addi	sp,sp,-48
    80002d1e:	f406                	sd	ra,40(sp)
    80002d20:	f022                	sd	s0,32(sp)
    80002d22:	ec26                	sd	s1,24(sp)
    80002d24:	e84a                	sd	s2,16(sp)
    80002d26:	e44e                	sd	s3,8(sp)
    80002d28:	1800                	addi	s0,sp,48
    80002d2a:	892a                	mv	s2,a0
    80002d2c:	84ae                	mv	s1,a1
    80002d2e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	d1a080e7          	jalr	-742(ra) # 80001a4a <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d38:	86ce                	mv	a3,s3
    80002d3a:	864a                	mv	a2,s2
    80002d3c:	85a6                	mv	a1,s1
    80002d3e:	6928                	ld	a0,80(a0)
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	abc080e7          	jalr	-1348(ra) # 800017fc <copyinstr>
    80002d48:	00054e63          	bltz	a0,80002d64 <fetchstr+0x48>
  return strlen(buf);
    80002d4c:	8526                	mv	a0,s1
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	15a080e7          	jalr	346(ra) # 80000ea8 <strlen>
}
    80002d56:	70a2                	ld	ra,40(sp)
    80002d58:	7402                	ld	s0,32(sp)
    80002d5a:	64e2                	ld	s1,24(sp)
    80002d5c:	6942                	ld	s2,16(sp)
    80002d5e:	69a2                	ld	s3,8(sp)
    80002d60:	6145                	addi	sp,sp,48
    80002d62:	8082                	ret
    return -1;
    80002d64:	557d                	li	a0,-1
    80002d66:	bfc5                	j	80002d56 <fetchstr+0x3a>

0000000080002d68 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002d68:	1101                	addi	sp,sp,-32
    80002d6a:	ec06                	sd	ra,24(sp)
    80002d6c:	e822                	sd	s0,16(sp)
    80002d6e:	e426                	sd	s1,8(sp)
    80002d70:	1000                	addi	s0,sp,32
    80002d72:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	eee080e7          	jalr	-274(ra) # 80002c62 <argraw>
    80002d7c:	c088                	sw	a0,0(s1)
}
    80002d7e:	60e2                	ld	ra,24(sp)
    80002d80:	6442                	ld	s0,16(sp)
    80002d82:	64a2                	ld	s1,8(sp)
    80002d84:	6105                	addi	sp,sp,32
    80002d86:	8082                	ret

0000000080002d88 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002d88:	1101                	addi	sp,sp,-32
    80002d8a:	ec06                	sd	ra,24(sp)
    80002d8c:	e822                	sd	s0,16(sp)
    80002d8e:	e426                	sd	s1,8(sp)
    80002d90:	1000                	addi	s0,sp,32
    80002d92:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d94:	00000097          	auipc	ra,0x0
    80002d98:	ece080e7          	jalr	-306(ra) # 80002c62 <argraw>
    80002d9c:	e088                	sd	a0,0(s1)
}
    80002d9e:	60e2                	ld	ra,24(sp)
    80002da0:	6442                	ld	s0,16(sp)
    80002da2:	64a2                	ld	s1,8(sp)
    80002da4:	6105                	addi	sp,sp,32
    80002da6:	8082                	ret

0000000080002da8 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002da8:	7179                	addi	sp,sp,-48
    80002daa:	f406                	sd	ra,40(sp)
    80002dac:	f022                	sd	s0,32(sp)
    80002dae:	ec26                	sd	s1,24(sp)
    80002db0:	e84a                	sd	s2,16(sp)
    80002db2:	1800                	addi	s0,sp,48
    80002db4:	84ae                	mv	s1,a1
    80002db6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002db8:	fd840593          	addi	a1,s0,-40
    80002dbc:	00000097          	auipc	ra,0x0
    80002dc0:	fcc080e7          	jalr	-52(ra) # 80002d88 <argaddr>
  return fetchstr(addr, buf, max);
    80002dc4:	864a                	mv	a2,s2
    80002dc6:	85a6                	mv	a1,s1
    80002dc8:	fd843503          	ld	a0,-40(s0)
    80002dcc:	00000097          	auipc	ra,0x0
    80002dd0:	f50080e7          	jalr	-176(ra) # 80002d1c <fetchstr>
}
    80002dd4:	70a2                	ld	ra,40(sp)
    80002dd6:	7402                	ld	s0,32(sp)
    80002dd8:	64e2                	ld	s1,24(sp)
    80002dda:	6942                	ld	s2,16(sp)
    80002ddc:	6145                	addi	sp,sp,48
    80002dde:	8082                	ret

0000000080002de0 <syscall>:
};

// Add a new array to keep track of syscall counts
uint64 syscall_counts[NSYSCALLS] = {0};
void syscall(void)
{
    80002de0:	7179                	addi	sp,sp,-48
    80002de2:	f406                	sd	ra,40(sp)
    80002de4:	f022                	sd	s0,32(sp)
    80002de6:	ec26                	sd	s1,24(sp)
    80002de8:	e84a                	sd	s2,16(sp)
    80002dea:	e44e                	sd	s3,8(sp)
    80002dec:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002dee:	fffff097          	auipc	ra,0xfffff
    80002df2:	c5c080e7          	jalr	-932(ra) # 80001a4a <myproc>
    80002df6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002df8:	05853983          	ld	s3,88(a0)
    80002dfc:	0a89b783          	ld	a5,168(s3)
    80002e00:	0007891b          	sext.w	s2,a5
  if (num > 0 && num < NSYSCALLS && syscalls[num])
    80002e04:	37fd                	addiw	a5,a5,-1
    80002e06:	4759                	li	a4,22
    80002e08:	02f76863          	bltu	a4,a5,80002e38 <syscall+0x58>
    80002e0c:	00391713          	slli	a4,s2,0x3
    80002e10:	00006797          	auipc	a5,0x6
    80002e14:	97878793          	addi	a5,a5,-1672 # 80008788 <syscalls>
    80002e18:	97ba                	add	a5,a5,a4
    80002e1a:	639c                	ld	a5,0(a5)
    80002e1c:	cf91                	beqz	a5,80002e38 <syscall+0x58>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e1e:	9782                	jalr	a5
    80002e20:	06a9b823          	sd	a0,112(s3)
    syscall_counts[num]++; // Increment the count for this syscall
    80002e24:	090e                	slli	s2,s2,0x3
    80002e26:	0001a797          	auipc	a5,0x1a
    80002e2a:	92278793          	addi	a5,a5,-1758 # 8001c748 <syscall_counts>
    80002e2e:	97ca                	add	a5,a5,s2
    80002e30:	6398                	ld	a4,0(a5)
    80002e32:	0705                	addi	a4,a4,1
    80002e34:	e398                	sd	a4,0(a5)
    80002e36:	a005                	j	80002e56 <syscall+0x76>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002e38:	86ca                	mv	a3,s2
    80002e3a:	15848613          	addi	a2,s1,344
    80002e3e:	588c                	lw	a1,48(s1)
    80002e40:	00005517          	auipc	a0,0x5
    80002e44:	58850513          	addi	a0,a0,1416 # 800083c8 <etext+0x3c8>
    80002e48:	ffffd097          	auipc	ra,0xffffd
    80002e4c:	762080e7          	jalr	1890(ra) # 800005aa <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e50:	6cbc                	ld	a5,88(s1)
    80002e52:	577d                	li	a4,-1
    80002e54:	fbb8                	sd	a4,112(a5)
  }
}
    80002e56:	70a2                	ld	ra,40(sp)
    80002e58:	7402                	ld	s0,32(sp)
    80002e5a:	64e2                	ld	s1,24(sp)
    80002e5c:	6942                	ld	s2,16(sp)
    80002e5e:	69a2                	ld	s3,8(sp)
    80002e60:	6145                	addi	sp,sp,48
    80002e62:	8082                	ret

0000000080002e64 <sys_exit>:

extern uint64 syscall_counts[];

uint64
sys_exit(void)
{
    80002e64:	1101                	addi	sp,sp,-32
    80002e66:	ec06                	sd	ra,24(sp)
    80002e68:	e822                	sd	s0,16(sp)
    80002e6a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e6c:	fec40593          	addi	a1,s0,-20
    80002e70:	4501                	li	a0,0
    80002e72:	00000097          	auipc	ra,0x0
    80002e76:	ef6080e7          	jalr	-266(ra) # 80002d68 <argint>
  exit(n);
    80002e7a:	fec42503          	lw	a0,-20(s0)
    80002e7e:	fffff097          	auipc	ra,0xfffff
    80002e82:	3e4080e7          	jalr	996(ra) # 80002262 <exit>
  return 0; // not reached
}
    80002e86:	4501                	li	a0,0
    80002e88:	60e2                	ld	ra,24(sp)
    80002e8a:	6442                	ld	s0,16(sp)
    80002e8c:	6105                	addi	sp,sp,32
    80002e8e:	8082                	ret

0000000080002e90 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e90:	1141                	addi	sp,sp,-16
    80002e92:	e406                	sd	ra,8(sp)
    80002e94:	e022                	sd	s0,0(sp)
    80002e96:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e98:	fffff097          	auipc	ra,0xfffff
    80002e9c:	bb2080e7          	jalr	-1102(ra) # 80001a4a <myproc>
}
    80002ea0:	5908                	lw	a0,48(a0)
    80002ea2:	60a2                	ld	ra,8(sp)
    80002ea4:	6402                	ld	s0,0(sp)
    80002ea6:	0141                	addi	sp,sp,16
    80002ea8:	8082                	ret

0000000080002eaa <sys_fork>:

uint64
sys_fork(void)
{
    80002eaa:	1141                	addi	sp,sp,-16
    80002eac:	e406                	sd	ra,8(sp)
    80002eae:	e022                	sd	s0,0(sp)
    80002eb0:	0800                	addi	s0,sp,16
  return fork();
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	f74080e7          	jalr	-140(ra) # 80001e26 <fork>
}
    80002eba:	60a2                	ld	ra,8(sp)
    80002ebc:	6402                	ld	s0,0(sp)
    80002ebe:	0141                	addi	sp,sp,16
    80002ec0:	8082                	ret

0000000080002ec2 <sys_wait>:

uint64
sys_wait(void)
{
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002eca:	fe840593          	addi	a1,s0,-24
    80002ece:	4501                	li	a0,0
    80002ed0:	00000097          	auipc	ra,0x0
    80002ed4:	eb8080e7          	jalr	-328(ra) # 80002d88 <argaddr>
  return wait(p);
    80002ed8:	fe843503          	ld	a0,-24(s0)
    80002edc:	fffff097          	auipc	ra,0xfffff
    80002ee0:	538080e7          	jalr	1336(ra) # 80002414 <wait>
}
    80002ee4:	60e2                	ld	ra,24(sp)
    80002ee6:	6442                	ld	s0,16(sp)
    80002ee8:	6105                	addi	sp,sp,32
    80002eea:	8082                	ret

0000000080002eec <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002eec:	7179                	addi	sp,sp,-48
    80002eee:	f406                	sd	ra,40(sp)
    80002ef0:	f022                	sd	s0,32(sp)
    80002ef2:	ec26                	sd	s1,24(sp)
    80002ef4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ef6:	fdc40593          	addi	a1,s0,-36
    80002efa:	4501                	li	a0,0
    80002efc:	00000097          	auipc	ra,0x0
    80002f00:	e6c080e7          	jalr	-404(ra) # 80002d68 <argint>
  addr = myproc()->sz;
    80002f04:	fffff097          	auipc	ra,0xfffff
    80002f08:	b46080e7          	jalr	-1210(ra) # 80001a4a <myproc>
    80002f0c:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002f0e:	fdc42503          	lw	a0,-36(s0)
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	eb8080e7          	jalr	-328(ra) # 80001dca <growproc>
    80002f1a:	00054863          	bltz	a0,80002f2a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f1e:	8526                	mv	a0,s1
    80002f20:	70a2                	ld	ra,40(sp)
    80002f22:	7402                	ld	s0,32(sp)
    80002f24:	64e2                	ld	s1,24(sp)
    80002f26:	6145                	addi	sp,sp,48
    80002f28:	8082                	ret
    return -1;
    80002f2a:	54fd                	li	s1,-1
    80002f2c:	bfcd                	j	80002f1e <sys_sbrk+0x32>

0000000080002f2e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f2e:	7139                	addi	sp,sp,-64
    80002f30:	fc06                	sd	ra,56(sp)
    80002f32:	f822                	sd	s0,48(sp)
    80002f34:	f04a                	sd	s2,32(sp)
    80002f36:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f38:	fcc40593          	addi	a1,s0,-52
    80002f3c:	4501                	li	a0,0
    80002f3e:	00000097          	auipc	ra,0x0
    80002f42:	e2a080e7          	jalr	-470(ra) # 80002d68 <argint>
  acquire(&tickslock);
    80002f46:	00019517          	auipc	a0,0x19
    80002f4a:	7ea50513          	addi	a0,a0,2026 # 8001c730 <tickslock>
    80002f4e:	ffffe097          	auipc	ra,0xffffe
    80002f52:	cea080e7          	jalr	-790(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80002f56:	00008917          	auipc	s2,0x8
    80002f5a:	33a92903          	lw	s2,826(s2) # 8000b290 <ticks>
  while (ticks - ticks0 < n)
    80002f5e:	fcc42783          	lw	a5,-52(s0)
    80002f62:	c3b9                	beqz	a5,80002fa8 <sys_sleep+0x7a>
    80002f64:	f426                	sd	s1,40(sp)
    80002f66:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f68:	00019997          	auipc	s3,0x19
    80002f6c:	7c898993          	addi	s3,s3,1992 # 8001c730 <tickslock>
    80002f70:	00008497          	auipc	s1,0x8
    80002f74:	32048493          	addi	s1,s1,800 # 8000b290 <ticks>
    if (killed(myproc()))
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	ad2080e7          	jalr	-1326(ra) # 80001a4a <myproc>
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	462080e7          	jalr	1122(ra) # 800023e2 <killed>
    80002f88:	ed15                	bnez	a0,80002fc4 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f8a:	85ce                	mv	a1,s3
    80002f8c:	8526                	mv	a0,s1
    80002f8e:	fffff097          	auipc	ra,0xfffff
    80002f92:	1a0080e7          	jalr	416(ra) # 8000212e <sleep>
  while (ticks - ticks0 < n)
    80002f96:	409c                	lw	a5,0(s1)
    80002f98:	412787bb          	subw	a5,a5,s2
    80002f9c:	fcc42703          	lw	a4,-52(s0)
    80002fa0:	fce7ece3          	bltu	a5,a4,80002f78 <sys_sleep+0x4a>
    80002fa4:	74a2                	ld	s1,40(sp)
    80002fa6:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002fa8:	00019517          	auipc	a0,0x19
    80002fac:	78850513          	addi	a0,a0,1928 # 8001c730 <tickslock>
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	d3c080e7          	jalr	-708(ra) # 80000cec <release>
  return 0;
    80002fb8:	4501                	li	a0,0
}
    80002fba:	70e2                	ld	ra,56(sp)
    80002fbc:	7442                	ld	s0,48(sp)
    80002fbe:	7902                	ld	s2,32(sp)
    80002fc0:	6121                	addi	sp,sp,64
    80002fc2:	8082                	ret
      release(&tickslock);
    80002fc4:	00019517          	auipc	a0,0x19
    80002fc8:	76c50513          	addi	a0,a0,1900 # 8001c730 <tickslock>
    80002fcc:	ffffe097          	auipc	ra,0xffffe
    80002fd0:	d20080e7          	jalr	-736(ra) # 80000cec <release>
      return -1;
    80002fd4:	557d                	li	a0,-1
    80002fd6:	74a2                	ld	s1,40(sp)
    80002fd8:	69e2                	ld	s3,24(sp)
    80002fda:	b7c5                	j	80002fba <sys_sleep+0x8c>

0000000080002fdc <sys_kill>:

uint64
sys_kill(void)
{
    80002fdc:	1101                	addi	sp,sp,-32
    80002fde:	ec06                	sd	ra,24(sp)
    80002fe0:	e822                	sd	s0,16(sp)
    80002fe2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fe4:	fec40593          	addi	a1,s0,-20
    80002fe8:	4501                	li	a0,0
    80002fea:	00000097          	auipc	ra,0x0
    80002fee:	d7e080e7          	jalr	-642(ra) # 80002d68 <argint>
  return kill(pid);
    80002ff2:	fec42503          	lw	a0,-20(s0)
    80002ff6:	fffff097          	auipc	ra,0xfffff
    80002ffa:	34e080e7          	jalr	846(ra) # 80002344 <kill>
}
    80002ffe:	60e2                	ld	ra,24(sp)
    80003000:	6442                	ld	s0,16(sp)
    80003002:	6105                	addi	sp,sp,32
    80003004:	8082                	ret

0000000080003006 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003006:	1101                	addi	sp,sp,-32
    80003008:	ec06                	sd	ra,24(sp)
    8000300a:	e822                	sd	s0,16(sp)
    8000300c:	e426                	sd	s1,8(sp)
    8000300e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003010:	00019517          	auipc	a0,0x19
    80003014:	72050513          	addi	a0,a0,1824 # 8001c730 <tickslock>
    80003018:	ffffe097          	auipc	ra,0xffffe
    8000301c:	c20080e7          	jalr	-992(ra) # 80000c38 <acquire>
  xticks = ticks;
    80003020:	00008497          	auipc	s1,0x8
    80003024:	2704a483          	lw	s1,624(s1) # 8000b290 <ticks>
  release(&tickslock);
    80003028:	00019517          	auipc	a0,0x19
    8000302c:	70850513          	addi	a0,a0,1800 # 8001c730 <tickslock>
    80003030:	ffffe097          	auipc	ra,0xffffe
    80003034:	cbc080e7          	jalr	-836(ra) # 80000cec <release>
  return xticks;
}
    80003038:	02049513          	slli	a0,s1,0x20
    8000303c:	9101                	srli	a0,a0,0x20
    8000303e:	60e2                	ld	ra,24(sp)
    80003040:	6442                	ld	s0,16(sp)
    80003042:	64a2                	ld	s1,8(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret

0000000080003048 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003048:	7139                	addi	sp,sp,-64
    8000304a:	fc06                	sd	ra,56(sp)
    8000304c:	f822                	sd	s0,48(sp)
    8000304e:	f426                	sd	s1,40(sp)
    80003050:	f04a                	sd	s2,32(sp)
    80003052:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003054:	fd840593          	addi	a1,s0,-40
    80003058:	4501                	li	a0,0
    8000305a:	00000097          	auipc	ra,0x0
    8000305e:	d2e080e7          	jalr	-722(ra) # 80002d88 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003062:	fd040593          	addi	a1,s0,-48
    80003066:	4505                	li	a0,1
    80003068:	00000097          	auipc	ra,0x0
    8000306c:	d20080e7          	jalr	-736(ra) # 80002d88 <argaddr>
  argaddr(2, &addr2);
    80003070:	fc840593          	addi	a1,s0,-56
    80003074:	4509                	li	a0,2
    80003076:	00000097          	auipc	ra,0x0
    8000307a:	d12080e7          	jalr	-750(ra) # 80002d88 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000307e:	fc040613          	addi	a2,s0,-64
    80003082:	fc440593          	addi	a1,s0,-60
    80003086:	fd843503          	ld	a0,-40(s0)
    8000308a:	fffff097          	auipc	ra,0xfffff
    8000308e:	614080e7          	jalr	1556(ra) # 8000269e <waitx>
    80003092:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003094:	fffff097          	auipc	ra,0xfffff
    80003098:	9b6080e7          	jalr	-1610(ra) # 80001a4a <myproc>
    8000309c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000309e:	4691                	li	a3,4
    800030a0:	fc440613          	addi	a2,s0,-60
    800030a4:	fd043583          	ld	a1,-48(s0)
    800030a8:	6928                	ld	a0,80(a0)
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	638080e7          	jalr	1592(ra) # 800016e2 <copyout>
    return -1;
    800030b2:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030b4:	00054f63          	bltz	a0,800030d2 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800030b8:	4691                	li	a3,4
    800030ba:	fc040613          	addi	a2,s0,-64
    800030be:	fc843583          	ld	a1,-56(s0)
    800030c2:	68a8                	ld	a0,80(s1)
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	61e080e7          	jalr	1566(ra) # 800016e2 <copyout>
    800030cc:	00054a63          	bltz	a0,800030e0 <sys_waitx+0x98>
    return -1;
  return ret;
    800030d0:	87ca                	mv	a5,s2
}
    800030d2:	853e                	mv	a0,a5
    800030d4:	70e2                	ld	ra,56(sp)
    800030d6:	7442                	ld	s0,48(sp)
    800030d8:	74a2                	ld	s1,40(sp)
    800030da:	7902                	ld	s2,32(sp)
    800030dc:	6121                	addi	sp,sp,64
    800030de:	8082                	ret
    return -1;
    800030e0:	57fd                	li	a5,-1
    800030e2:	bfc5                	j	800030d2 <sys_waitx+0x8a>

00000000800030e4 <sys_getsyscount>:

uint64
sys_getsyscount(void)
{
    800030e4:	1101                	addi	sp,sp,-32
    800030e6:	ec06                	sd	ra,24(sp)
    800030e8:	e822                	sd	s0,16(sp)
    800030ea:	1000                	addi	s0,sp,32
  int mask;
  argint(0, &mask); // argint is a void function, it directly sets the value of mask
    800030ec:	fec40593          	addi	a1,s0,-20
    800030f0:	4501                	li	a0,0
    800030f2:	00000097          	auipc	ra,0x0
    800030f6:	c76080e7          	jalr	-906(ra) # 80002d68 <argint>

  // Find the syscall number from the mask
  int syscall_num = -1;
  for (int i = 1; i < NSYSCALLS; i++)
  {
    if (mask == (1 << i))
    800030fa:	fec42603          	lw	a2,-20(s0)
  for (int i = 1; i < NSYSCALLS; i++)
    800030fe:	4785                	li	a5,1
    if (mask == (1 << i))
    80003100:	4685                	li	a3,1
  for (int i = 1; i < NSYSCALLS; i++)
    80003102:	45e1                	li	a1,24
    if (mask == (1 << i))
    80003104:	00f6973b          	sllw	a4,a3,a5
    80003108:	00c70763          	beq	a4,a2,80003116 <sys_getsyscount+0x32>
  for (int i = 1; i < NSYSCALLS; i++)
    8000310c:	2785                	addiw	a5,a5,1
    8000310e:	feb79be3          	bne	a5,a1,80003104 <sys_getsyscount+0x20>
      break;
    }
  }

  if (syscall_num == -1 || syscall_num >= NSYSCALLS)
    return -1;
    80003112:	557d                	li	a0,-1
    80003114:	a829                	j	8000312e <sys_getsyscount+0x4a>
  if (syscall_num == -1 || syscall_num >= NSYSCALLS)
    80003116:	577d                	li	a4,-1
    80003118:	00e78f63          	beq	a5,a4,80003136 <sys_getsyscount+0x52>

  uint64 count = syscall_counts[syscall_num];
    8000311c:	078e                	slli	a5,a5,0x3
    8000311e:	00019717          	auipc	a4,0x19
    80003122:	62a70713          	addi	a4,a4,1578 # 8001c748 <syscall_counts>
    80003126:	97ba                	add	a5,a5,a4
    80003128:	6388                	ld	a0,0(a5)
  syscall_counts[syscall_num] = 0; // Reset the count after reading
    8000312a:	0007b023          	sd	zero,0(a5)
  return count;
}
    8000312e:	60e2                	ld	ra,24(sp)
    80003130:	6442                	ld	s0,16(sp)
    80003132:	6105                	addi	sp,sp,32
    80003134:	8082                	ret
    return -1;
    80003136:	557d                	li	a0,-1
    80003138:	bfdd                	j	8000312e <sys_getsyscount+0x4a>

000000008000313a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000313a:	7179                	addi	sp,sp,-48
    8000313c:	f406                	sd	ra,40(sp)
    8000313e:	f022                	sd	s0,32(sp)
    80003140:	ec26                	sd	s1,24(sp)
    80003142:	e84a                	sd	s2,16(sp)
    80003144:	e44e                	sd	s3,8(sp)
    80003146:	e052                	sd	s4,0(sp)
    80003148:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000314a:	00005597          	auipc	a1,0x5
    8000314e:	29e58593          	addi	a1,a1,670 # 800083e8 <etext+0x3e8>
    80003152:	00019517          	auipc	a0,0x19
    80003156:	6b650513          	addi	a0,a0,1718 # 8001c808 <bcache>
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	a4e080e7          	jalr	-1458(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003162:	00021797          	auipc	a5,0x21
    80003166:	6a678793          	addi	a5,a5,1702 # 80024808 <bcache+0x8000>
    8000316a:	00022717          	auipc	a4,0x22
    8000316e:	90670713          	addi	a4,a4,-1786 # 80024a70 <bcache+0x8268>
    80003172:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003176:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000317a:	00019497          	auipc	s1,0x19
    8000317e:	6a648493          	addi	s1,s1,1702 # 8001c820 <bcache+0x18>
    b->next = bcache.head.next;
    80003182:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003184:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003186:	00005a17          	auipc	s4,0x5
    8000318a:	26aa0a13          	addi	s4,s4,618 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    8000318e:	2b893783          	ld	a5,696(s2)
    80003192:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003194:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003198:	85d2                	mv	a1,s4
    8000319a:	01048513          	addi	a0,s1,16
    8000319e:	00001097          	auipc	ra,0x1
    800031a2:	4e8080e7          	jalr	1256(ra) # 80004686 <initsleeplock>
    bcache.head.next->prev = b;
    800031a6:	2b893783          	ld	a5,696(s2)
    800031aa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031ac:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031b0:	45848493          	addi	s1,s1,1112
    800031b4:	fd349de3          	bne	s1,s3,8000318e <binit+0x54>
  }
}
    800031b8:	70a2                	ld	ra,40(sp)
    800031ba:	7402                	ld	s0,32(sp)
    800031bc:	64e2                	ld	s1,24(sp)
    800031be:	6942                	ld	s2,16(sp)
    800031c0:	69a2                	ld	s3,8(sp)
    800031c2:	6a02                	ld	s4,0(sp)
    800031c4:	6145                	addi	sp,sp,48
    800031c6:	8082                	ret

00000000800031c8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031c8:	7179                	addi	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	e84a                	sd	s2,16(sp)
    800031d2:	e44e                	sd	s3,8(sp)
    800031d4:	1800                	addi	s0,sp,48
    800031d6:	892a                	mv	s2,a0
    800031d8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031da:	00019517          	auipc	a0,0x19
    800031de:	62e50513          	addi	a0,a0,1582 # 8001c808 <bcache>
    800031e2:	ffffe097          	auipc	ra,0xffffe
    800031e6:	a56080e7          	jalr	-1450(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031ea:	00022497          	auipc	s1,0x22
    800031ee:	8d64b483          	ld	s1,-1834(s1) # 80024ac0 <bcache+0x82b8>
    800031f2:	00022797          	auipc	a5,0x22
    800031f6:	87e78793          	addi	a5,a5,-1922 # 80024a70 <bcache+0x8268>
    800031fa:	02f48f63          	beq	s1,a5,80003238 <bread+0x70>
    800031fe:	873e                	mv	a4,a5
    80003200:	a021                	j	80003208 <bread+0x40>
    80003202:	68a4                	ld	s1,80(s1)
    80003204:	02e48a63          	beq	s1,a4,80003238 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003208:	449c                	lw	a5,8(s1)
    8000320a:	ff279ce3          	bne	a5,s2,80003202 <bread+0x3a>
    8000320e:	44dc                	lw	a5,12(s1)
    80003210:	ff3799e3          	bne	a5,s3,80003202 <bread+0x3a>
      b->refcnt++;
    80003214:	40bc                	lw	a5,64(s1)
    80003216:	2785                	addiw	a5,a5,1
    80003218:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000321a:	00019517          	auipc	a0,0x19
    8000321e:	5ee50513          	addi	a0,a0,1518 # 8001c808 <bcache>
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	aca080e7          	jalr	-1334(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    8000322a:	01048513          	addi	a0,s1,16
    8000322e:	00001097          	auipc	ra,0x1
    80003232:	492080e7          	jalr	1170(ra) # 800046c0 <acquiresleep>
      return b;
    80003236:	a8b9                	j	80003294 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003238:	00022497          	auipc	s1,0x22
    8000323c:	8804b483          	ld	s1,-1920(s1) # 80024ab8 <bcache+0x82b0>
    80003240:	00022797          	auipc	a5,0x22
    80003244:	83078793          	addi	a5,a5,-2000 # 80024a70 <bcache+0x8268>
    80003248:	00f48863          	beq	s1,a5,80003258 <bread+0x90>
    8000324c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000324e:	40bc                	lw	a5,64(s1)
    80003250:	cf81                	beqz	a5,80003268 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003252:	64a4                	ld	s1,72(s1)
    80003254:	fee49de3          	bne	s1,a4,8000324e <bread+0x86>
  panic("bget: no buffers");
    80003258:	00005517          	auipc	a0,0x5
    8000325c:	1a050513          	addi	a0,a0,416 # 800083f8 <etext+0x3f8>
    80003260:	ffffd097          	auipc	ra,0xffffd
    80003264:	300080e7          	jalr	768(ra) # 80000560 <panic>
      b->dev = dev;
    80003268:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000326c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003270:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003274:	4785                	li	a5,1
    80003276:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003278:	00019517          	auipc	a0,0x19
    8000327c:	59050513          	addi	a0,a0,1424 # 8001c808 <bcache>
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	a6c080e7          	jalr	-1428(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003288:	01048513          	addi	a0,s1,16
    8000328c:	00001097          	auipc	ra,0x1
    80003290:	434080e7          	jalr	1076(ra) # 800046c0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003294:	409c                	lw	a5,0(s1)
    80003296:	cb89                	beqz	a5,800032a8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003298:	8526                	mv	a0,s1
    8000329a:	70a2                	ld	ra,40(sp)
    8000329c:	7402                	ld	s0,32(sp)
    8000329e:	64e2                	ld	s1,24(sp)
    800032a0:	6942                	ld	s2,16(sp)
    800032a2:	69a2                	ld	s3,8(sp)
    800032a4:	6145                	addi	sp,sp,48
    800032a6:	8082                	ret
    virtio_disk_rw(b, 0);
    800032a8:	4581                	li	a1,0
    800032aa:	8526                	mv	a0,s1
    800032ac:	00003097          	auipc	ra,0x3
    800032b0:	0ec080e7          	jalr	236(ra) # 80006398 <virtio_disk_rw>
    b->valid = 1;
    800032b4:	4785                	li	a5,1
    800032b6:	c09c                	sw	a5,0(s1)
  return b;
    800032b8:	b7c5                	j	80003298 <bread+0xd0>

00000000800032ba <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	addi	s0,sp,32
    800032c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032c6:	0541                	addi	a0,a0,16
    800032c8:	00001097          	auipc	ra,0x1
    800032cc:	492080e7          	jalr	1170(ra) # 8000475a <holdingsleep>
    800032d0:	cd01                	beqz	a0,800032e8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032d2:	4585                	li	a1,1
    800032d4:	8526                	mv	a0,s1
    800032d6:	00003097          	auipc	ra,0x3
    800032da:	0c2080e7          	jalr	194(ra) # 80006398 <virtio_disk_rw>
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6105                	addi	sp,sp,32
    800032e6:	8082                	ret
    panic("bwrite");
    800032e8:	00005517          	auipc	a0,0x5
    800032ec:	12850513          	addi	a0,a0,296 # 80008410 <etext+0x410>
    800032f0:	ffffd097          	auipc	ra,0xffffd
    800032f4:	270080e7          	jalr	624(ra) # 80000560 <panic>

00000000800032f8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032f8:	1101                	addi	sp,sp,-32
    800032fa:	ec06                	sd	ra,24(sp)
    800032fc:	e822                	sd	s0,16(sp)
    800032fe:	e426                	sd	s1,8(sp)
    80003300:	e04a                	sd	s2,0(sp)
    80003302:	1000                	addi	s0,sp,32
    80003304:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003306:	01050913          	addi	s2,a0,16
    8000330a:	854a                	mv	a0,s2
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	44e080e7          	jalr	1102(ra) # 8000475a <holdingsleep>
    80003314:	c925                	beqz	a0,80003384 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003316:	854a                	mv	a0,s2
    80003318:	00001097          	auipc	ra,0x1
    8000331c:	3fe080e7          	jalr	1022(ra) # 80004716 <releasesleep>

  acquire(&bcache.lock);
    80003320:	00019517          	auipc	a0,0x19
    80003324:	4e850513          	addi	a0,a0,1256 # 8001c808 <bcache>
    80003328:	ffffe097          	auipc	ra,0xffffe
    8000332c:	910080e7          	jalr	-1776(ra) # 80000c38 <acquire>
  b->refcnt--;
    80003330:	40bc                	lw	a5,64(s1)
    80003332:	37fd                	addiw	a5,a5,-1
    80003334:	0007871b          	sext.w	a4,a5
    80003338:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000333a:	e71d                	bnez	a4,80003368 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000333c:	68b8                	ld	a4,80(s1)
    8000333e:	64bc                	ld	a5,72(s1)
    80003340:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003342:	68b8                	ld	a4,80(s1)
    80003344:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003346:	00021797          	auipc	a5,0x21
    8000334a:	4c278793          	addi	a5,a5,1218 # 80024808 <bcache+0x8000>
    8000334e:	2b87b703          	ld	a4,696(a5)
    80003352:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003354:	00021717          	auipc	a4,0x21
    80003358:	71c70713          	addi	a4,a4,1820 # 80024a70 <bcache+0x8268>
    8000335c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000335e:	2b87b703          	ld	a4,696(a5)
    80003362:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003364:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003368:	00019517          	auipc	a0,0x19
    8000336c:	4a050513          	addi	a0,a0,1184 # 8001c808 <bcache>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	97c080e7          	jalr	-1668(ra) # 80000cec <release>
}
    80003378:	60e2                	ld	ra,24(sp)
    8000337a:	6442                	ld	s0,16(sp)
    8000337c:	64a2                	ld	s1,8(sp)
    8000337e:	6902                	ld	s2,0(sp)
    80003380:	6105                	addi	sp,sp,32
    80003382:	8082                	ret
    panic("brelse");
    80003384:	00005517          	auipc	a0,0x5
    80003388:	09450513          	addi	a0,a0,148 # 80008418 <etext+0x418>
    8000338c:	ffffd097          	auipc	ra,0xffffd
    80003390:	1d4080e7          	jalr	468(ra) # 80000560 <panic>

0000000080003394 <bpin>:

void
bpin(struct buf *b) {
    80003394:	1101                	addi	sp,sp,-32
    80003396:	ec06                	sd	ra,24(sp)
    80003398:	e822                	sd	s0,16(sp)
    8000339a:	e426                	sd	s1,8(sp)
    8000339c:	1000                	addi	s0,sp,32
    8000339e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033a0:	00019517          	auipc	a0,0x19
    800033a4:	46850513          	addi	a0,a0,1128 # 8001c808 <bcache>
    800033a8:	ffffe097          	auipc	ra,0xffffe
    800033ac:	890080e7          	jalr	-1904(ra) # 80000c38 <acquire>
  b->refcnt++;
    800033b0:	40bc                	lw	a5,64(s1)
    800033b2:	2785                	addiw	a5,a5,1
    800033b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033b6:	00019517          	auipc	a0,0x19
    800033ba:	45250513          	addi	a0,a0,1106 # 8001c808 <bcache>
    800033be:	ffffe097          	auipc	ra,0xffffe
    800033c2:	92e080e7          	jalr	-1746(ra) # 80000cec <release>
}
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6105                	addi	sp,sp,32
    800033ce:	8082                	ret

00000000800033d0 <bunpin>:

void
bunpin(struct buf *b) {
    800033d0:	1101                	addi	sp,sp,-32
    800033d2:	ec06                	sd	ra,24(sp)
    800033d4:	e822                	sd	s0,16(sp)
    800033d6:	e426                	sd	s1,8(sp)
    800033d8:	1000                	addi	s0,sp,32
    800033da:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033dc:	00019517          	auipc	a0,0x19
    800033e0:	42c50513          	addi	a0,a0,1068 # 8001c808 <bcache>
    800033e4:	ffffe097          	auipc	ra,0xffffe
    800033e8:	854080e7          	jalr	-1964(ra) # 80000c38 <acquire>
  b->refcnt--;
    800033ec:	40bc                	lw	a5,64(s1)
    800033ee:	37fd                	addiw	a5,a5,-1
    800033f0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033f2:	00019517          	auipc	a0,0x19
    800033f6:	41650513          	addi	a0,a0,1046 # 8001c808 <bcache>
    800033fa:	ffffe097          	auipc	ra,0xffffe
    800033fe:	8f2080e7          	jalr	-1806(ra) # 80000cec <release>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	addi	sp,sp,32
    8000340a:	8082                	ret

000000008000340c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000340c:	1101                	addi	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	e04a                	sd	s2,0(sp)
    80003416:	1000                	addi	s0,sp,32
    80003418:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000341a:	00d5d59b          	srliw	a1,a1,0xd
    8000341e:	00022797          	auipc	a5,0x22
    80003422:	ac67a783          	lw	a5,-1338(a5) # 80024ee4 <sb+0x1c>
    80003426:	9dbd                	addw	a1,a1,a5
    80003428:	00000097          	auipc	ra,0x0
    8000342c:	da0080e7          	jalr	-608(ra) # 800031c8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003430:	0074f713          	andi	a4,s1,7
    80003434:	4785                	li	a5,1
    80003436:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000343a:	14ce                	slli	s1,s1,0x33
    8000343c:	90d9                	srli	s1,s1,0x36
    8000343e:	00950733          	add	a4,a0,s1
    80003442:	05874703          	lbu	a4,88(a4)
    80003446:	00e7f6b3          	and	a3,a5,a4
    8000344a:	c69d                	beqz	a3,80003478 <bfree+0x6c>
    8000344c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000344e:	94aa                	add	s1,s1,a0
    80003450:	fff7c793          	not	a5,a5
    80003454:	8f7d                	and	a4,a4,a5
    80003456:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000345a:	00001097          	auipc	ra,0x1
    8000345e:	148080e7          	jalr	328(ra) # 800045a2 <log_write>
  brelse(bp);
    80003462:	854a                	mv	a0,s2
    80003464:	00000097          	auipc	ra,0x0
    80003468:	e94080e7          	jalr	-364(ra) # 800032f8 <brelse>
}
    8000346c:	60e2                	ld	ra,24(sp)
    8000346e:	6442                	ld	s0,16(sp)
    80003470:	64a2                	ld	s1,8(sp)
    80003472:	6902                	ld	s2,0(sp)
    80003474:	6105                	addi	sp,sp,32
    80003476:	8082                	ret
    panic("freeing free block");
    80003478:	00005517          	auipc	a0,0x5
    8000347c:	fa850513          	addi	a0,a0,-88 # 80008420 <etext+0x420>
    80003480:	ffffd097          	auipc	ra,0xffffd
    80003484:	0e0080e7          	jalr	224(ra) # 80000560 <panic>

0000000080003488 <balloc>:
{
    80003488:	711d                	addi	sp,sp,-96
    8000348a:	ec86                	sd	ra,88(sp)
    8000348c:	e8a2                	sd	s0,80(sp)
    8000348e:	e4a6                	sd	s1,72(sp)
    80003490:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003492:	00022797          	auipc	a5,0x22
    80003496:	a3a7a783          	lw	a5,-1478(a5) # 80024ecc <sb+0x4>
    8000349a:	10078f63          	beqz	a5,800035b8 <balloc+0x130>
    8000349e:	e0ca                	sd	s2,64(sp)
    800034a0:	fc4e                	sd	s3,56(sp)
    800034a2:	f852                	sd	s4,48(sp)
    800034a4:	f456                	sd	s5,40(sp)
    800034a6:	f05a                	sd	s6,32(sp)
    800034a8:	ec5e                	sd	s7,24(sp)
    800034aa:	e862                	sd	s8,16(sp)
    800034ac:	e466                	sd	s9,8(sp)
    800034ae:	8baa                	mv	s7,a0
    800034b0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034b2:	00022b17          	auipc	s6,0x22
    800034b6:	a16b0b13          	addi	s6,s6,-1514 # 80024ec8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ba:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034bc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034be:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034c0:	6c89                	lui	s9,0x2
    800034c2:	a061                	j	8000354a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034c4:	97ca                	add	a5,a5,s2
    800034c6:	8e55                	or	a2,a2,a3
    800034c8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800034cc:	854a                	mv	a0,s2
    800034ce:	00001097          	auipc	ra,0x1
    800034d2:	0d4080e7          	jalr	212(ra) # 800045a2 <log_write>
        brelse(bp);
    800034d6:	854a                	mv	a0,s2
    800034d8:	00000097          	auipc	ra,0x0
    800034dc:	e20080e7          	jalr	-480(ra) # 800032f8 <brelse>
  bp = bread(dev, bno);
    800034e0:	85a6                	mv	a1,s1
    800034e2:	855e                	mv	a0,s7
    800034e4:	00000097          	auipc	ra,0x0
    800034e8:	ce4080e7          	jalr	-796(ra) # 800031c8 <bread>
    800034ec:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034ee:	40000613          	li	a2,1024
    800034f2:	4581                	li	a1,0
    800034f4:	05850513          	addi	a0,a0,88
    800034f8:	ffffe097          	auipc	ra,0xffffe
    800034fc:	83c080e7          	jalr	-1988(ra) # 80000d34 <memset>
  log_write(bp);
    80003500:	854a                	mv	a0,s2
    80003502:	00001097          	auipc	ra,0x1
    80003506:	0a0080e7          	jalr	160(ra) # 800045a2 <log_write>
  brelse(bp);
    8000350a:	854a                	mv	a0,s2
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	dec080e7          	jalr	-532(ra) # 800032f8 <brelse>
}
    80003514:	6906                	ld	s2,64(sp)
    80003516:	79e2                	ld	s3,56(sp)
    80003518:	7a42                	ld	s4,48(sp)
    8000351a:	7aa2                	ld	s5,40(sp)
    8000351c:	7b02                	ld	s6,32(sp)
    8000351e:	6be2                	ld	s7,24(sp)
    80003520:	6c42                	ld	s8,16(sp)
    80003522:	6ca2                	ld	s9,8(sp)
}
    80003524:	8526                	mv	a0,s1
    80003526:	60e6                	ld	ra,88(sp)
    80003528:	6446                	ld	s0,80(sp)
    8000352a:	64a6                	ld	s1,72(sp)
    8000352c:	6125                	addi	sp,sp,96
    8000352e:	8082                	ret
    brelse(bp);
    80003530:	854a                	mv	a0,s2
    80003532:	00000097          	auipc	ra,0x0
    80003536:	dc6080e7          	jalr	-570(ra) # 800032f8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000353a:	015c87bb          	addw	a5,s9,s5
    8000353e:	00078a9b          	sext.w	s5,a5
    80003542:	004b2703          	lw	a4,4(s6)
    80003546:	06eaf163          	bgeu	s5,a4,800035a8 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    8000354a:	41fad79b          	sraiw	a5,s5,0x1f
    8000354e:	0137d79b          	srliw	a5,a5,0x13
    80003552:	015787bb          	addw	a5,a5,s5
    80003556:	40d7d79b          	sraiw	a5,a5,0xd
    8000355a:	01cb2583          	lw	a1,28(s6)
    8000355e:	9dbd                	addw	a1,a1,a5
    80003560:	855e                	mv	a0,s7
    80003562:	00000097          	auipc	ra,0x0
    80003566:	c66080e7          	jalr	-922(ra) # 800031c8 <bread>
    8000356a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000356c:	004b2503          	lw	a0,4(s6)
    80003570:	000a849b          	sext.w	s1,s5
    80003574:	8762                	mv	a4,s8
    80003576:	faa4fde3          	bgeu	s1,a0,80003530 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000357a:	00777693          	andi	a3,a4,7
    8000357e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003582:	41f7579b          	sraiw	a5,a4,0x1f
    80003586:	01d7d79b          	srliw	a5,a5,0x1d
    8000358a:	9fb9                	addw	a5,a5,a4
    8000358c:	4037d79b          	sraiw	a5,a5,0x3
    80003590:	00f90633          	add	a2,s2,a5
    80003594:	05864603          	lbu	a2,88(a2)
    80003598:	00c6f5b3          	and	a1,a3,a2
    8000359c:	d585                	beqz	a1,800034c4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000359e:	2705                	addiw	a4,a4,1
    800035a0:	2485                	addiw	s1,s1,1
    800035a2:	fd471ae3          	bne	a4,s4,80003576 <balloc+0xee>
    800035a6:	b769                	j	80003530 <balloc+0xa8>
    800035a8:	6906                	ld	s2,64(sp)
    800035aa:	79e2                	ld	s3,56(sp)
    800035ac:	7a42                	ld	s4,48(sp)
    800035ae:	7aa2                	ld	s5,40(sp)
    800035b0:	7b02                	ld	s6,32(sp)
    800035b2:	6be2                	ld	s7,24(sp)
    800035b4:	6c42                	ld	s8,16(sp)
    800035b6:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800035b8:	00005517          	auipc	a0,0x5
    800035bc:	e8050513          	addi	a0,a0,-384 # 80008438 <etext+0x438>
    800035c0:	ffffd097          	auipc	ra,0xffffd
    800035c4:	fea080e7          	jalr	-22(ra) # 800005aa <printf>
  return 0;
    800035c8:	4481                	li	s1,0
    800035ca:	bfa9                	j	80003524 <balloc+0x9c>

00000000800035cc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035cc:	7179                	addi	sp,sp,-48
    800035ce:	f406                	sd	ra,40(sp)
    800035d0:	f022                	sd	s0,32(sp)
    800035d2:	ec26                	sd	s1,24(sp)
    800035d4:	e84a                	sd	s2,16(sp)
    800035d6:	e44e                	sd	s3,8(sp)
    800035d8:	1800                	addi	s0,sp,48
    800035da:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035dc:	47ad                	li	a5,11
    800035de:	02b7e863          	bltu	a5,a1,8000360e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800035e2:	02059793          	slli	a5,a1,0x20
    800035e6:	01e7d593          	srli	a1,a5,0x1e
    800035ea:	00b504b3          	add	s1,a0,a1
    800035ee:	0504a903          	lw	s2,80(s1)
    800035f2:	08091263          	bnez	s2,80003676 <bmap+0xaa>
      addr = balloc(ip->dev);
    800035f6:	4108                	lw	a0,0(a0)
    800035f8:	00000097          	auipc	ra,0x0
    800035fc:	e90080e7          	jalr	-368(ra) # 80003488 <balloc>
    80003600:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003604:	06090963          	beqz	s2,80003676 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003608:	0524a823          	sw	s2,80(s1)
    8000360c:	a0ad                	j	80003676 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000360e:	ff45849b          	addiw	s1,a1,-12
    80003612:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003616:	0ff00793          	li	a5,255
    8000361a:	08e7e863          	bltu	a5,a4,800036aa <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000361e:	08052903          	lw	s2,128(a0)
    80003622:	00091f63          	bnez	s2,80003640 <bmap+0x74>
      addr = balloc(ip->dev);
    80003626:	4108                	lw	a0,0(a0)
    80003628:	00000097          	auipc	ra,0x0
    8000362c:	e60080e7          	jalr	-416(ra) # 80003488 <balloc>
    80003630:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003634:	04090163          	beqz	s2,80003676 <bmap+0xaa>
    80003638:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000363a:	0929a023          	sw	s2,128(s3)
    8000363e:	a011                	j	80003642 <bmap+0x76>
    80003640:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003642:	85ca                	mv	a1,s2
    80003644:	0009a503          	lw	a0,0(s3)
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	b80080e7          	jalr	-1152(ra) # 800031c8 <bread>
    80003650:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003652:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003656:	02049713          	slli	a4,s1,0x20
    8000365a:	01e75593          	srli	a1,a4,0x1e
    8000365e:	00b784b3          	add	s1,a5,a1
    80003662:	0004a903          	lw	s2,0(s1)
    80003666:	02090063          	beqz	s2,80003686 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000366a:	8552                	mv	a0,s4
    8000366c:	00000097          	auipc	ra,0x0
    80003670:	c8c080e7          	jalr	-884(ra) # 800032f8 <brelse>
    return addr;
    80003674:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003676:	854a                	mv	a0,s2
    80003678:	70a2                	ld	ra,40(sp)
    8000367a:	7402                	ld	s0,32(sp)
    8000367c:	64e2                	ld	s1,24(sp)
    8000367e:	6942                	ld	s2,16(sp)
    80003680:	69a2                	ld	s3,8(sp)
    80003682:	6145                	addi	sp,sp,48
    80003684:	8082                	ret
      addr = balloc(ip->dev);
    80003686:	0009a503          	lw	a0,0(s3)
    8000368a:	00000097          	auipc	ra,0x0
    8000368e:	dfe080e7          	jalr	-514(ra) # 80003488 <balloc>
    80003692:	0005091b          	sext.w	s2,a0
      if(addr){
    80003696:	fc090ae3          	beqz	s2,8000366a <bmap+0x9e>
        a[bn] = addr;
    8000369a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000369e:	8552                	mv	a0,s4
    800036a0:	00001097          	auipc	ra,0x1
    800036a4:	f02080e7          	jalr	-254(ra) # 800045a2 <log_write>
    800036a8:	b7c9                	j	8000366a <bmap+0x9e>
    800036aa:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800036ac:	00005517          	auipc	a0,0x5
    800036b0:	da450513          	addi	a0,a0,-604 # 80008450 <etext+0x450>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	eac080e7          	jalr	-340(ra) # 80000560 <panic>

00000000800036bc <iget>:
{
    800036bc:	7179                	addi	sp,sp,-48
    800036be:	f406                	sd	ra,40(sp)
    800036c0:	f022                	sd	s0,32(sp)
    800036c2:	ec26                	sd	s1,24(sp)
    800036c4:	e84a                	sd	s2,16(sp)
    800036c6:	e44e                	sd	s3,8(sp)
    800036c8:	e052                	sd	s4,0(sp)
    800036ca:	1800                	addi	s0,sp,48
    800036cc:	89aa                	mv	s3,a0
    800036ce:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036d0:	00022517          	auipc	a0,0x22
    800036d4:	81850513          	addi	a0,a0,-2024 # 80024ee8 <itable>
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	560080e7          	jalr	1376(ra) # 80000c38 <acquire>
  empty = 0;
    800036e0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036e2:	00022497          	auipc	s1,0x22
    800036e6:	81e48493          	addi	s1,s1,-2018 # 80024f00 <itable+0x18>
    800036ea:	00023697          	auipc	a3,0x23
    800036ee:	2a668693          	addi	a3,a3,678 # 80026990 <log>
    800036f2:	a039                	j	80003700 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036f4:	02090b63          	beqz	s2,8000372a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036f8:	08848493          	addi	s1,s1,136
    800036fc:	02d48a63          	beq	s1,a3,80003730 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003700:	449c                	lw	a5,8(s1)
    80003702:	fef059e3          	blez	a5,800036f4 <iget+0x38>
    80003706:	4098                	lw	a4,0(s1)
    80003708:	ff3716e3          	bne	a4,s3,800036f4 <iget+0x38>
    8000370c:	40d8                	lw	a4,4(s1)
    8000370e:	ff4713e3          	bne	a4,s4,800036f4 <iget+0x38>
      ip->ref++;
    80003712:	2785                	addiw	a5,a5,1
    80003714:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003716:	00021517          	auipc	a0,0x21
    8000371a:	7d250513          	addi	a0,a0,2002 # 80024ee8 <itable>
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	5ce080e7          	jalr	1486(ra) # 80000cec <release>
      return ip;
    80003726:	8926                	mv	s2,s1
    80003728:	a03d                	j	80003756 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000372a:	f7f9                	bnez	a5,800036f8 <iget+0x3c>
      empty = ip;
    8000372c:	8926                	mv	s2,s1
    8000372e:	b7e9                	j	800036f8 <iget+0x3c>
  if(empty == 0)
    80003730:	02090c63          	beqz	s2,80003768 <iget+0xac>
  ip->dev = dev;
    80003734:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003738:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000373c:	4785                	li	a5,1
    8000373e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003742:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003746:	00021517          	auipc	a0,0x21
    8000374a:	7a250513          	addi	a0,a0,1954 # 80024ee8 <itable>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	59e080e7          	jalr	1438(ra) # 80000cec <release>
}
    80003756:	854a                	mv	a0,s2
    80003758:	70a2                	ld	ra,40(sp)
    8000375a:	7402                	ld	s0,32(sp)
    8000375c:	64e2                	ld	s1,24(sp)
    8000375e:	6942                	ld	s2,16(sp)
    80003760:	69a2                	ld	s3,8(sp)
    80003762:	6a02                	ld	s4,0(sp)
    80003764:	6145                	addi	sp,sp,48
    80003766:	8082                	ret
    panic("iget: no inodes");
    80003768:	00005517          	auipc	a0,0x5
    8000376c:	d0050513          	addi	a0,a0,-768 # 80008468 <etext+0x468>
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	df0080e7          	jalr	-528(ra) # 80000560 <panic>

0000000080003778 <fsinit>:
fsinit(int dev) {
    80003778:	7179                	addi	sp,sp,-48
    8000377a:	f406                	sd	ra,40(sp)
    8000377c:	f022                	sd	s0,32(sp)
    8000377e:	ec26                	sd	s1,24(sp)
    80003780:	e84a                	sd	s2,16(sp)
    80003782:	e44e                	sd	s3,8(sp)
    80003784:	1800                	addi	s0,sp,48
    80003786:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003788:	4585                	li	a1,1
    8000378a:	00000097          	auipc	ra,0x0
    8000378e:	a3e080e7          	jalr	-1474(ra) # 800031c8 <bread>
    80003792:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003794:	00021997          	auipc	s3,0x21
    80003798:	73498993          	addi	s3,s3,1844 # 80024ec8 <sb>
    8000379c:	02000613          	li	a2,32
    800037a0:	05850593          	addi	a1,a0,88
    800037a4:	854e                	mv	a0,s3
    800037a6:	ffffd097          	auipc	ra,0xffffd
    800037aa:	5ea080e7          	jalr	1514(ra) # 80000d90 <memmove>
  brelse(bp);
    800037ae:	8526                	mv	a0,s1
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	b48080e7          	jalr	-1208(ra) # 800032f8 <brelse>
  if(sb.magic != FSMAGIC)
    800037b8:	0009a703          	lw	a4,0(s3)
    800037bc:	102037b7          	lui	a5,0x10203
    800037c0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037c4:	02f71263          	bne	a4,a5,800037e8 <fsinit+0x70>
  initlog(dev, &sb);
    800037c8:	00021597          	auipc	a1,0x21
    800037cc:	70058593          	addi	a1,a1,1792 # 80024ec8 <sb>
    800037d0:	854a                	mv	a0,s2
    800037d2:	00001097          	auipc	ra,0x1
    800037d6:	b60080e7          	jalr	-1184(ra) # 80004332 <initlog>
}
    800037da:	70a2                	ld	ra,40(sp)
    800037dc:	7402                	ld	s0,32(sp)
    800037de:	64e2                	ld	s1,24(sp)
    800037e0:	6942                	ld	s2,16(sp)
    800037e2:	69a2                	ld	s3,8(sp)
    800037e4:	6145                	addi	sp,sp,48
    800037e6:	8082                	ret
    panic("invalid file system");
    800037e8:	00005517          	auipc	a0,0x5
    800037ec:	c9050513          	addi	a0,a0,-880 # 80008478 <etext+0x478>
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	d70080e7          	jalr	-656(ra) # 80000560 <panic>

00000000800037f8 <iinit>:
{
    800037f8:	7179                	addi	sp,sp,-48
    800037fa:	f406                	sd	ra,40(sp)
    800037fc:	f022                	sd	s0,32(sp)
    800037fe:	ec26                	sd	s1,24(sp)
    80003800:	e84a                	sd	s2,16(sp)
    80003802:	e44e                	sd	s3,8(sp)
    80003804:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003806:	00005597          	auipc	a1,0x5
    8000380a:	c8a58593          	addi	a1,a1,-886 # 80008490 <etext+0x490>
    8000380e:	00021517          	auipc	a0,0x21
    80003812:	6da50513          	addi	a0,a0,1754 # 80024ee8 <itable>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	392080e7          	jalr	914(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000381e:	00021497          	auipc	s1,0x21
    80003822:	6f248493          	addi	s1,s1,1778 # 80024f10 <itable+0x28>
    80003826:	00023997          	auipc	s3,0x23
    8000382a:	17a98993          	addi	s3,s3,378 # 800269a0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000382e:	00005917          	auipc	s2,0x5
    80003832:	c6a90913          	addi	s2,s2,-918 # 80008498 <etext+0x498>
    80003836:	85ca                	mv	a1,s2
    80003838:	8526                	mv	a0,s1
    8000383a:	00001097          	auipc	ra,0x1
    8000383e:	e4c080e7          	jalr	-436(ra) # 80004686 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003842:	08848493          	addi	s1,s1,136
    80003846:	ff3498e3          	bne	s1,s3,80003836 <iinit+0x3e>
}
    8000384a:	70a2                	ld	ra,40(sp)
    8000384c:	7402                	ld	s0,32(sp)
    8000384e:	64e2                	ld	s1,24(sp)
    80003850:	6942                	ld	s2,16(sp)
    80003852:	69a2                	ld	s3,8(sp)
    80003854:	6145                	addi	sp,sp,48
    80003856:	8082                	ret

0000000080003858 <ialloc>:
{
    80003858:	7139                	addi	sp,sp,-64
    8000385a:	fc06                	sd	ra,56(sp)
    8000385c:	f822                	sd	s0,48(sp)
    8000385e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003860:	00021717          	auipc	a4,0x21
    80003864:	67472703          	lw	a4,1652(a4) # 80024ed4 <sb+0xc>
    80003868:	4785                	li	a5,1
    8000386a:	06e7f463          	bgeu	a5,a4,800038d2 <ialloc+0x7a>
    8000386e:	f426                	sd	s1,40(sp)
    80003870:	f04a                	sd	s2,32(sp)
    80003872:	ec4e                	sd	s3,24(sp)
    80003874:	e852                	sd	s4,16(sp)
    80003876:	e456                	sd	s5,8(sp)
    80003878:	e05a                	sd	s6,0(sp)
    8000387a:	8aaa                	mv	s5,a0
    8000387c:	8b2e                	mv	s6,a1
    8000387e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003880:	00021a17          	auipc	s4,0x21
    80003884:	648a0a13          	addi	s4,s4,1608 # 80024ec8 <sb>
    80003888:	00495593          	srli	a1,s2,0x4
    8000388c:	018a2783          	lw	a5,24(s4)
    80003890:	9dbd                	addw	a1,a1,a5
    80003892:	8556                	mv	a0,s5
    80003894:	00000097          	auipc	ra,0x0
    80003898:	934080e7          	jalr	-1740(ra) # 800031c8 <bread>
    8000389c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000389e:	05850993          	addi	s3,a0,88
    800038a2:	00f97793          	andi	a5,s2,15
    800038a6:	079a                	slli	a5,a5,0x6
    800038a8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038aa:	00099783          	lh	a5,0(s3)
    800038ae:	cf9d                	beqz	a5,800038ec <ialloc+0x94>
    brelse(bp);
    800038b0:	00000097          	auipc	ra,0x0
    800038b4:	a48080e7          	jalr	-1464(ra) # 800032f8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038b8:	0905                	addi	s2,s2,1
    800038ba:	00ca2703          	lw	a4,12(s4)
    800038be:	0009079b          	sext.w	a5,s2
    800038c2:	fce7e3e3          	bltu	a5,a4,80003888 <ialloc+0x30>
    800038c6:	74a2                	ld	s1,40(sp)
    800038c8:	7902                	ld	s2,32(sp)
    800038ca:	69e2                	ld	s3,24(sp)
    800038cc:	6a42                	ld	s4,16(sp)
    800038ce:	6aa2                	ld	s5,8(sp)
    800038d0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800038d2:	00005517          	auipc	a0,0x5
    800038d6:	bce50513          	addi	a0,a0,-1074 # 800084a0 <etext+0x4a0>
    800038da:	ffffd097          	auipc	ra,0xffffd
    800038de:	cd0080e7          	jalr	-816(ra) # 800005aa <printf>
  return 0;
    800038e2:	4501                	li	a0,0
}
    800038e4:	70e2                	ld	ra,56(sp)
    800038e6:	7442                	ld	s0,48(sp)
    800038e8:	6121                	addi	sp,sp,64
    800038ea:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038ec:	04000613          	li	a2,64
    800038f0:	4581                	li	a1,0
    800038f2:	854e                	mv	a0,s3
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	440080e7          	jalr	1088(ra) # 80000d34 <memset>
      dip->type = type;
    800038fc:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003900:	8526                	mv	a0,s1
    80003902:	00001097          	auipc	ra,0x1
    80003906:	ca0080e7          	jalr	-864(ra) # 800045a2 <log_write>
      brelse(bp);
    8000390a:	8526                	mv	a0,s1
    8000390c:	00000097          	auipc	ra,0x0
    80003910:	9ec080e7          	jalr	-1556(ra) # 800032f8 <brelse>
      return iget(dev, inum);
    80003914:	0009059b          	sext.w	a1,s2
    80003918:	8556                	mv	a0,s5
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	da2080e7          	jalr	-606(ra) # 800036bc <iget>
    80003922:	74a2                	ld	s1,40(sp)
    80003924:	7902                	ld	s2,32(sp)
    80003926:	69e2                	ld	s3,24(sp)
    80003928:	6a42                	ld	s4,16(sp)
    8000392a:	6aa2                	ld	s5,8(sp)
    8000392c:	6b02                	ld	s6,0(sp)
    8000392e:	bf5d                	j	800038e4 <ialloc+0x8c>

0000000080003930 <iupdate>:
{
    80003930:	1101                	addi	sp,sp,-32
    80003932:	ec06                	sd	ra,24(sp)
    80003934:	e822                	sd	s0,16(sp)
    80003936:	e426                	sd	s1,8(sp)
    80003938:	e04a                	sd	s2,0(sp)
    8000393a:	1000                	addi	s0,sp,32
    8000393c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000393e:	415c                	lw	a5,4(a0)
    80003940:	0047d79b          	srliw	a5,a5,0x4
    80003944:	00021597          	auipc	a1,0x21
    80003948:	59c5a583          	lw	a1,1436(a1) # 80024ee0 <sb+0x18>
    8000394c:	9dbd                	addw	a1,a1,a5
    8000394e:	4108                	lw	a0,0(a0)
    80003950:	00000097          	auipc	ra,0x0
    80003954:	878080e7          	jalr	-1928(ra) # 800031c8 <bread>
    80003958:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000395a:	05850793          	addi	a5,a0,88
    8000395e:	40d8                	lw	a4,4(s1)
    80003960:	8b3d                	andi	a4,a4,15
    80003962:	071a                	slli	a4,a4,0x6
    80003964:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003966:	04449703          	lh	a4,68(s1)
    8000396a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000396e:	04649703          	lh	a4,70(s1)
    80003972:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003976:	04849703          	lh	a4,72(s1)
    8000397a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000397e:	04a49703          	lh	a4,74(s1)
    80003982:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003986:	44f8                	lw	a4,76(s1)
    80003988:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000398a:	03400613          	li	a2,52
    8000398e:	05048593          	addi	a1,s1,80
    80003992:	00c78513          	addi	a0,a5,12
    80003996:	ffffd097          	auipc	ra,0xffffd
    8000399a:	3fa080e7          	jalr	1018(ra) # 80000d90 <memmove>
  log_write(bp);
    8000399e:	854a                	mv	a0,s2
    800039a0:	00001097          	auipc	ra,0x1
    800039a4:	c02080e7          	jalr	-1022(ra) # 800045a2 <log_write>
  brelse(bp);
    800039a8:	854a                	mv	a0,s2
    800039aa:	00000097          	auipc	ra,0x0
    800039ae:	94e080e7          	jalr	-1714(ra) # 800032f8 <brelse>
}
    800039b2:	60e2                	ld	ra,24(sp)
    800039b4:	6442                	ld	s0,16(sp)
    800039b6:	64a2                	ld	s1,8(sp)
    800039b8:	6902                	ld	s2,0(sp)
    800039ba:	6105                	addi	sp,sp,32
    800039bc:	8082                	ret

00000000800039be <idup>:
{
    800039be:	1101                	addi	sp,sp,-32
    800039c0:	ec06                	sd	ra,24(sp)
    800039c2:	e822                	sd	s0,16(sp)
    800039c4:	e426                	sd	s1,8(sp)
    800039c6:	1000                	addi	s0,sp,32
    800039c8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039ca:	00021517          	auipc	a0,0x21
    800039ce:	51e50513          	addi	a0,a0,1310 # 80024ee8 <itable>
    800039d2:	ffffd097          	auipc	ra,0xffffd
    800039d6:	266080e7          	jalr	614(ra) # 80000c38 <acquire>
  ip->ref++;
    800039da:	449c                	lw	a5,8(s1)
    800039dc:	2785                	addiw	a5,a5,1
    800039de:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039e0:	00021517          	auipc	a0,0x21
    800039e4:	50850513          	addi	a0,a0,1288 # 80024ee8 <itable>
    800039e8:	ffffd097          	auipc	ra,0xffffd
    800039ec:	304080e7          	jalr	772(ra) # 80000cec <release>
}
    800039f0:	8526                	mv	a0,s1
    800039f2:	60e2                	ld	ra,24(sp)
    800039f4:	6442                	ld	s0,16(sp)
    800039f6:	64a2                	ld	s1,8(sp)
    800039f8:	6105                	addi	sp,sp,32
    800039fa:	8082                	ret

00000000800039fc <ilock>:
{
    800039fc:	1101                	addi	sp,sp,-32
    800039fe:	ec06                	sd	ra,24(sp)
    80003a00:	e822                	sd	s0,16(sp)
    80003a02:	e426                	sd	s1,8(sp)
    80003a04:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a06:	c10d                	beqz	a0,80003a28 <ilock+0x2c>
    80003a08:	84aa                	mv	s1,a0
    80003a0a:	451c                	lw	a5,8(a0)
    80003a0c:	00f05e63          	blez	a5,80003a28 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003a10:	0541                	addi	a0,a0,16
    80003a12:	00001097          	auipc	ra,0x1
    80003a16:	cae080e7          	jalr	-850(ra) # 800046c0 <acquiresleep>
  if(ip->valid == 0){
    80003a1a:	40bc                	lw	a5,64(s1)
    80003a1c:	cf99                	beqz	a5,80003a3a <ilock+0x3e>
}
    80003a1e:	60e2                	ld	ra,24(sp)
    80003a20:	6442                	ld	s0,16(sp)
    80003a22:	64a2                	ld	s1,8(sp)
    80003a24:	6105                	addi	sp,sp,32
    80003a26:	8082                	ret
    80003a28:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003a2a:	00005517          	auipc	a0,0x5
    80003a2e:	a8e50513          	addi	a0,a0,-1394 # 800084b8 <etext+0x4b8>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	b2e080e7          	jalr	-1234(ra) # 80000560 <panic>
    80003a3a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a3c:	40dc                	lw	a5,4(s1)
    80003a3e:	0047d79b          	srliw	a5,a5,0x4
    80003a42:	00021597          	auipc	a1,0x21
    80003a46:	49e5a583          	lw	a1,1182(a1) # 80024ee0 <sb+0x18>
    80003a4a:	9dbd                	addw	a1,a1,a5
    80003a4c:	4088                	lw	a0,0(s1)
    80003a4e:	fffff097          	auipc	ra,0xfffff
    80003a52:	77a080e7          	jalr	1914(ra) # 800031c8 <bread>
    80003a56:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a58:	05850593          	addi	a1,a0,88
    80003a5c:	40dc                	lw	a5,4(s1)
    80003a5e:	8bbd                	andi	a5,a5,15
    80003a60:	079a                	slli	a5,a5,0x6
    80003a62:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a64:	00059783          	lh	a5,0(a1)
    80003a68:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a6c:	00259783          	lh	a5,2(a1)
    80003a70:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a74:	00459783          	lh	a5,4(a1)
    80003a78:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a7c:	00659783          	lh	a5,6(a1)
    80003a80:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a84:	459c                	lw	a5,8(a1)
    80003a86:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a88:	03400613          	li	a2,52
    80003a8c:	05b1                	addi	a1,a1,12
    80003a8e:	05048513          	addi	a0,s1,80
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	2fe080e7          	jalr	766(ra) # 80000d90 <memmove>
    brelse(bp);
    80003a9a:	854a                	mv	a0,s2
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	85c080e7          	jalr	-1956(ra) # 800032f8 <brelse>
    ip->valid = 1;
    80003aa4:	4785                	li	a5,1
    80003aa6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003aa8:	04449783          	lh	a5,68(s1)
    80003aac:	c399                	beqz	a5,80003ab2 <ilock+0xb6>
    80003aae:	6902                	ld	s2,0(sp)
    80003ab0:	b7bd                	j	80003a1e <ilock+0x22>
      panic("ilock: no type");
    80003ab2:	00005517          	auipc	a0,0x5
    80003ab6:	a0e50513          	addi	a0,a0,-1522 # 800084c0 <etext+0x4c0>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	aa6080e7          	jalr	-1370(ra) # 80000560 <panic>

0000000080003ac2 <iunlock>:
{
    80003ac2:	1101                	addi	sp,sp,-32
    80003ac4:	ec06                	sd	ra,24(sp)
    80003ac6:	e822                	sd	s0,16(sp)
    80003ac8:	e426                	sd	s1,8(sp)
    80003aca:	e04a                	sd	s2,0(sp)
    80003acc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ace:	c905                	beqz	a0,80003afe <iunlock+0x3c>
    80003ad0:	84aa                	mv	s1,a0
    80003ad2:	01050913          	addi	s2,a0,16
    80003ad6:	854a                	mv	a0,s2
    80003ad8:	00001097          	auipc	ra,0x1
    80003adc:	c82080e7          	jalr	-894(ra) # 8000475a <holdingsleep>
    80003ae0:	cd19                	beqz	a0,80003afe <iunlock+0x3c>
    80003ae2:	449c                	lw	a5,8(s1)
    80003ae4:	00f05d63          	blez	a5,80003afe <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ae8:	854a                	mv	a0,s2
    80003aea:	00001097          	auipc	ra,0x1
    80003aee:	c2c080e7          	jalr	-980(ra) # 80004716 <releasesleep>
}
    80003af2:	60e2                	ld	ra,24(sp)
    80003af4:	6442                	ld	s0,16(sp)
    80003af6:	64a2                	ld	s1,8(sp)
    80003af8:	6902                	ld	s2,0(sp)
    80003afa:	6105                	addi	sp,sp,32
    80003afc:	8082                	ret
    panic("iunlock");
    80003afe:	00005517          	auipc	a0,0x5
    80003b02:	9d250513          	addi	a0,a0,-1582 # 800084d0 <etext+0x4d0>
    80003b06:	ffffd097          	auipc	ra,0xffffd
    80003b0a:	a5a080e7          	jalr	-1446(ra) # 80000560 <panic>

0000000080003b0e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b0e:	7179                	addi	sp,sp,-48
    80003b10:	f406                	sd	ra,40(sp)
    80003b12:	f022                	sd	s0,32(sp)
    80003b14:	ec26                	sd	s1,24(sp)
    80003b16:	e84a                	sd	s2,16(sp)
    80003b18:	e44e                	sd	s3,8(sp)
    80003b1a:	1800                	addi	s0,sp,48
    80003b1c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b1e:	05050493          	addi	s1,a0,80
    80003b22:	08050913          	addi	s2,a0,128
    80003b26:	a021                	j	80003b2e <itrunc+0x20>
    80003b28:	0491                	addi	s1,s1,4
    80003b2a:	01248d63          	beq	s1,s2,80003b44 <itrunc+0x36>
    if(ip->addrs[i]){
    80003b2e:	408c                	lw	a1,0(s1)
    80003b30:	dde5                	beqz	a1,80003b28 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003b32:	0009a503          	lw	a0,0(s3)
    80003b36:	00000097          	auipc	ra,0x0
    80003b3a:	8d6080e7          	jalr	-1834(ra) # 8000340c <bfree>
      ip->addrs[i] = 0;
    80003b3e:	0004a023          	sw	zero,0(s1)
    80003b42:	b7dd                	j	80003b28 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b44:	0809a583          	lw	a1,128(s3)
    80003b48:	ed99                	bnez	a1,80003b66 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b4a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b4e:	854e                	mv	a0,s3
    80003b50:	00000097          	auipc	ra,0x0
    80003b54:	de0080e7          	jalr	-544(ra) # 80003930 <iupdate>
}
    80003b58:	70a2                	ld	ra,40(sp)
    80003b5a:	7402                	ld	s0,32(sp)
    80003b5c:	64e2                	ld	s1,24(sp)
    80003b5e:	6942                	ld	s2,16(sp)
    80003b60:	69a2                	ld	s3,8(sp)
    80003b62:	6145                	addi	sp,sp,48
    80003b64:	8082                	ret
    80003b66:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b68:	0009a503          	lw	a0,0(s3)
    80003b6c:	fffff097          	auipc	ra,0xfffff
    80003b70:	65c080e7          	jalr	1628(ra) # 800031c8 <bread>
    80003b74:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b76:	05850493          	addi	s1,a0,88
    80003b7a:	45850913          	addi	s2,a0,1112
    80003b7e:	a021                	j	80003b86 <itrunc+0x78>
    80003b80:	0491                	addi	s1,s1,4
    80003b82:	01248b63          	beq	s1,s2,80003b98 <itrunc+0x8a>
      if(a[j])
    80003b86:	408c                	lw	a1,0(s1)
    80003b88:	dde5                	beqz	a1,80003b80 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003b8a:	0009a503          	lw	a0,0(s3)
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	87e080e7          	jalr	-1922(ra) # 8000340c <bfree>
    80003b96:	b7ed                	j	80003b80 <itrunc+0x72>
    brelse(bp);
    80003b98:	8552                	mv	a0,s4
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	75e080e7          	jalr	1886(ra) # 800032f8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ba2:	0809a583          	lw	a1,128(s3)
    80003ba6:	0009a503          	lw	a0,0(s3)
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	862080e7          	jalr	-1950(ra) # 8000340c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bb2:	0809a023          	sw	zero,128(s3)
    80003bb6:	6a02                	ld	s4,0(sp)
    80003bb8:	bf49                	j	80003b4a <itrunc+0x3c>

0000000080003bba <iput>:
{
    80003bba:	1101                	addi	sp,sp,-32
    80003bbc:	ec06                	sd	ra,24(sp)
    80003bbe:	e822                	sd	s0,16(sp)
    80003bc0:	e426                	sd	s1,8(sp)
    80003bc2:	1000                	addi	s0,sp,32
    80003bc4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bc6:	00021517          	auipc	a0,0x21
    80003bca:	32250513          	addi	a0,a0,802 # 80024ee8 <itable>
    80003bce:	ffffd097          	auipc	ra,0xffffd
    80003bd2:	06a080e7          	jalr	106(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bd6:	4498                	lw	a4,8(s1)
    80003bd8:	4785                	li	a5,1
    80003bda:	02f70263          	beq	a4,a5,80003bfe <iput+0x44>
  ip->ref--;
    80003bde:	449c                	lw	a5,8(s1)
    80003be0:	37fd                	addiw	a5,a5,-1
    80003be2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003be4:	00021517          	auipc	a0,0x21
    80003be8:	30450513          	addi	a0,a0,772 # 80024ee8 <itable>
    80003bec:	ffffd097          	auipc	ra,0xffffd
    80003bf0:	100080e7          	jalr	256(ra) # 80000cec <release>
}
    80003bf4:	60e2                	ld	ra,24(sp)
    80003bf6:	6442                	ld	s0,16(sp)
    80003bf8:	64a2                	ld	s1,8(sp)
    80003bfa:	6105                	addi	sp,sp,32
    80003bfc:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bfe:	40bc                	lw	a5,64(s1)
    80003c00:	dff9                	beqz	a5,80003bde <iput+0x24>
    80003c02:	04a49783          	lh	a5,74(s1)
    80003c06:	ffe1                	bnez	a5,80003bde <iput+0x24>
    80003c08:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003c0a:	01048913          	addi	s2,s1,16
    80003c0e:	854a                	mv	a0,s2
    80003c10:	00001097          	auipc	ra,0x1
    80003c14:	ab0080e7          	jalr	-1360(ra) # 800046c0 <acquiresleep>
    release(&itable.lock);
    80003c18:	00021517          	auipc	a0,0x21
    80003c1c:	2d050513          	addi	a0,a0,720 # 80024ee8 <itable>
    80003c20:	ffffd097          	auipc	ra,0xffffd
    80003c24:	0cc080e7          	jalr	204(ra) # 80000cec <release>
    itrunc(ip);
    80003c28:	8526                	mv	a0,s1
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	ee4080e7          	jalr	-284(ra) # 80003b0e <itrunc>
    ip->type = 0;
    80003c32:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c36:	8526                	mv	a0,s1
    80003c38:	00000097          	auipc	ra,0x0
    80003c3c:	cf8080e7          	jalr	-776(ra) # 80003930 <iupdate>
    ip->valid = 0;
    80003c40:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c44:	854a                	mv	a0,s2
    80003c46:	00001097          	auipc	ra,0x1
    80003c4a:	ad0080e7          	jalr	-1328(ra) # 80004716 <releasesleep>
    acquire(&itable.lock);
    80003c4e:	00021517          	auipc	a0,0x21
    80003c52:	29a50513          	addi	a0,a0,666 # 80024ee8 <itable>
    80003c56:	ffffd097          	auipc	ra,0xffffd
    80003c5a:	fe2080e7          	jalr	-30(ra) # 80000c38 <acquire>
    80003c5e:	6902                	ld	s2,0(sp)
    80003c60:	bfbd                	j	80003bde <iput+0x24>

0000000080003c62 <iunlockput>:
{
    80003c62:	1101                	addi	sp,sp,-32
    80003c64:	ec06                	sd	ra,24(sp)
    80003c66:	e822                	sd	s0,16(sp)
    80003c68:	e426                	sd	s1,8(sp)
    80003c6a:	1000                	addi	s0,sp,32
    80003c6c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c6e:	00000097          	auipc	ra,0x0
    80003c72:	e54080e7          	jalr	-428(ra) # 80003ac2 <iunlock>
  iput(ip);
    80003c76:	8526                	mv	a0,s1
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	f42080e7          	jalr	-190(ra) # 80003bba <iput>
}
    80003c80:	60e2                	ld	ra,24(sp)
    80003c82:	6442                	ld	s0,16(sp)
    80003c84:	64a2                	ld	s1,8(sp)
    80003c86:	6105                	addi	sp,sp,32
    80003c88:	8082                	ret

0000000080003c8a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c8a:	1141                	addi	sp,sp,-16
    80003c8c:	e422                	sd	s0,8(sp)
    80003c8e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c90:	411c                	lw	a5,0(a0)
    80003c92:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c94:	415c                	lw	a5,4(a0)
    80003c96:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c98:	04451783          	lh	a5,68(a0)
    80003c9c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ca0:	04a51783          	lh	a5,74(a0)
    80003ca4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ca8:	04c56783          	lwu	a5,76(a0)
    80003cac:	e99c                	sd	a5,16(a1)
}
    80003cae:	6422                	ld	s0,8(sp)
    80003cb0:	0141                	addi	sp,sp,16
    80003cb2:	8082                	ret

0000000080003cb4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cb4:	457c                	lw	a5,76(a0)
    80003cb6:	10d7e563          	bltu	a5,a3,80003dc0 <readi+0x10c>
{
    80003cba:	7159                	addi	sp,sp,-112
    80003cbc:	f486                	sd	ra,104(sp)
    80003cbe:	f0a2                	sd	s0,96(sp)
    80003cc0:	eca6                	sd	s1,88(sp)
    80003cc2:	e0d2                	sd	s4,64(sp)
    80003cc4:	fc56                	sd	s5,56(sp)
    80003cc6:	f85a                	sd	s6,48(sp)
    80003cc8:	f45e                	sd	s7,40(sp)
    80003cca:	1880                	addi	s0,sp,112
    80003ccc:	8b2a                	mv	s6,a0
    80003cce:	8bae                	mv	s7,a1
    80003cd0:	8a32                	mv	s4,a2
    80003cd2:	84b6                	mv	s1,a3
    80003cd4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003cd6:	9f35                	addw	a4,a4,a3
    return 0;
    80003cd8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cda:	0cd76a63          	bltu	a4,a3,80003dae <readi+0xfa>
    80003cde:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003ce0:	00e7f463          	bgeu	a5,a4,80003ce8 <readi+0x34>
    n = ip->size - off;
    80003ce4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce8:	0a0a8963          	beqz	s5,80003d9a <readi+0xe6>
    80003cec:	e8ca                	sd	s2,80(sp)
    80003cee:	f062                	sd	s8,32(sp)
    80003cf0:	ec66                	sd	s9,24(sp)
    80003cf2:	e86a                	sd	s10,16(sp)
    80003cf4:	e46e                	sd	s11,8(sp)
    80003cf6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cf8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cfc:	5c7d                	li	s8,-1
    80003cfe:	a82d                	j	80003d38 <readi+0x84>
    80003d00:	020d1d93          	slli	s11,s10,0x20
    80003d04:	020ddd93          	srli	s11,s11,0x20
    80003d08:	05890613          	addi	a2,s2,88
    80003d0c:	86ee                	mv	a3,s11
    80003d0e:	963a                	add	a2,a2,a4
    80003d10:	85d2                	mv	a1,s4
    80003d12:	855e                	mv	a0,s7
    80003d14:	fffff097          	auipc	ra,0xfffff
    80003d18:	82e080e7          	jalr	-2002(ra) # 80002542 <either_copyout>
    80003d1c:	05850d63          	beq	a0,s8,80003d76 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d20:	854a                	mv	a0,s2
    80003d22:	fffff097          	auipc	ra,0xfffff
    80003d26:	5d6080e7          	jalr	1494(ra) # 800032f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d2a:	013d09bb          	addw	s3,s10,s3
    80003d2e:	009d04bb          	addw	s1,s10,s1
    80003d32:	9a6e                	add	s4,s4,s11
    80003d34:	0559fd63          	bgeu	s3,s5,80003d8e <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003d38:	00a4d59b          	srliw	a1,s1,0xa
    80003d3c:	855a                	mv	a0,s6
    80003d3e:	00000097          	auipc	ra,0x0
    80003d42:	88e080e7          	jalr	-1906(ra) # 800035cc <bmap>
    80003d46:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d4a:	c9b1                	beqz	a1,80003d9e <readi+0xea>
    bp = bread(ip->dev, addr);
    80003d4c:	000b2503          	lw	a0,0(s6)
    80003d50:	fffff097          	auipc	ra,0xfffff
    80003d54:	478080e7          	jalr	1144(ra) # 800031c8 <bread>
    80003d58:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d5a:	3ff4f713          	andi	a4,s1,1023
    80003d5e:	40ec87bb          	subw	a5,s9,a4
    80003d62:	413a86bb          	subw	a3,s5,s3
    80003d66:	8d3e                	mv	s10,a5
    80003d68:	2781                	sext.w	a5,a5
    80003d6a:	0006861b          	sext.w	a2,a3
    80003d6e:	f8f679e3          	bgeu	a2,a5,80003d00 <readi+0x4c>
    80003d72:	8d36                	mv	s10,a3
    80003d74:	b771                	j	80003d00 <readi+0x4c>
      brelse(bp);
    80003d76:	854a                	mv	a0,s2
    80003d78:	fffff097          	auipc	ra,0xfffff
    80003d7c:	580080e7          	jalr	1408(ra) # 800032f8 <brelse>
      tot = -1;
    80003d80:	59fd                	li	s3,-1
      break;
    80003d82:	6946                	ld	s2,80(sp)
    80003d84:	7c02                	ld	s8,32(sp)
    80003d86:	6ce2                	ld	s9,24(sp)
    80003d88:	6d42                	ld	s10,16(sp)
    80003d8a:	6da2                	ld	s11,8(sp)
    80003d8c:	a831                	j	80003da8 <readi+0xf4>
    80003d8e:	6946                	ld	s2,80(sp)
    80003d90:	7c02                	ld	s8,32(sp)
    80003d92:	6ce2                	ld	s9,24(sp)
    80003d94:	6d42                	ld	s10,16(sp)
    80003d96:	6da2                	ld	s11,8(sp)
    80003d98:	a801                	j	80003da8 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d9a:	89d6                	mv	s3,s5
    80003d9c:	a031                	j	80003da8 <readi+0xf4>
    80003d9e:	6946                	ld	s2,80(sp)
    80003da0:	7c02                	ld	s8,32(sp)
    80003da2:	6ce2                	ld	s9,24(sp)
    80003da4:	6d42                	ld	s10,16(sp)
    80003da6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003da8:	0009851b          	sext.w	a0,s3
    80003dac:	69a6                	ld	s3,72(sp)
}
    80003dae:	70a6                	ld	ra,104(sp)
    80003db0:	7406                	ld	s0,96(sp)
    80003db2:	64e6                	ld	s1,88(sp)
    80003db4:	6a06                	ld	s4,64(sp)
    80003db6:	7ae2                	ld	s5,56(sp)
    80003db8:	7b42                	ld	s6,48(sp)
    80003dba:	7ba2                	ld	s7,40(sp)
    80003dbc:	6165                	addi	sp,sp,112
    80003dbe:	8082                	ret
    return 0;
    80003dc0:	4501                	li	a0,0
}
    80003dc2:	8082                	ret

0000000080003dc4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dc4:	457c                	lw	a5,76(a0)
    80003dc6:	10d7ee63          	bltu	a5,a3,80003ee2 <writei+0x11e>
{
    80003dca:	7159                	addi	sp,sp,-112
    80003dcc:	f486                	sd	ra,104(sp)
    80003dce:	f0a2                	sd	s0,96(sp)
    80003dd0:	e8ca                	sd	s2,80(sp)
    80003dd2:	e0d2                	sd	s4,64(sp)
    80003dd4:	fc56                	sd	s5,56(sp)
    80003dd6:	f85a                	sd	s6,48(sp)
    80003dd8:	f45e                	sd	s7,40(sp)
    80003dda:	1880                	addi	s0,sp,112
    80003ddc:	8aaa                	mv	s5,a0
    80003dde:	8bae                	mv	s7,a1
    80003de0:	8a32                	mv	s4,a2
    80003de2:	8936                	mv	s2,a3
    80003de4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003de6:	00e687bb          	addw	a5,a3,a4
    80003dea:	0ed7ee63          	bltu	a5,a3,80003ee6 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dee:	00043737          	lui	a4,0x43
    80003df2:	0ef76c63          	bltu	a4,a5,80003eea <writei+0x126>
    80003df6:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003df8:	0c0b0d63          	beqz	s6,80003ed2 <writei+0x10e>
    80003dfc:	eca6                	sd	s1,88(sp)
    80003dfe:	f062                	sd	s8,32(sp)
    80003e00:	ec66                	sd	s9,24(sp)
    80003e02:	e86a                	sd	s10,16(sp)
    80003e04:	e46e                	sd	s11,8(sp)
    80003e06:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e08:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e0c:	5c7d                	li	s8,-1
    80003e0e:	a091                	j	80003e52 <writei+0x8e>
    80003e10:	020d1d93          	slli	s11,s10,0x20
    80003e14:	020ddd93          	srli	s11,s11,0x20
    80003e18:	05848513          	addi	a0,s1,88
    80003e1c:	86ee                	mv	a3,s11
    80003e1e:	8652                	mv	a2,s4
    80003e20:	85de                	mv	a1,s7
    80003e22:	953a                	add	a0,a0,a4
    80003e24:	ffffe097          	auipc	ra,0xffffe
    80003e28:	774080e7          	jalr	1908(ra) # 80002598 <either_copyin>
    80003e2c:	07850263          	beq	a0,s8,80003e90 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e30:	8526                	mv	a0,s1
    80003e32:	00000097          	auipc	ra,0x0
    80003e36:	770080e7          	jalr	1904(ra) # 800045a2 <log_write>
    brelse(bp);
    80003e3a:	8526                	mv	a0,s1
    80003e3c:	fffff097          	auipc	ra,0xfffff
    80003e40:	4bc080e7          	jalr	1212(ra) # 800032f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e44:	013d09bb          	addw	s3,s10,s3
    80003e48:	012d093b          	addw	s2,s10,s2
    80003e4c:	9a6e                	add	s4,s4,s11
    80003e4e:	0569f663          	bgeu	s3,s6,80003e9a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e52:	00a9559b          	srliw	a1,s2,0xa
    80003e56:	8556                	mv	a0,s5
    80003e58:	fffff097          	auipc	ra,0xfffff
    80003e5c:	774080e7          	jalr	1908(ra) # 800035cc <bmap>
    80003e60:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e64:	c99d                	beqz	a1,80003e9a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e66:	000aa503          	lw	a0,0(s5)
    80003e6a:	fffff097          	auipc	ra,0xfffff
    80003e6e:	35e080e7          	jalr	862(ra) # 800031c8 <bread>
    80003e72:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e74:	3ff97713          	andi	a4,s2,1023
    80003e78:	40ec87bb          	subw	a5,s9,a4
    80003e7c:	413b06bb          	subw	a3,s6,s3
    80003e80:	8d3e                	mv	s10,a5
    80003e82:	2781                	sext.w	a5,a5
    80003e84:	0006861b          	sext.w	a2,a3
    80003e88:	f8f674e3          	bgeu	a2,a5,80003e10 <writei+0x4c>
    80003e8c:	8d36                	mv	s10,a3
    80003e8e:	b749                	j	80003e10 <writei+0x4c>
      brelse(bp);
    80003e90:	8526                	mv	a0,s1
    80003e92:	fffff097          	auipc	ra,0xfffff
    80003e96:	466080e7          	jalr	1126(ra) # 800032f8 <brelse>
  }

  if(off > ip->size)
    80003e9a:	04caa783          	lw	a5,76(s5)
    80003e9e:	0327fc63          	bgeu	a5,s2,80003ed6 <writei+0x112>
    ip->size = off;
    80003ea2:	052aa623          	sw	s2,76(s5)
    80003ea6:	64e6                	ld	s1,88(sp)
    80003ea8:	7c02                	ld	s8,32(sp)
    80003eaa:	6ce2                	ld	s9,24(sp)
    80003eac:	6d42                	ld	s10,16(sp)
    80003eae:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003eb0:	8556                	mv	a0,s5
    80003eb2:	00000097          	auipc	ra,0x0
    80003eb6:	a7e080e7          	jalr	-1410(ra) # 80003930 <iupdate>

  return tot;
    80003eba:	0009851b          	sext.w	a0,s3
    80003ebe:	69a6                	ld	s3,72(sp)
}
    80003ec0:	70a6                	ld	ra,104(sp)
    80003ec2:	7406                	ld	s0,96(sp)
    80003ec4:	6946                	ld	s2,80(sp)
    80003ec6:	6a06                	ld	s4,64(sp)
    80003ec8:	7ae2                	ld	s5,56(sp)
    80003eca:	7b42                	ld	s6,48(sp)
    80003ecc:	7ba2                	ld	s7,40(sp)
    80003ece:	6165                	addi	sp,sp,112
    80003ed0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ed2:	89da                	mv	s3,s6
    80003ed4:	bff1                	j	80003eb0 <writei+0xec>
    80003ed6:	64e6                	ld	s1,88(sp)
    80003ed8:	7c02                	ld	s8,32(sp)
    80003eda:	6ce2                	ld	s9,24(sp)
    80003edc:	6d42                	ld	s10,16(sp)
    80003ede:	6da2                	ld	s11,8(sp)
    80003ee0:	bfc1                	j	80003eb0 <writei+0xec>
    return -1;
    80003ee2:	557d                	li	a0,-1
}
    80003ee4:	8082                	ret
    return -1;
    80003ee6:	557d                	li	a0,-1
    80003ee8:	bfe1                	j	80003ec0 <writei+0xfc>
    return -1;
    80003eea:	557d                	li	a0,-1
    80003eec:	bfd1                	j	80003ec0 <writei+0xfc>

0000000080003eee <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003eee:	1141                	addi	sp,sp,-16
    80003ef0:	e406                	sd	ra,8(sp)
    80003ef2:	e022                	sd	s0,0(sp)
    80003ef4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ef6:	4639                	li	a2,14
    80003ef8:	ffffd097          	auipc	ra,0xffffd
    80003efc:	f0c080e7          	jalr	-244(ra) # 80000e04 <strncmp>
}
    80003f00:	60a2                	ld	ra,8(sp)
    80003f02:	6402                	ld	s0,0(sp)
    80003f04:	0141                	addi	sp,sp,16
    80003f06:	8082                	ret

0000000080003f08 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f08:	7139                	addi	sp,sp,-64
    80003f0a:	fc06                	sd	ra,56(sp)
    80003f0c:	f822                	sd	s0,48(sp)
    80003f0e:	f426                	sd	s1,40(sp)
    80003f10:	f04a                	sd	s2,32(sp)
    80003f12:	ec4e                	sd	s3,24(sp)
    80003f14:	e852                	sd	s4,16(sp)
    80003f16:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f18:	04451703          	lh	a4,68(a0)
    80003f1c:	4785                	li	a5,1
    80003f1e:	00f71a63          	bne	a4,a5,80003f32 <dirlookup+0x2a>
    80003f22:	892a                	mv	s2,a0
    80003f24:	89ae                	mv	s3,a1
    80003f26:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f28:	457c                	lw	a5,76(a0)
    80003f2a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f2c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f2e:	e79d                	bnez	a5,80003f5c <dirlookup+0x54>
    80003f30:	a8a5                	j	80003fa8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f32:	00004517          	auipc	a0,0x4
    80003f36:	5a650513          	addi	a0,a0,1446 # 800084d8 <etext+0x4d8>
    80003f3a:	ffffc097          	auipc	ra,0xffffc
    80003f3e:	626080e7          	jalr	1574(ra) # 80000560 <panic>
      panic("dirlookup read");
    80003f42:	00004517          	auipc	a0,0x4
    80003f46:	5ae50513          	addi	a0,a0,1454 # 800084f0 <etext+0x4f0>
    80003f4a:	ffffc097          	auipc	ra,0xffffc
    80003f4e:	616080e7          	jalr	1558(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f52:	24c1                	addiw	s1,s1,16
    80003f54:	04c92783          	lw	a5,76(s2)
    80003f58:	04f4f763          	bgeu	s1,a5,80003fa6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f5c:	4741                	li	a4,16
    80003f5e:	86a6                	mv	a3,s1
    80003f60:	fc040613          	addi	a2,s0,-64
    80003f64:	4581                	li	a1,0
    80003f66:	854a                	mv	a0,s2
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	d4c080e7          	jalr	-692(ra) # 80003cb4 <readi>
    80003f70:	47c1                	li	a5,16
    80003f72:	fcf518e3          	bne	a0,a5,80003f42 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f76:	fc045783          	lhu	a5,-64(s0)
    80003f7a:	dfe1                	beqz	a5,80003f52 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f7c:	fc240593          	addi	a1,s0,-62
    80003f80:	854e                	mv	a0,s3
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	f6c080e7          	jalr	-148(ra) # 80003eee <namecmp>
    80003f8a:	f561                	bnez	a0,80003f52 <dirlookup+0x4a>
      if(poff)
    80003f8c:	000a0463          	beqz	s4,80003f94 <dirlookup+0x8c>
        *poff = off;
    80003f90:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f94:	fc045583          	lhu	a1,-64(s0)
    80003f98:	00092503          	lw	a0,0(s2)
    80003f9c:	fffff097          	auipc	ra,0xfffff
    80003fa0:	720080e7          	jalr	1824(ra) # 800036bc <iget>
    80003fa4:	a011                	j	80003fa8 <dirlookup+0xa0>
  return 0;
    80003fa6:	4501                	li	a0,0
}
    80003fa8:	70e2                	ld	ra,56(sp)
    80003faa:	7442                	ld	s0,48(sp)
    80003fac:	74a2                	ld	s1,40(sp)
    80003fae:	7902                	ld	s2,32(sp)
    80003fb0:	69e2                	ld	s3,24(sp)
    80003fb2:	6a42                	ld	s4,16(sp)
    80003fb4:	6121                	addi	sp,sp,64
    80003fb6:	8082                	ret

0000000080003fb8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fb8:	711d                	addi	sp,sp,-96
    80003fba:	ec86                	sd	ra,88(sp)
    80003fbc:	e8a2                	sd	s0,80(sp)
    80003fbe:	e4a6                	sd	s1,72(sp)
    80003fc0:	e0ca                	sd	s2,64(sp)
    80003fc2:	fc4e                	sd	s3,56(sp)
    80003fc4:	f852                	sd	s4,48(sp)
    80003fc6:	f456                	sd	s5,40(sp)
    80003fc8:	f05a                	sd	s6,32(sp)
    80003fca:	ec5e                	sd	s7,24(sp)
    80003fcc:	e862                	sd	s8,16(sp)
    80003fce:	e466                	sd	s9,8(sp)
    80003fd0:	1080                	addi	s0,sp,96
    80003fd2:	84aa                	mv	s1,a0
    80003fd4:	8b2e                	mv	s6,a1
    80003fd6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003fd8:	00054703          	lbu	a4,0(a0)
    80003fdc:	02f00793          	li	a5,47
    80003fe0:	02f70263          	beq	a4,a5,80004004 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fe4:	ffffe097          	auipc	ra,0xffffe
    80003fe8:	a66080e7          	jalr	-1434(ra) # 80001a4a <myproc>
    80003fec:	15053503          	ld	a0,336(a0)
    80003ff0:	00000097          	auipc	ra,0x0
    80003ff4:	9ce080e7          	jalr	-1586(ra) # 800039be <idup>
    80003ff8:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ffa:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ffe:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004000:	4b85                	li	s7,1
    80004002:	a875                	j	800040be <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004004:	4585                	li	a1,1
    80004006:	4505                	li	a0,1
    80004008:	fffff097          	auipc	ra,0xfffff
    8000400c:	6b4080e7          	jalr	1716(ra) # 800036bc <iget>
    80004010:	8a2a                	mv	s4,a0
    80004012:	b7e5                	j	80003ffa <namex+0x42>
      iunlockput(ip);
    80004014:	8552                	mv	a0,s4
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	c4c080e7          	jalr	-948(ra) # 80003c62 <iunlockput>
      return 0;
    8000401e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004020:	8552                	mv	a0,s4
    80004022:	60e6                	ld	ra,88(sp)
    80004024:	6446                	ld	s0,80(sp)
    80004026:	64a6                	ld	s1,72(sp)
    80004028:	6906                	ld	s2,64(sp)
    8000402a:	79e2                	ld	s3,56(sp)
    8000402c:	7a42                	ld	s4,48(sp)
    8000402e:	7aa2                	ld	s5,40(sp)
    80004030:	7b02                	ld	s6,32(sp)
    80004032:	6be2                	ld	s7,24(sp)
    80004034:	6c42                	ld	s8,16(sp)
    80004036:	6ca2                	ld	s9,8(sp)
    80004038:	6125                	addi	sp,sp,96
    8000403a:	8082                	ret
      iunlock(ip);
    8000403c:	8552                	mv	a0,s4
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	a84080e7          	jalr	-1404(ra) # 80003ac2 <iunlock>
      return ip;
    80004046:	bfe9                	j	80004020 <namex+0x68>
      iunlockput(ip);
    80004048:	8552                	mv	a0,s4
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	c18080e7          	jalr	-1000(ra) # 80003c62 <iunlockput>
      return 0;
    80004052:	8a4e                	mv	s4,s3
    80004054:	b7f1                	j	80004020 <namex+0x68>
  len = path - s;
    80004056:	40998633          	sub	a2,s3,s1
    8000405a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000405e:	099c5863          	bge	s8,s9,800040ee <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004062:	4639                	li	a2,14
    80004064:	85a6                	mv	a1,s1
    80004066:	8556                	mv	a0,s5
    80004068:	ffffd097          	auipc	ra,0xffffd
    8000406c:	d28080e7          	jalr	-728(ra) # 80000d90 <memmove>
    80004070:	84ce                	mv	s1,s3
  while(*path == '/')
    80004072:	0004c783          	lbu	a5,0(s1)
    80004076:	01279763          	bne	a5,s2,80004084 <namex+0xcc>
    path++;
    8000407a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000407c:	0004c783          	lbu	a5,0(s1)
    80004080:	ff278de3          	beq	a5,s2,8000407a <namex+0xc2>
    ilock(ip);
    80004084:	8552                	mv	a0,s4
    80004086:	00000097          	auipc	ra,0x0
    8000408a:	976080e7          	jalr	-1674(ra) # 800039fc <ilock>
    if(ip->type != T_DIR){
    8000408e:	044a1783          	lh	a5,68(s4)
    80004092:	f97791e3          	bne	a5,s7,80004014 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004096:	000b0563          	beqz	s6,800040a0 <namex+0xe8>
    8000409a:	0004c783          	lbu	a5,0(s1)
    8000409e:	dfd9                	beqz	a5,8000403c <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040a0:	4601                	li	a2,0
    800040a2:	85d6                	mv	a1,s5
    800040a4:	8552                	mv	a0,s4
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	e62080e7          	jalr	-414(ra) # 80003f08 <dirlookup>
    800040ae:	89aa                	mv	s3,a0
    800040b0:	dd41                	beqz	a0,80004048 <namex+0x90>
    iunlockput(ip);
    800040b2:	8552                	mv	a0,s4
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	bae080e7          	jalr	-1106(ra) # 80003c62 <iunlockput>
    ip = next;
    800040bc:	8a4e                	mv	s4,s3
  while(*path == '/')
    800040be:	0004c783          	lbu	a5,0(s1)
    800040c2:	01279763          	bne	a5,s2,800040d0 <namex+0x118>
    path++;
    800040c6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040c8:	0004c783          	lbu	a5,0(s1)
    800040cc:	ff278de3          	beq	a5,s2,800040c6 <namex+0x10e>
  if(*path == 0)
    800040d0:	cb9d                	beqz	a5,80004106 <namex+0x14e>
  while(*path != '/' && *path != 0)
    800040d2:	0004c783          	lbu	a5,0(s1)
    800040d6:	89a6                	mv	s3,s1
  len = path - s;
    800040d8:	4c81                	li	s9,0
    800040da:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800040dc:	01278963          	beq	a5,s2,800040ee <namex+0x136>
    800040e0:	dbbd                	beqz	a5,80004056 <namex+0x9e>
    path++;
    800040e2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800040e4:	0009c783          	lbu	a5,0(s3)
    800040e8:	ff279ce3          	bne	a5,s2,800040e0 <namex+0x128>
    800040ec:	b7ad                	j	80004056 <namex+0x9e>
    memmove(name, s, len);
    800040ee:	2601                	sext.w	a2,a2
    800040f0:	85a6                	mv	a1,s1
    800040f2:	8556                	mv	a0,s5
    800040f4:	ffffd097          	auipc	ra,0xffffd
    800040f8:	c9c080e7          	jalr	-868(ra) # 80000d90 <memmove>
    name[len] = 0;
    800040fc:	9cd6                	add	s9,s9,s5
    800040fe:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004102:	84ce                	mv	s1,s3
    80004104:	b7bd                	j	80004072 <namex+0xba>
  if(nameiparent){
    80004106:	f00b0de3          	beqz	s6,80004020 <namex+0x68>
    iput(ip);
    8000410a:	8552                	mv	a0,s4
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	aae080e7          	jalr	-1362(ra) # 80003bba <iput>
    return 0;
    80004114:	4a01                	li	s4,0
    80004116:	b729                	j	80004020 <namex+0x68>

0000000080004118 <dirlink>:
{
    80004118:	7139                	addi	sp,sp,-64
    8000411a:	fc06                	sd	ra,56(sp)
    8000411c:	f822                	sd	s0,48(sp)
    8000411e:	f04a                	sd	s2,32(sp)
    80004120:	ec4e                	sd	s3,24(sp)
    80004122:	e852                	sd	s4,16(sp)
    80004124:	0080                	addi	s0,sp,64
    80004126:	892a                	mv	s2,a0
    80004128:	8a2e                	mv	s4,a1
    8000412a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000412c:	4601                	li	a2,0
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	dda080e7          	jalr	-550(ra) # 80003f08 <dirlookup>
    80004136:	ed25                	bnez	a0,800041ae <dirlink+0x96>
    80004138:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000413a:	04c92483          	lw	s1,76(s2)
    8000413e:	c49d                	beqz	s1,8000416c <dirlink+0x54>
    80004140:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004142:	4741                	li	a4,16
    80004144:	86a6                	mv	a3,s1
    80004146:	fc040613          	addi	a2,s0,-64
    8000414a:	4581                	li	a1,0
    8000414c:	854a                	mv	a0,s2
    8000414e:	00000097          	auipc	ra,0x0
    80004152:	b66080e7          	jalr	-1178(ra) # 80003cb4 <readi>
    80004156:	47c1                	li	a5,16
    80004158:	06f51163          	bne	a0,a5,800041ba <dirlink+0xa2>
    if(de.inum == 0)
    8000415c:	fc045783          	lhu	a5,-64(s0)
    80004160:	c791                	beqz	a5,8000416c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004162:	24c1                	addiw	s1,s1,16
    80004164:	04c92783          	lw	a5,76(s2)
    80004168:	fcf4ede3          	bltu	s1,a5,80004142 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000416c:	4639                	li	a2,14
    8000416e:	85d2                	mv	a1,s4
    80004170:	fc240513          	addi	a0,s0,-62
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	cc6080e7          	jalr	-826(ra) # 80000e3a <strncpy>
  de.inum = inum;
    8000417c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004180:	4741                	li	a4,16
    80004182:	86a6                	mv	a3,s1
    80004184:	fc040613          	addi	a2,s0,-64
    80004188:	4581                	li	a1,0
    8000418a:	854a                	mv	a0,s2
    8000418c:	00000097          	auipc	ra,0x0
    80004190:	c38080e7          	jalr	-968(ra) # 80003dc4 <writei>
    80004194:	1541                	addi	a0,a0,-16
    80004196:	00a03533          	snez	a0,a0
    8000419a:	40a00533          	neg	a0,a0
    8000419e:	74a2                	ld	s1,40(sp)
}
    800041a0:	70e2                	ld	ra,56(sp)
    800041a2:	7442                	ld	s0,48(sp)
    800041a4:	7902                	ld	s2,32(sp)
    800041a6:	69e2                	ld	s3,24(sp)
    800041a8:	6a42                	ld	s4,16(sp)
    800041aa:	6121                	addi	sp,sp,64
    800041ac:	8082                	ret
    iput(ip);
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	a0c080e7          	jalr	-1524(ra) # 80003bba <iput>
    return -1;
    800041b6:	557d                	li	a0,-1
    800041b8:	b7e5                	j	800041a0 <dirlink+0x88>
      panic("dirlink read");
    800041ba:	00004517          	auipc	a0,0x4
    800041be:	34650513          	addi	a0,a0,838 # 80008500 <etext+0x500>
    800041c2:	ffffc097          	auipc	ra,0xffffc
    800041c6:	39e080e7          	jalr	926(ra) # 80000560 <panic>

00000000800041ca <namei>:

struct inode*
namei(char *path)
{
    800041ca:	1101                	addi	sp,sp,-32
    800041cc:	ec06                	sd	ra,24(sp)
    800041ce:	e822                	sd	s0,16(sp)
    800041d0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041d2:	fe040613          	addi	a2,s0,-32
    800041d6:	4581                	li	a1,0
    800041d8:	00000097          	auipc	ra,0x0
    800041dc:	de0080e7          	jalr	-544(ra) # 80003fb8 <namex>
}
    800041e0:	60e2                	ld	ra,24(sp)
    800041e2:	6442                	ld	s0,16(sp)
    800041e4:	6105                	addi	sp,sp,32
    800041e6:	8082                	ret

00000000800041e8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041e8:	1141                	addi	sp,sp,-16
    800041ea:	e406                	sd	ra,8(sp)
    800041ec:	e022                	sd	s0,0(sp)
    800041ee:	0800                	addi	s0,sp,16
    800041f0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041f2:	4585                	li	a1,1
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	dc4080e7          	jalr	-572(ra) # 80003fb8 <namex>
}
    800041fc:	60a2                	ld	ra,8(sp)
    800041fe:	6402                	ld	s0,0(sp)
    80004200:	0141                	addi	sp,sp,16
    80004202:	8082                	ret

0000000080004204 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004204:	1101                	addi	sp,sp,-32
    80004206:	ec06                	sd	ra,24(sp)
    80004208:	e822                	sd	s0,16(sp)
    8000420a:	e426                	sd	s1,8(sp)
    8000420c:	e04a                	sd	s2,0(sp)
    8000420e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004210:	00022917          	auipc	s2,0x22
    80004214:	78090913          	addi	s2,s2,1920 # 80026990 <log>
    80004218:	01892583          	lw	a1,24(s2)
    8000421c:	02892503          	lw	a0,40(s2)
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	fa8080e7          	jalr	-88(ra) # 800031c8 <bread>
    80004228:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000422a:	02c92603          	lw	a2,44(s2)
    8000422e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004230:	00c05f63          	blez	a2,8000424e <write_head+0x4a>
    80004234:	00022717          	auipc	a4,0x22
    80004238:	78c70713          	addi	a4,a4,1932 # 800269c0 <log+0x30>
    8000423c:	87aa                	mv	a5,a0
    8000423e:	060a                	slli	a2,a2,0x2
    80004240:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004242:	4314                	lw	a3,0(a4)
    80004244:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004246:	0711                	addi	a4,a4,4
    80004248:	0791                	addi	a5,a5,4
    8000424a:	fec79ce3          	bne	a5,a2,80004242 <write_head+0x3e>
  }
  bwrite(buf);
    8000424e:	8526                	mv	a0,s1
    80004250:	fffff097          	auipc	ra,0xfffff
    80004254:	06a080e7          	jalr	106(ra) # 800032ba <bwrite>
  brelse(buf);
    80004258:	8526                	mv	a0,s1
    8000425a:	fffff097          	auipc	ra,0xfffff
    8000425e:	09e080e7          	jalr	158(ra) # 800032f8 <brelse>
}
    80004262:	60e2                	ld	ra,24(sp)
    80004264:	6442                	ld	s0,16(sp)
    80004266:	64a2                	ld	s1,8(sp)
    80004268:	6902                	ld	s2,0(sp)
    8000426a:	6105                	addi	sp,sp,32
    8000426c:	8082                	ret

000000008000426e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000426e:	00022797          	auipc	a5,0x22
    80004272:	74e7a783          	lw	a5,1870(a5) # 800269bc <log+0x2c>
    80004276:	0af05d63          	blez	a5,80004330 <install_trans+0xc2>
{
    8000427a:	7139                	addi	sp,sp,-64
    8000427c:	fc06                	sd	ra,56(sp)
    8000427e:	f822                	sd	s0,48(sp)
    80004280:	f426                	sd	s1,40(sp)
    80004282:	f04a                	sd	s2,32(sp)
    80004284:	ec4e                	sd	s3,24(sp)
    80004286:	e852                	sd	s4,16(sp)
    80004288:	e456                	sd	s5,8(sp)
    8000428a:	e05a                	sd	s6,0(sp)
    8000428c:	0080                	addi	s0,sp,64
    8000428e:	8b2a                	mv	s6,a0
    80004290:	00022a97          	auipc	s5,0x22
    80004294:	730a8a93          	addi	s5,s5,1840 # 800269c0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004298:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000429a:	00022997          	auipc	s3,0x22
    8000429e:	6f698993          	addi	s3,s3,1782 # 80026990 <log>
    800042a2:	a00d                	j	800042c4 <install_trans+0x56>
    brelse(lbuf);
    800042a4:	854a                	mv	a0,s2
    800042a6:	fffff097          	auipc	ra,0xfffff
    800042aa:	052080e7          	jalr	82(ra) # 800032f8 <brelse>
    brelse(dbuf);
    800042ae:	8526                	mv	a0,s1
    800042b0:	fffff097          	auipc	ra,0xfffff
    800042b4:	048080e7          	jalr	72(ra) # 800032f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042b8:	2a05                	addiw	s4,s4,1
    800042ba:	0a91                	addi	s5,s5,4
    800042bc:	02c9a783          	lw	a5,44(s3)
    800042c0:	04fa5e63          	bge	s4,a5,8000431c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042c4:	0189a583          	lw	a1,24(s3)
    800042c8:	014585bb          	addw	a1,a1,s4
    800042cc:	2585                	addiw	a1,a1,1
    800042ce:	0289a503          	lw	a0,40(s3)
    800042d2:	fffff097          	auipc	ra,0xfffff
    800042d6:	ef6080e7          	jalr	-266(ra) # 800031c8 <bread>
    800042da:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042dc:	000aa583          	lw	a1,0(s5)
    800042e0:	0289a503          	lw	a0,40(s3)
    800042e4:	fffff097          	auipc	ra,0xfffff
    800042e8:	ee4080e7          	jalr	-284(ra) # 800031c8 <bread>
    800042ec:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042ee:	40000613          	li	a2,1024
    800042f2:	05890593          	addi	a1,s2,88
    800042f6:	05850513          	addi	a0,a0,88
    800042fa:	ffffd097          	auipc	ra,0xffffd
    800042fe:	a96080e7          	jalr	-1386(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004302:	8526                	mv	a0,s1
    80004304:	fffff097          	auipc	ra,0xfffff
    80004308:	fb6080e7          	jalr	-74(ra) # 800032ba <bwrite>
    if(recovering == 0)
    8000430c:	f80b1ce3          	bnez	s6,800042a4 <install_trans+0x36>
      bunpin(dbuf);
    80004310:	8526                	mv	a0,s1
    80004312:	fffff097          	auipc	ra,0xfffff
    80004316:	0be080e7          	jalr	190(ra) # 800033d0 <bunpin>
    8000431a:	b769                	j	800042a4 <install_trans+0x36>
}
    8000431c:	70e2                	ld	ra,56(sp)
    8000431e:	7442                	ld	s0,48(sp)
    80004320:	74a2                	ld	s1,40(sp)
    80004322:	7902                	ld	s2,32(sp)
    80004324:	69e2                	ld	s3,24(sp)
    80004326:	6a42                	ld	s4,16(sp)
    80004328:	6aa2                	ld	s5,8(sp)
    8000432a:	6b02                	ld	s6,0(sp)
    8000432c:	6121                	addi	sp,sp,64
    8000432e:	8082                	ret
    80004330:	8082                	ret

0000000080004332 <initlog>:
{
    80004332:	7179                	addi	sp,sp,-48
    80004334:	f406                	sd	ra,40(sp)
    80004336:	f022                	sd	s0,32(sp)
    80004338:	ec26                	sd	s1,24(sp)
    8000433a:	e84a                	sd	s2,16(sp)
    8000433c:	e44e                	sd	s3,8(sp)
    8000433e:	1800                	addi	s0,sp,48
    80004340:	892a                	mv	s2,a0
    80004342:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004344:	00022497          	auipc	s1,0x22
    80004348:	64c48493          	addi	s1,s1,1612 # 80026990 <log>
    8000434c:	00004597          	auipc	a1,0x4
    80004350:	1c458593          	addi	a1,a1,452 # 80008510 <etext+0x510>
    80004354:	8526                	mv	a0,s1
    80004356:	ffffd097          	auipc	ra,0xffffd
    8000435a:	852080e7          	jalr	-1966(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    8000435e:	0149a583          	lw	a1,20(s3)
    80004362:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004364:	0109a783          	lw	a5,16(s3)
    80004368:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000436a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000436e:	854a                	mv	a0,s2
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	e58080e7          	jalr	-424(ra) # 800031c8 <bread>
  log.lh.n = lh->n;
    80004378:	4d30                	lw	a2,88(a0)
    8000437a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000437c:	00c05f63          	blez	a2,8000439a <initlog+0x68>
    80004380:	87aa                	mv	a5,a0
    80004382:	00022717          	auipc	a4,0x22
    80004386:	63e70713          	addi	a4,a4,1598 # 800269c0 <log+0x30>
    8000438a:	060a                	slli	a2,a2,0x2
    8000438c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000438e:	4ff4                	lw	a3,92(a5)
    80004390:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004392:	0791                	addi	a5,a5,4
    80004394:	0711                	addi	a4,a4,4
    80004396:	fec79ce3          	bne	a5,a2,8000438e <initlog+0x5c>
  brelse(buf);
    8000439a:	fffff097          	auipc	ra,0xfffff
    8000439e:	f5e080e7          	jalr	-162(ra) # 800032f8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800043a2:	4505                	li	a0,1
    800043a4:	00000097          	auipc	ra,0x0
    800043a8:	eca080e7          	jalr	-310(ra) # 8000426e <install_trans>
  log.lh.n = 0;
    800043ac:	00022797          	auipc	a5,0x22
    800043b0:	6007a823          	sw	zero,1552(a5) # 800269bc <log+0x2c>
  write_head(); // clear the log
    800043b4:	00000097          	auipc	ra,0x0
    800043b8:	e50080e7          	jalr	-432(ra) # 80004204 <write_head>
}
    800043bc:	70a2                	ld	ra,40(sp)
    800043be:	7402                	ld	s0,32(sp)
    800043c0:	64e2                	ld	s1,24(sp)
    800043c2:	6942                	ld	s2,16(sp)
    800043c4:	69a2                	ld	s3,8(sp)
    800043c6:	6145                	addi	sp,sp,48
    800043c8:	8082                	ret

00000000800043ca <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043ca:	1101                	addi	sp,sp,-32
    800043cc:	ec06                	sd	ra,24(sp)
    800043ce:	e822                	sd	s0,16(sp)
    800043d0:	e426                	sd	s1,8(sp)
    800043d2:	e04a                	sd	s2,0(sp)
    800043d4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043d6:	00022517          	auipc	a0,0x22
    800043da:	5ba50513          	addi	a0,a0,1466 # 80026990 <log>
    800043de:	ffffd097          	auipc	ra,0xffffd
    800043e2:	85a080e7          	jalr	-1958(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    800043e6:	00022497          	auipc	s1,0x22
    800043ea:	5aa48493          	addi	s1,s1,1450 # 80026990 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043ee:	4979                	li	s2,30
    800043f0:	a039                	j	800043fe <begin_op+0x34>
      sleep(&log, &log.lock);
    800043f2:	85a6                	mv	a1,s1
    800043f4:	8526                	mv	a0,s1
    800043f6:	ffffe097          	auipc	ra,0xffffe
    800043fa:	d38080e7          	jalr	-712(ra) # 8000212e <sleep>
    if(log.committing){
    800043fe:	50dc                	lw	a5,36(s1)
    80004400:	fbed                	bnez	a5,800043f2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004402:	5098                	lw	a4,32(s1)
    80004404:	2705                	addiw	a4,a4,1
    80004406:	0027179b          	slliw	a5,a4,0x2
    8000440a:	9fb9                	addw	a5,a5,a4
    8000440c:	0017979b          	slliw	a5,a5,0x1
    80004410:	54d4                	lw	a3,44(s1)
    80004412:	9fb5                	addw	a5,a5,a3
    80004414:	00f95963          	bge	s2,a5,80004426 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004418:	85a6                	mv	a1,s1
    8000441a:	8526                	mv	a0,s1
    8000441c:	ffffe097          	auipc	ra,0xffffe
    80004420:	d12080e7          	jalr	-750(ra) # 8000212e <sleep>
    80004424:	bfe9                	j	800043fe <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004426:	00022517          	auipc	a0,0x22
    8000442a:	56a50513          	addi	a0,a0,1386 # 80026990 <log>
    8000442e:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004430:	ffffd097          	auipc	ra,0xffffd
    80004434:	8bc080e7          	jalr	-1860(ra) # 80000cec <release>
      break;
    }
  }
}
    80004438:	60e2                	ld	ra,24(sp)
    8000443a:	6442                	ld	s0,16(sp)
    8000443c:	64a2                	ld	s1,8(sp)
    8000443e:	6902                	ld	s2,0(sp)
    80004440:	6105                	addi	sp,sp,32
    80004442:	8082                	ret

0000000080004444 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004444:	7139                	addi	sp,sp,-64
    80004446:	fc06                	sd	ra,56(sp)
    80004448:	f822                	sd	s0,48(sp)
    8000444a:	f426                	sd	s1,40(sp)
    8000444c:	f04a                	sd	s2,32(sp)
    8000444e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004450:	00022497          	auipc	s1,0x22
    80004454:	54048493          	addi	s1,s1,1344 # 80026990 <log>
    80004458:	8526                	mv	a0,s1
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	7de080e7          	jalr	2014(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    80004462:	509c                	lw	a5,32(s1)
    80004464:	37fd                	addiw	a5,a5,-1
    80004466:	0007891b          	sext.w	s2,a5
    8000446a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000446c:	50dc                	lw	a5,36(s1)
    8000446e:	e7b9                	bnez	a5,800044bc <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004470:	06091163          	bnez	s2,800044d2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004474:	00022497          	auipc	s1,0x22
    80004478:	51c48493          	addi	s1,s1,1308 # 80026990 <log>
    8000447c:	4785                	li	a5,1
    8000447e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004480:	8526                	mv	a0,s1
    80004482:	ffffd097          	auipc	ra,0xffffd
    80004486:	86a080e7          	jalr	-1942(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000448a:	54dc                	lw	a5,44(s1)
    8000448c:	06f04763          	bgtz	a5,800044fa <end_op+0xb6>
    acquire(&log.lock);
    80004490:	00022497          	auipc	s1,0x22
    80004494:	50048493          	addi	s1,s1,1280 # 80026990 <log>
    80004498:	8526                	mv	a0,s1
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	79e080e7          	jalr	1950(ra) # 80000c38 <acquire>
    log.committing = 0;
    800044a2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800044a6:	8526                	mv	a0,s1
    800044a8:	ffffe097          	auipc	ra,0xffffe
    800044ac:	cea080e7          	jalr	-790(ra) # 80002192 <wakeup>
    release(&log.lock);
    800044b0:	8526                	mv	a0,s1
    800044b2:	ffffd097          	auipc	ra,0xffffd
    800044b6:	83a080e7          	jalr	-1990(ra) # 80000cec <release>
}
    800044ba:	a815                	j	800044ee <end_op+0xaa>
    800044bc:	ec4e                	sd	s3,24(sp)
    800044be:	e852                	sd	s4,16(sp)
    800044c0:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800044c2:	00004517          	auipc	a0,0x4
    800044c6:	05650513          	addi	a0,a0,86 # 80008518 <etext+0x518>
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	096080e7          	jalr	150(ra) # 80000560 <panic>
    wakeup(&log);
    800044d2:	00022497          	auipc	s1,0x22
    800044d6:	4be48493          	addi	s1,s1,1214 # 80026990 <log>
    800044da:	8526                	mv	a0,s1
    800044dc:	ffffe097          	auipc	ra,0xffffe
    800044e0:	cb6080e7          	jalr	-842(ra) # 80002192 <wakeup>
  release(&log.lock);
    800044e4:	8526                	mv	a0,s1
    800044e6:	ffffd097          	auipc	ra,0xffffd
    800044ea:	806080e7          	jalr	-2042(ra) # 80000cec <release>
}
    800044ee:	70e2                	ld	ra,56(sp)
    800044f0:	7442                	ld	s0,48(sp)
    800044f2:	74a2                	ld	s1,40(sp)
    800044f4:	7902                	ld	s2,32(sp)
    800044f6:	6121                	addi	sp,sp,64
    800044f8:	8082                	ret
    800044fa:	ec4e                	sd	s3,24(sp)
    800044fc:	e852                	sd	s4,16(sp)
    800044fe:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004500:	00022a97          	auipc	s5,0x22
    80004504:	4c0a8a93          	addi	s5,s5,1216 # 800269c0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004508:	00022a17          	auipc	s4,0x22
    8000450c:	488a0a13          	addi	s4,s4,1160 # 80026990 <log>
    80004510:	018a2583          	lw	a1,24(s4)
    80004514:	012585bb          	addw	a1,a1,s2
    80004518:	2585                	addiw	a1,a1,1
    8000451a:	028a2503          	lw	a0,40(s4)
    8000451e:	fffff097          	auipc	ra,0xfffff
    80004522:	caa080e7          	jalr	-854(ra) # 800031c8 <bread>
    80004526:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004528:	000aa583          	lw	a1,0(s5)
    8000452c:	028a2503          	lw	a0,40(s4)
    80004530:	fffff097          	auipc	ra,0xfffff
    80004534:	c98080e7          	jalr	-872(ra) # 800031c8 <bread>
    80004538:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000453a:	40000613          	li	a2,1024
    8000453e:	05850593          	addi	a1,a0,88
    80004542:	05848513          	addi	a0,s1,88
    80004546:	ffffd097          	auipc	ra,0xffffd
    8000454a:	84a080e7          	jalr	-1974(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    8000454e:	8526                	mv	a0,s1
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	d6a080e7          	jalr	-662(ra) # 800032ba <bwrite>
    brelse(from);
    80004558:	854e                	mv	a0,s3
    8000455a:	fffff097          	auipc	ra,0xfffff
    8000455e:	d9e080e7          	jalr	-610(ra) # 800032f8 <brelse>
    brelse(to);
    80004562:	8526                	mv	a0,s1
    80004564:	fffff097          	auipc	ra,0xfffff
    80004568:	d94080e7          	jalr	-620(ra) # 800032f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456c:	2905                	addiw	s2,s2,1
    8000456e:	0a91                	addi	s5,s5,4
    80004570:	02ca2783          	lw	a5,44(s4)
    80004574:	f8f94ee3          	blt	s2,a5,80004510 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004578:	00000097          	auipc	ra,0x0
    8000457c:	c8c080e7          	jalr	-884(ra) # 80004204 <write_head>
    install_trans(0); // Now install writes to home locations
    80004580:	4501                	li	a0,0
    80004582:	00000097          	auipc	ra,0x0
    80004586:	cec080e7          	jalr	-788(ra) # 8000426e <install_trans>
    log.lh.n = 0;
    8000458a:	00022797          	auipc	a5,0x22
    8000458e:	4207a923          	sw	zero,1074(a5) # 800269bc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004592:	00000097          	auipc	ra,0x0
    80004596:	c72080e7          	jalr	-910(ra) # 80004204 <write_head>
    8000459a:	69e2                	ld	s3,24(sp)
    8000459c:	6a42                	ld	s4,16(sp)
    8000459e:	6aa2                	ld	s5,8(sp)
    800045a0:	bdc5                	j	80004490 <end_op+0x4c>

00000000800045a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800045a2:	1101                	addi	sp,sp,-32
    800045a4:	ec06                	sd	ra,24(sp)
    800045a6:	e822                	sd	s0,16(sp)
    800045a8:	e426                	sd	s1,8(sp)
    800045aa:	e04a                	sd	s2,0(sp)
    800045ac:	1000                	addi	s0,sp,32
    800045ae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045b0:	00022917          	auipc	s2,0x22
    800045b4:	3e090913          	addi	s2,s2,992 # 80026990 <log>
    800045b8:	854a                	mv	a0,s2
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	67e080e7          	jalr	1662(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045c2:	02c92603          	lw	a2,44(s2)
    800045c6:	47f5                	li	a5,29
    800045c8:	06c7c563          	blt	a5,a2,80004632 <log_write+0x90>
    800045cc:	00022797          	auipc	a5,0x22
    800045d0:	3e07a783          	lw	a5,992(a5) # 800269ac <log+0x1c>
    800045d4:	37fd                	addiw	a5,a5,-1
    800045d6:	04f65e63          	bge	a2,a5,80004632 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045da:	00022797          	auipc	a5,0x22
    800045de:	3d67a783          	lw	a5,982(a5) # 800269b0 <log+0x20>
    800045e2:	06f05063          	blez	a5,80004642 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045e6:	4781                	li	a5,0
    800045e8:	06c05563          	blez	a2,80004652 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045ec:	44cc                	lw	a1,12(s1)
    800045ee:	00022717          	auipc	a4,0x22
    800045f2:	3d270713          	addi	a4,a4,978 # 800269c0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045f6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045f8:	4314                	lw	a3,0(a4)
    800045fa:	04b68c63          	beq	a3,a1,80004652 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045fe:	2785                	addiw	a5,a5,1
    80004600:	0711                	addi	a4,a4,4
    80004602:	fef61be3          	bne	a2,a5,800045f8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004606:	0621                	addi	a2,a2,8
    80004608:	060a                	slli	a2,a2,0x2
    8000460a:	00022797          	auipc	a5,0x22
    8000460e:	38678793          	addi	a5,a5,902 # 80026990 <log>
    80004612:	97b2                	add	a5,a5,a2
    80004614:	44d8                	lw	a4,12(s1)
    80004616:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004618:	8526                	mv	a0,s1
    8000461a:	fffff097          	auipc	ra,0xfffff
    8000461e:	d7a080e7          	jalr	-646(ra) # 80003394 <bpin>
    log.lh.n++;
    80004622:	00022717          	auipc	a4,0x22
    80004626:	36e70713          	addi	a4,a4,878 # 80026990 <log>
    8000462a:	575c                	lw	a5,44(a4)
    8000462c:	2785                	addiw	a5,a5,1
    8000462e:	d75c                	sw	a5,44(a4)
    80004630:	a82d                	j	8000466a <log_write+0xc8>
    panic("too big a transaction");
    80004632:	00004517          	auipc	a0,0x4
    80004636:	ef650513          	addi	a0,a0,-266 # 80008528 <etext+0x528>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	f26080e7          	jalr	-218(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004642:	00004517          	auipc	a0,0x4
    80004646:	efe50513          	addi	a0,a0,-258 # 80008540 <etext+0x540>
    8000464a:	ffffc097          	auipc	ra,0xffffc
    8000464e:	f16080e7          	jalr	-234(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004652:	00878693          	addi	a3,a5,8
    80004656:	068a                	slli	a3,a3,0x2
    80004658:	00022717          	auipc	a4,0x22
    8000465c:	33870713          	addi	a4,a4,824 # 80026990 <log>
    80004660:	9736                	add	a4,a4,a3
    80004662:	44d4                	lw	a3,12(s1)
    80004664:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004666:	faf609e3          	beq	a2,a5,80004618 <log_write+0x76>
  }
  release(&log.lock);
    8000466a:	00022517          	auipc	a0,0x22
    8000466e:	32650513          	addi	a0,a0,806 # 80026990 <log>
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	67a080e7          	jalr	1658(ra) # 80000cec <release>
}
    8000467a:	60e2                	ld	ra,24(sp)
    8000467c:	6442                	ld	s0,16(sp)
    8000467e:	64a2                	ld	s1,8(sp)
    80004680:	6902                	ld	s2,0(sp)
    80004682:	6105                	addi	sp,sp,32
    80004684:	8082                	ret

0000000080004686 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004686:	1101                	addi	sp,sp,-32
    80004688:	ec06                	sd	ra,24(sp)
    8000468a:	e822                	sd	s0,16(sp)
    8000468c:	e426                	sd	s1,8(sp)
    8000468e:	e04a                	sd	s2,0(sp)
    80004690:	1000                	addi	s0,sp,32
    80004692:	84aa                	mv	s1,a0
    80004694:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004696:	00004597          	auipc	a1,0x4
    8000469a:	eca58593          	addi	a1,a1,-310 # 80008560 <etext+0x560>
    8000469e:	0521                	addi	a0,a0,8
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	508080e7          	jalr	1288(ra) # 80000ba8 <initlock>
  lk->name = name;
    800046a8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046b0:	0204a423          	sw	zero,40(s1)
}
    800046b4:	60e2                	ld	ra,24(sp)
    800046b6:	6442                	ld	s0,16(sp)
    800046b8:	64a2                	ld	s1,8(sp)
    800046ba:	6902                	ld	s2,0(sp)
    800046bc:	6105                	addi	sp,sp,32
    800046be:	8082                	ret

00000000800046c0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046c0:	1101                	addi	sp,sp,-32
    800046c2:	ec06                	sd	ra,24(sp)
    800046c4:	e822                	sd	s0,16(sp)
    800046c6:	e426                	sd	s1,8(sp)
    800046c8:	e04a                	sd	s2,0(sp)
    800046ca:	1000                	addi	s0,sp,32
    800046cc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ce:	00850913          	addi	s2,a0,8
    800046d2:	854a                	mv	a0,s2
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	564080e7          	jalr	1380(ra) # 80000c38 <acquire>
  while (lk->locked) {
    800046dc:	409c                	lw	a5,0(s1)
    800046de:	cb89                	beqz	a5,800046f0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046e0:	85ca                	mv	a1,s2
    800046e2:	8526                	mv	a0,s1
    800046e4:	ffffe097          	auipc	ra,0xffffe
    800046e8:	a4a080e7          	jalr	-1462(ra) # 8000212e <sleep>
  while (lk->locked) {
    800046ec:	409c                	lw	a5,0(s1)
    800046ee:	fbed                	bnez	a5,800046e0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046f0:	4785                	li	a5,1
    800046f2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046f4:	ffffd097          	auipc	ra,0xffffd
    800046f8:	356080e7          	jalr	854(ra) # 80001a4a <myproc>
    800046fc:	591c                	lw	a5,48(a0)
    800046fe:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004700:	854a                	mv	a0,s2
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	5ea080e7          	jalr	1514(ra) # 80000cec <release>
}
    8000470a:	60e2                	ld	ra,24(sp)
    8000470c:	6442                	ld	s0,16(sp)
    8000470e:	64a2                	ld	s1,8(sp)
    80004710:	6902                	ld	s2,0(sp)
    80004712:	6105                	addi	sp,sp,32
    80004714:	8082                	ret

0000000080004716 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004716:	1101                	addi	sp,sp,-32
    80004718:	ec06                	sd	ra,24(sp)
    8000471a:	e822                	sd	s0,16(sp)
    8000471c:	e426                	sd	s1,8(sp)
    8000471e:	e04a                	sd	s2,0(sp)
    80004720:	1000                	addi	s0,sp,32
    80004722:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004724:	00850913          	addi	s2,a0,8
    80004728:	854a                	mv	a0,s2
    8000472a:	ffffc097          	auipc	ra,0xffffc
    8000472e:	50e080e7          	jalr	1294(ra) # 80000c38 <acquire>
  lk->locked = 0;
    80004732:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004736:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000473a:	8526                	mv	a0,s1
    8000473c:	ffffe097          	auipc	ra,0xffffe
    80004740:	a56080e7          	jalr	-1450(ra) # 80002192 <wakeup>
  release(&lk->lk);
    80004744:	854a                	mv	a0,s2
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	5a6080e7          	jalr	1446(ra) # 80000cec <release>
}
    8000474e:	60e2                	ld	ra,24(sp)
    80004750:	6442                	ld	s0,16(sp)
    80004752:	64a2                	ld	s1,8(sp)
    80004754:	6902                	ld	s2,0(sp)
    80004756:	6105                	addi	sp,sp,32
    80004758:	8082                	ret

000000008000475a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000475a:	7179                	addi	sp,sp,-48
    8000475c:	f406                	sd	ra,40(sp)
    8000475e:	f022                	sd	s0,32(sp)
    80004760:	ec26                	sd	s1,24(sp)
    80004762:	e84a                	sd	s2,16(sp)
    80004764:	1800                	addi	s0,sp,48
    80004766:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004768:	00850913          	addi	s2,a0,8
    8000476c:	854a                	mv	a0,s2
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	4ca080e7          	jalr	1226(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004776:	409c                	lw	a5,0(s1)
    80004778:	ef91                	bnez	a5,80004794 <holdingsleep+0x3a>
    8000477a:	4481                	li	s1,0
  release(&lk->lk);
    8000477c:	854a                	mv	a0,s2
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	56e080e7          	jalr	1390(ra) # 80000cec <release>
  return r;
}
    80004786:	8526                	mv	a0,s1
    80004788:	70a2                	ld	ra,40(sp)
    8000478a:	7402                	ld	s0,32(sp)
    8000478c:	64e2                	ld	s1,24(sp)
    8000478e:	6942                	ld	s2,16(sp)
    80004790:	6145                	addi	sp,sp,48
    80004792:	8082                	ret
    80004794:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004796:	0284a983          	lw	s3,40(s1)
    8000479a:	ffffd097          	auipc	ra,0xffffd
    8000479e:	2b0080e7          	jalr	688(ra) # 80001a4a <myproc>
    800047a2:	5904                	lw	s1,48(a0)
    800047a4:	413484b3          	sub	s1,s1,s3
    800047a8:	0014b493          	seqz	s1,s1
    800047ac:	69a2                	ld	s3,8(sp)
    800047ae:	b7f9                	j	8000477c <holdingsleep+0x22>

00000000800047b0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047b0:	1141                	addi	sp,sp,-16
    800047b2:	e406                	sd	ra,8(sp)
    800047b4:	e022                	sd	s0,0(sp)
    800047b6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047b8:	00004597          	auipc	a1,0x4
    800047bc:	db858593          	addi	a1,a1,-584 # 80008570 <etext+0x570>
    800047c0:	00022517          	auipc	a0,0x22
    800047c4:	31850513          	addi	a0,a0,792 # 80026ad8 <ftable>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	3e0080e7          	jalr	992(ra) # 80000ba8 <initlock>
}
    800047d0:	60a2                	ld	ra,8(sp)
    800047d2:	6402                	ld	s0,0(sp)
    800047d4:	0141                	addi	sp,sp,16
    800047d6:	8082                	ret

00000000800047d8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047d8:	1101                	addi	sp,sp,-32
    800047da:	ec06                	sd	ra,24(sp)
    800047dc:	e822                	sd	s0,16(sp)
    800047de:	e426                	sd	s1,8(sp)
    800047e0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047e2:	00022517          	auipc	a0,0x22
    800047e6:	2f650513          	addi	a0,a0,758 # 80026ad8 <ftable>
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	44e080e7          	jalr	1102(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047f2:	00022497          	auipc	s1,0x22
    800047f6:	2fe48493          	addi	s1,s1,766 # 80026af0 <ftable+0x18>
    800047fa:	00023717          	auipc	a4,0x23
    800047fe:	29670713          	addi	a4,a4,662 # 80027a90 <disk>
    if(f->ref == 0){
    80004802:	40dc                	lw	a5,4(s1)
    80004804:	cf99                	beqz	a5,80004822 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004806:	02848493          	addi	s1,s1,40
    8000480a:	fee49ce3          	bne	s1,a4,80004802 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000480e:	00022517          	auipc	a0,0x22
    80004812:	2ca50513          	addi	a0,a0,714 # 80026ad8 <ftable>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	4d6080e7          	jalr	1238(ra) # 80000cec <release>
  return 0;
    8000481e:	4481                	li	s1,0
    80004820:	a819                	j	80004836 <filealloc+0x5e>
      f->ref = 1;
    80004822:	4785                	li	a5,1
    80004824:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004826:	00022517          	auipc	a0,0x22
    8000482a:	2b250513          	addi	a0,a0,690 # 80026ad8 <ftable>
    8000482e:	ffffc097          	auipc	ra,0xffffc
    80004832:	4be080e7          	jalr	1214(ra) # 80000cec <release>
}
    80004836:	8526                	mv	a0,s1
    80004838:	60e2                	ld	ra,24(sp)
    8000483a:	6442                	ld	s0,16(sp)
    8000483c:	64a2                	ld	s1,8(sp)
    8000483e:	6105                	addi	sp,sp,32
    80004840:	8082                	ret

0000000080004842 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004842:	1101                	addi	sp,sp,-32
    80004844:	ec06                	sd	ra,24(sp)
    80004846:	e822                	sd	s0,16(sp)
    80004848:	e426                	sd	s1,8(sp)
    8000484a:	1000                	addi	s0,sp,32
    8000484c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000484e:	00022517          	auipc	a0,0x22
    80004852:	28a50513          	addi	a0,a0,650 # 80026ad8 <ftable>
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	3e2080e7          	jalr	994(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    8000485e:	40dc                	lw	a5,4(s1)
    80004860:	02f05263          	blez	a5,80004884 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004864:	2785                	addiw	a5,a5,1
    80004866:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004868:	00022517          	auipc	a0,0x22
    8000486c:	27050513          	addi	a0,a0,624 # 80026ad8 <ftable>
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	47c080e7          	jalr	1148(ra) # 80000cec <release>
  return f;
}
    80004878:	8526                	mv	a0,s1
    8000487a:	60e2                	ld	ra,24(sp)
    8000487c:	6442                	ld	s0,16(sp)
    8000487e:	64a2                	ld	s1,8(sp)
    80004880:	6105                	addi	sp,sp,32
    80004882:	8082                	ret
    panic("filedup");
    80004884:	00004517          	auipc	a0,0x4
    80004888:	cf450513          	addi	a0,a0,-780 # 80008578 <etext+0x578>
    8000488c:	ffffc097          	auipc	ra,0xffffc
    80004890:	cd4080e7          	jalr	-812(ra) # 80000560 <panic>

0000000080004894 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004894:	7139                	addi	sp,sp,-64
    80004896:	fc06                	sd	ra,56(sp)
    80004898:	f822                	sd	s0,48(sp)
    8000489a:	f426                	sd	s1,40(sp)
    8000489c:	0080                	addi	s0,sp,64
    8000489e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048a0:	00022517          	auipc	a0,0x22
    800048a4:	23850513          	addi	a0,a0,568 # 80026ad8 <ftable>
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	390080e7          	jalr	912(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    800048b0:	40dc                	lw	a5,4(s1)
    800048b2:	04f05c63          	blez	a5,8000490a <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    800048b6:	37fd                	addiw	a5,a5,-1
    800048b8:	0007871b          	sext.w	a4,a5
    800048bc:	c0dc                	sw	a5,4(s1)
    800048be:	06e04263          	bgtz	a4,80004922 <fileclose+0x8e>
    800048c2:	f04a                	sd	s2,32(sp)
    800048c4:	ec4e                	sd	s3,24(sp)
    800048c6:	e852                	sd	s4,16(sp)
    800048c8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048ca:	0004a903          	lw	s2,0(s1)
    800048ce:	0094ca83          	lbu	s5,9(s1)
    800048d2:	0104ba03          	ld	s4,16(s1)
    800048d6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048da:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048de:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048e2:	00022517          	auipc	a0,0x22
    800048e6:	1f650513          	addi	a0,a0,502 # 80026ad8 <ftable>
    800048ea:	ffffc097          	auipc	ra,0xffffc
    800048ee:	402080e7          	jalr	1026(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    800048f2:	4785                	li	a5,1
    800048f4:	04f90463          	beq	s2,a5,8000493c <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048f8:	3979                	addiw	s2,s2,-2
    800048fa:	4785                	li	a5,1
    800048fc:	0527fb63          	bgeu	a5,s2,80004952 <fileclose+0xbe>
    80004900:	7902                	ld	s2,32(sp)
    80004902:	69e2                	ld	s3,24(sp)
    80004904:	6a42                	ld	s4,16(sp)
    80004906:	6aa2                	ld	s5,8(sp)
    80004908:	a02d                	j	80004932 <fileclose+0x9e>
    8000490a:	f04a                	sd	s2,32(sp)
    8000490c:	ec4e                	sd	s3,24(sp)
    8000490e:	e852                	sd	s4,16(sp)
    80004910:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004912:	00004517          	auipc	a0,0x4
    80004916:	c6e50513          	addi	a0,a0,-914 # 80008580 <etext+0x580>
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	c46080e7          	jalr	-954(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004922:	00022517          	auipc	a0,0x22
    80004926:	1b650513          	addi	a0,a0,438 # 80026ad8 <ftable>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	3c2080e7          	jalr	962(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004932:	70e2                	ld	ra,56(sp)
    80004934:	7442                	ld	s0,48(sp)
    80004936:	74a2                	ld	s1,40(sp)
    80004938:	6121                	addi	sp,sp,64
    8000493a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000493c:	85d6                	mv	a1,s5
    8000493e:	8552                	mv	a0,s4
    80004940:	00000097          	auipc	ra,0x0
    80004944:	3a2080e7          	jalr	930(ra) # 80004ce2 <pipeclose>
    80004948:	7902                	ld	s2,32(sp)
    8000494a:	69e2                	ld	s3,24(sp)
    8000494c:	6a42                	ld	s4,16(sp)
    8000494e:	6aa2                	ld	s5,8(sp)
    80004950:	b7cd                	j	80004932 <fileclose+0x9e>
    begin_op();
    80004952:	00000097          	auipc	ra,0x0
    80004956:	a78080e7          	jalr	-1416(ra) # 800043ca <begin_op>
    iput(ff.ip);
    8000495a:	854e                	mv	a0,s3
    8000495c:	fffff097          	auipc	ra,0xfffff
    80004960:	25e080e7          	jalr	606(ra) # 80003bba <iput>
    end_op();
    80004964:	00000097          	auipc	ra,0x0
    80004968:	ae0080e7          	jalr	-1312(ra) # 80004444 <end_op>
    8000496c:	7902                	ld	s2,32(sp)
    8000496e:	69e2                	ld	s3,24(sp)
    80004970:	6a42                	ld	s4,16(sp)
    80004972:	6aa2                	ld	s5,8(sp)
    80004974:	bf7d                	j	80004932 <fileclose+0x9e>

0000000080004976 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004976:	715d                	addi	sp,sp,-80
    80004978:	e486                	sd	ra,72(sp)
    8000497a:	e0a2                	sd	s0,64(sp)
    8000497c:	fc26                	sd	s1,56(sp)
    8000497e:	f44e                	sd	s3,40(sp)
    80004980:	0880                	addi	s0,sp,80
    80004982:	84aa                	mv	s1,a0
    80004984:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004986:	ffffd097          	auipc	ra,0xffffd
    8000498a:	0c4080e7          	jalr	196(ra) # 80001a4a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000498e:	409c                	lw	a5,0(s1)
    80004990:	37f9                	addiw	a5,a5,-2
    80004992:	4705                	li	a4,1
    80004994:	04f76863          	bltu	a4,a5,800049e4 <filestat+0x6e>
    80004998:	f84a                	sd	s2,48(sp)
    8000499a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000499c:	6c88                	ld	a0,24(s1)
    8000499e:	fffff097          	auipc	ra,0xfffff
    800049a2:	05e080e7          	jalr	94(ra) # 800039fc <ilock>
    stati(f->ip, &st);
    800049a6:	fb840593          	addi	a1,s0,-72
    800049aa:	6c88                	ld	a0,24(s1)
    800049ac:	fffff097          	auipc	ra,0xfffff
    800049b0:	2de080e7          	jalr	734(ra) # 80003c8a <stati>
    iunlock(f->ip);
    800049b4:	6c88                	ld	a0,24(s1)
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	10c080e7          	jalr	268(ra) # 80003ac2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049be:	46e1                	li	a3,24
    800049c0:	fb840613          	addi	a2,s0,-72
    800049c4:	85ce                	mv	a1,s3
    800049c6:	05093503          	ld	a0,80(s2)
    800049ca:	ffffd097          	auipc	ra,0xffffd
    800049ce:	d18080e7          	jalr	-744(ra) # 800016e2 <copyout>
    800049d2:	41f5551b          	sraiw	a0,a0,0x1f
    800049d6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800049d8:	60a6                	ld	ra,72(sp)
    800049da:	6406                	ld	s0,64(sp)
    800049dc:	74e2                	ld	s1,56(sp)
    800049de:	79a2                	ld	s3,40(sp)
    800049e0:	6161                	addi	sp,sp,80
    800049e2:	8082                	ret
  return -1;
    800049e4:	557d                	li	a0,-1
    800049e6:	bfcd                	j	800049d8 <filestat+0x62>

00000000800049e8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049e8:	7179                	addi	sp,sp,-48
    800049ea:	f406                	sd	ra,40(sp)
    800049ec:	f022                	sd	s0,32(sp)
    800049ee:	e84a                	sd	s2,16(sp)
    800049f0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049f2:	00854783          	lbu	a5,8(a0)
    800049f6:	cbc5                	beqz	a5,80004aa6 <fileread+0xbe>
    800049f8:	ec26                	sd	s1,24(sp)
    800049fa:	e44e                	sd	s3,8(sp)
    800049fc:	84aa                	mv	s1,a0
    800049fe:	89ae                	mv	s3,a1
    80004a00:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a02:	411c                	lw	a5,0(a0)
    80004a04:	4705                	li	a4,1
    80004a06:	04e78963          	beq	a5,a4,80004a58 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a0a:	470d                	li	a4,3
    80004a0c:	04e78f63          	beq	a5,a4,80004a6a <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a10:	4709                	li	a4,2
    80004a12:	08e79263          	bne	a5,a4,80004a96 <fileread+0xae>
    ilock(f->ip);
    80004a16:	6d08                	ld	a0,24(a0)
    80004a18:	fffff097          	auipc	ra,0xfffff
    80004a1c:	fe4080e7          	jalr	-28(ra) # 800039fc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a20:	874a                	mv	a4,s2
    80004a22:	5094                	lw	a3,32(s1)
    80004a24:	864e                	mv	a2,s3
    80004a26:	4585                	li	a1,1
    80004a28:	6c88                	ld	a0,24(s1)
    80004a2a:	fffff097          	auipc	ra,0xfffff
    80004a2e:	28a080e7          	jalr	650(ra) # 80003cb4 <readi>
    80004a32:	892a                	mv	s2,a0
    80004a34:	00a05563          	blez	a0,80004a3e <fileread+0x56>
      f->off += r;
    80004a38:	509c                	lw	a5,32(s1)
    80004a3a:	9fa9                	addw	a5,a5,a0
    80004a3c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a3e:	6c88                	ld	a0,24(s1)
    80004a40:	fffff097          	auipc	ra,0xfffff
    80004a44:	082080e7          	jalr	130(ra) # 80003ac2 <iunlock>
    80004a48:	64e2                	ld	s1,24(sp)
    80004a4a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004a4c:	854a                	mv	a0,s2
    80004a4e:	70a2                	ld	ra,40(sp)
    80004a50:	7402                	ld	s0,32(sp)
    80004a52:	6942                	ld	s2,16(sp)
    80004a54:	6145                	addi	sp,sp,48
    80004a56:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a58:	6908                	ld	a0,16(a0)
    80004a5a:	00000097          	auipc	ra,0x0
    80004a5e:	400080e7          	jalr	1024(ra) # 80004e5a <piperead>
    80004a62:	892a                	mv	s2,a0
    80004a64:	64e2                	ld	s1,24(sp)
    80004a66:	69a2                	ld	s3,8(sp)
    80004a68:	b7d5                	j	80004a4c <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a6a:	02451783          	lh	a5,36(a0)
    80004a6e:	03079693          	slli	a3,a5,0x30
    80004a72:	92c1                	srli	a3,a3,0x30
    80004a74:	4725                	li	a4,9
    80004a76:	02d76a63          	bltu	a4,a3,80004aaa <fileread+0xc2>
    80004a7a:	0792                	slli	a5,a5,0x4
    80004a7c:	00022717          	auipc	a4,0x22
    80004a80:	fbc70713          	addi	a4,a4,-68 # 80026a38 <devsw>
    80004a84:	97ba                	add	a5,a5,a4
    80004a86:	639c                	ld	a5,0(a5)
    80004a88:	c78d                	beqz	a5,80004ab2 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004a8a:	4505                	li	a0,1
    80004a8c:	9782                	jalr	a5
    80004a8e:	892a                	mv	s2,a0
    80004a90:	64e2                	ld	s1,24(sp)
    80004a92:	69a2                	ld	s3,8(sp)
    80004a94:	bf65                	j	80004a4c <fileread+0x64>
    panic("fileread");
    80004a96:	00004517          	auipc	a0,0x4
    80004a9a:	afa50513          	addi	a0,a0,-1286 # 80008590 <etext+0x590>
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	ac2080e7          	jalr	-1342(ra) # 80000560 <panic>
    return -1;
    80004aa6:	597d                	li	s2,-1
    80004aa8:	b755                	j	80004a4c <fileread+0x64>
      return -1;
    80004aaa:	597d                	li	s2,-1
    80004aac:	64e2                	ld	s1,24(sp)
    80004aae:	69a2                	ld	s3,8(sp)
    80004ab0:	bf71                	j	80004a4c <fileread+0x64>
    80004ab2:	597d                	li	s2,-1
    80004ab4:	64e2                	ld	s1,24(sp)
    80004ab6:	69a2                	ld	s3,8(sp)
    80004ab8:	bf51                	j	80004a4c <fileread+0x64>

0000000080004aba <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004aba:	00954783          	lbu	a5,9(a0)
    80004abe:	12078963          	beqz	a5,80004bf0 <filewrite+0x136>
{
    80004ac2:	715d                	addi	sp,sp,-80
    80004ac4:	e486                	sd	ra,72(sp)
    80004ac6:	e0a2                	sd	s0,64(sp)
    80004ac8:	f84a                	sd	s2,48(sp)
    80004aca:	f052                	sd	s4,32(sp)
    80004acc:	e85a                	sd	s6,16(sp)
    80004ace:	0880                	addi	s0,sp,80
    80004ad0:	892a                	mv	s2,a0
    80004ad2:	8b2e                	mv	s6,a1
    80004ad4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ad6:	411c                	lw	a5,0(a0)
    80004ad8:	4705                	li	a4,1
    80004ada:	02e78763          	beq	a5,a4,80004b08 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ade:	470d                	li	a4,3
    80004ae0:	02e78a63          	beq	a5,a4,80004b14 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ae4:	4709                	li	a4,2
    80004ae6:	0ee79863          	bne	a5,a4,80004bd6 <filewrite+0x11c>
    80004aea:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004aec:	0cc05463          	blez	a2,80004bb4 <filewrite+0xfa>
    80004af0:	fc26                	sd	s1,56(sp)
    80004af2:	ec56                	sd	s5,24(sp)
    80004af4:	e45e                	sd	s7,8(sp)
    80004af6:	e062                	sd	s8,0(sp)
    int i = 0;
    80004af8:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004afa:	6b85                	lui	s7,0x1
    80004afc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b00:	6c05                	lui	s8,0x1
    80004b02:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b06:	a851                	j	80004b9a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004b08:	6908                	ld	a0,16(a0)
    80004b0a:	00000097          	auipc	ra,0x0
    80004b0e:	248080e7          	jalr	584(ra) # 80004d52 <pipewrite>
    80004b12:	a85d                	j	80004bc8 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b14:	02451783          	lh	a5,36(a0)
    80004b18:	03079693          	slli	a3,a5,0x30
    80004b1c:	92c1                	srli	a3,a3,0x30
    80004b1e:	4725                	li	a4,9
    80004b20:	0cd76a63          	bltu	a4,a3,80004bf4 <filewrite+0x13a>
    80004b24:	0792                	slli	a5,a5,0x4
    80004b26:	00022717          	auipc	a4,0x22
    80004b2a:	f1270713          	addi	a4,a4,-238 # 80026a38 <devsw>
    80004b2e:	97ba                	add	a5,a5,a4
    80004b30:	679c                	ld	a5,8(a5)
    80004b32:	c3f9                	beqz	a5,80004bf8 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004b34:	4505                	li	a0,1
    80004b36:	9782                	jalr	a5
    80004b38:	a841                	j	80004bc8 <filewrite+0x10e>
      if(n1 > max)
    80004b3a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004b3e:	00000097          	auipc	ra,0x0
    80004b42:	88c080e7          	jalr	-1908(ra) # 800043ca <begin_op>
      ilock(f->ip);
    80004b46:	01893503          	ld	a0,24(s2)
    80004b4a:	fffff097          	auipc	ra,0xfffff
    80004b4e:	eb2080e7          	jalr	-334(ra) # 800039fc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b52:	8756                	mv	a4,s5
    80004b54:	02092683          	lw	a3,32(s2)
    80004b58:	01698633          	add	a2,s3,s6
    80004b5c:	4585                	li	a1,1
    80004b5e:	01893503          	ld	a0,24(s2)
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	262080e7          	jalr	610(ra) # 80003dc4 <writei>
    80004b6a:	84aa                	mv	s1,a0
    80004b6c:	00a05763          	blez	a0,80004b7a <filewrite+0xc0>
        f->off += r;
    80004b70:	02092783          	lw	a5,32(s2)
    80004b74:	9fa9                	addw	a5,a5,a0
    80004b76:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b7a:	01893503          	ld	a0,24(s2)
    80004b7e:	fffff097          	auipc	ra,0xfffff
    80004b82:	f44080e7          	jalr	-188(ra) # 80003ac2 <iunlock>
      end_op();
    80004b86:	00000097          	auipc	ra,0x0
    80004b8a:	8be080e7          	jalr	-1858(ra) # 80004444 <end_op>

      if(r != n1){
    80004b8e:	029a9563          	bne	s5,s1,80004bb8 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004b92:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b96:	0149da63          	bge	s3,s4,80004baa <filewrite+0xf0>
      int n1 = n - i;
    80004b9a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004b9e:	0004879b          	sext.w	a5,s1
    80004ba2:	f8fbdce3          	bge	s7,a5,80004b3a <filewrite+0x80>
    80004ba6:	84e2                	mv	s1,s8
    80004ba8:	bf49                	j	80004b3a <filewrite+0x80>
    80004baa:	74e2                	ld	s1,56(sp)
    80004bac:	6ae2                	ld	s5,24(sp)
    80004bae:	6ba2                	ld	s7,8(sp)
    80004bb0:	6c02                	ld	s8,0(sp)
    80004bb2:	a039                	j	80004bc0 <filewrite+0x106>
    int i = 0;
    80004bb4:	4981                	li	s3,0
    80004bb6:	a029                	j	80004bc0 <filewrite+0x106>
    80004bb8:	74e2                	ld	s1,56(sp)
    80004bba:	6ae2                	ld	s5,24(sp)
    80004bbc:	6ba2                	ld	s7,8(sp)
    80004bbe:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004bc0:	033a1e63          	bne	s4,s3,80004bfc <filewrite+0x142>
    80004bc4:	8552                	mv	a0,s4
    80004bc6:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004bc8:	60a6                	ld	ra,72(sp)
    80004bca:	6406                	ld	s0,64(sp)
    80004bcc:	7942                	ld	s2,48(sp)
    80004bce:	7a02                	ld	s4,32(sp)
    80004bd0:	6b42                	ld	s6,16(sp)
    80004bd2:	6161                	addi	sp,sp,80
    80004bd4:	8082                	ret
    80004bd6:	fc26                	sd	s1,56(sp)
    80004bd8:	f44e                	sd	s3,40(sp)
    80004bda:	ec56                	sd	s5,24(sp)
    80004bdc:	e45e                	sd	s7,8(sp)
    80004bde:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004be0:	00004517          	auipc	a0,0x4
    80004be4:	9c050513          	addi	a0,a0,-1600 # 800085a0 <etext+0x5a0>
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	978080e7          	jalr	-1672(ra) # 80000560 <panic>
    return -1;
    80004bf0:	557d                	li	a0,-1
}
    80004bf2:	8082                	ret
      return -1;
    80004bf4:	557d                	li	a0,-1
    80004bf6:	bfc9                	j	80004bc8 <filewrite+0x10e>
    80004bf8:	557d                	li	a0,-1
    80004bfa:	b7f9                	j	80004bc8 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004bfc:	557d                	li	a0,-1
    80004bfe:	79a2                	ld	s3,40(sp)
    80004c00:	b7e1                	j	80004bc8 <filewrite+0x10e>

0000000080004c02 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c02:	7179                	addi	sp,sp,-48
    80004c04:	f406                	sd	ra,40(sp)
    80004c06:	f022                	sd	s0,32(sp)
    80004c08:	ec26                	sd	s1,24(sp)
    80004c0a:	e052                	sd	s4,0(sp)
    80004c0c:	1800                	addi	s0,sp,48
    80004c0e:	84aa                	mv	s1,a0
    80004c10:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c12:	0005b023          	sd	zero,0(a1)
    80004c16:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c1a:	00000097          	auipc	ra,0x0
    80004c1e:	bbe080e7          	jalr	-1090(ra) # 800047d8 <filealloc>
    80004c22:	e088                	sd	a0,0(s1)
    80004c24:	cd49                	beqz	a0,80004cbe <pipealloc+0xbc>
    80004c26:	00000097          	auipc	ra,0x0
    80004c2a:	bb2080e7          	jalr	-1102(ra) # 800047d8 <filealloc>
    80004c2e:	00aa3023          	sd	a0,0(s4)
    80004c32:	c141                	beqz	a0,80004cb2 <pipealloc+0xb0>
    80004c34:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	f12080e7          	jalr	-238(ra) # 80000b48 <kalloc>
    80004c3e:	892a                	mv	s2,a0
    80004c40:	c13d                	beqz	a0,80004ca6 <pipealloc+0xa4>
    80004c42:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004c44:	4985                	li	s3,1
    80004c46:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c4a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c4e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c52:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c56:	00004597          	auipc	a1,0x4
    80004c5a:	95a58593          	addi	a1,a1,-1702 # 800085b0 <etext+0x5b0>
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	f4a080e7          	jalr	-182(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004c66:	609c                	ld	a5,0(s1)
    80004c68:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c6c:	609c                	ld	a5,0(s1)
    80004c6e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c72:	609c                	ld	a5,0(s1)
    80004c74:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c78:	609c                	ld	a5,0(s1)
    80004c7a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c7e:	000a3783          	ld	a5,0(s4)
    80004c82:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c86:	000a3783          	ld	a5,0(s4)
    80004c8a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c8e:	000a3783          	ld	a5,0(s4)
    80004c92:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c96:	000a3783          	ld	a5,0(s4)
    80004c9a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c9e:	4501                	li	a0,0
    80004ca0:	6942                	ld	s2,16(sp)
    80004ca2:	69a2                	ld	s3,8(sp)
    80004ca4:	a03d                	j	80004cd2 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ca6:	6088                	ld	a0,0(s1)
    80004ca8:	c119                	beqz	a0,80004cae <pipealloc+0xac>
    80004caa:	6942                	ld	s2,16(sp)
    80004cac:	a029                	j	80004cb6 <pipealloc+0xb4>
    80004cae:	6942                	ld	s2,16(sp)
    80004cb0:	a039                	j	80004cbe <pipealloc+0xbc>
    80004cb2:	6088                	ld	a0,0(s1)
    80004cb4:	c50d                	beqz	a0,80004cde <pipealloc+0xdc>
    fileclose(*f0);
    80004cb6:	00000097          	auipc	ra,0x0
    80004cba:	bde080e7          	jalr	-1058(ra) # 80004894 <fileclose>
  if(*f1)
    80004cbe:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cc2:	557d                	li	a0,-1
  if(*f1)
    80004cc4:	c799                	beqz	a5,80004cd2 <pipealloc+0xd0>
    fileclose(*f1);
    80004cc6:	853e                	mv	a0,a5
    80004cc8:	00000097          	auipc	ra,0x0
    80004ccc:	bcc080e7          	jalr	-1076(ra) # 80004894 <fileclose>
  return -1;
    80004cd0:	557d                	li	a0,-1
}
    80004cd2:	70a2                	ld	ra,40(sp)
    80004cd4:	7402                	ld	s0,32(sp)
    80004cd6:	64e2                	ld	s1,24(sp)
    80004cd8:	6a02                	ld	s4,0(sp)
    80004cda:	6145                	addi	sp,sp,48
    80004cdc:	8082                	ret
  return -1;
    80004cde:	557d                	li	a0,-1
    80004ce0:	bfcd                	j	80004cd2 <pipealloc+0xd0>

0000000080004ce2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ce2:	1101                	addi	sp,sp,-32
    80004ce4:	ec06                	sd	ra,24(sp)
    80004ce6:	e822                	sd	s0,16(sp)
    80004ce8:	e426                	sd	s1,8(sp)
    80004cea:	e04a                	sd	s2,0(sp)
    80004cec:	1000                	addi	s0,sp,32
    80004cee:	84aa                	mv	s1,a0
    80004cf0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004cf2:	ffffc097          	auipc	ra,0xffffc
    80004cf6:	f46080e7          	jalr	-186(ra) # 80000c38 <acquire>
  if(writable){
    80004cfa:	02090d63          	beqz	s2,80004d34 <pipeclose+0x52>
    pi->writeopen = 0;
    80004cfe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d02:	21848513          	addi	a0,s1,536
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	48c080e7          	jalr	1164(ra) # 80002192 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d0e:	2204b783          	ld	a5,544(s1)
    80004d12:	eb95                	bnez	a5,80004d46 <pipeclose+0x64>
    release(&pi->lock);
    80004d14:	8526                	mv	a0,s1
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	fd6080e7          	jalr	-42(ra) # 80000cec <release>
    kfree((char*)pi);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	d2a080e7          	jalr	-726(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004d28:	60e2                	ld	ra,24(sp)
    80004d2a:	6442                	ld	s0,16(sp)
    80004d2c:	64a2                	ld	s1,8(sp)
    80004d2e:	6902                	ld	s2,0(sp)
    80004d30:	6105                	addi	sp,sp,32
    80004d32:	8082                	ret
    pi->readopen = 0;
    80004d34:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d38:	21c48513          	addi	a0,s1,540
    80004d3c:	ffffd097          	auipc	ra,0xffffd
    80004d40:	456080e7          	jalr	1110(ra) # 80002192 <wakeup>
    80004d44:	b7e9                	j	80004d0e <pipeclose+0x2c>
    release(&pi->lock);
    80004d46:	8526                	mv	a0,s1
    80004d48:	ffffc097          	auipc	ra,0xffffc
    80004d4c:	fa4080e7          	jalr	-92(ra) # 80000cec <release>
}
    80004d50:	bfe1                	j	80004d28 <pipeclose+0x46>

0000000080004d52 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d52:	711d                	addi	sp,sp,-96
    80004d54:	ec86                	sd	ra,88(sp)
    80004d56:	e8a2                	sd	s0,80(sp)
    80004d58:	e4a6                	sd	s1,72(sp)
    80004d5a:	e0ca                	sd	s2,64(sp)
    80004d5c:	fc4e                	sd	s3,56(sp)
    80004d5e:	f852                	sd	s4,48(sp)
    80004d60:	f456                	sd	s5,40(sp)
    80004d62:	1080                	addi	s0,sp,96
    80004d64:	84aa                	mv	s1,a0
    80004d66:	8aae                	mv	s5,a1
    80004d68:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d6a:	ffffd097          	auipc	ra,0xffffd
    80004d6e:	ce0080e7          	jalr	-800(ra) # 80001a4a <myproc>
    80004d72:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	ec2080e7          	jalr	-318(ra) # 80000c38 <acquire>
  while(i < n){
    80004d7e:	0d405863          	blez	s4,80004e4e <pipewrite+0xfc>
    80004d82:	f05a                	sd	s6,32(sp)
    80004d84:	ec5e                	sd	s7,24(sp)
    80004d86:	e862                	sd	s8,16(sp)
  int i = 0;
    80004d88:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d8a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d8c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d90:	21c48b93          	addi	s7,s1,540
    80004d94:	a089                	j	80004dd6 <pipewrite+0x84>
      release(&pi->lock);
    80004d96:	8526                	mv	a0,s1
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	f54080e7          	jalr	-172(ra) # 80000cec <release>
      return -1;
    80004da0:	597d                	li	s2,-1
    80004da2:	7b02                	ld	s6,32(sp)
    80004da4:	6be2                	ld	s7,24(sp)
    80004da6:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004da8:	854a                	mv	a0,s2
    80004daa:	60e6                	ld	ra,88(sp)
    80004dac:	6446                	ld	s0,80(sp)
    80004dae:	64a6                	ld	s1,72(sp)
    80004db0:	6906                	ld	s2,64(sp)
    80004db2:	79e2                	ld	s3,56(sp)
    80004db4:	7a42                	ld	s4,48(sp)
    80004db6:	7aa2                	ld	s5,40(sp)
    80004db8:	6125                	addi	sp,sp,96
    80004dba:	8082                	ret
      wakeup(&pi->nread);
    80004dbc:	8562                	mv	a0,s8
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	3d4080e7          	jalr	980(ra) # 80002192 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004dc6:	85a6                	mv	a1,s1
    80004dc8:	855e                	mv	a0,s7
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	364080e7          	jalr	868(ra) # 8000212e <sleep>
  while(i < n){
    80004dd2:	05495f63          	bge	s2,s4,80004e30 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004dd6:	2204a783          	lw	a5,544(s1)
    80004dda:	dfd5                	beqz	a5,80004d96 <pipewrite+0x44>
    80004ddc:	854e                	mv	a0,s3
    80004dde:	ffffd097          	auipc	ra,0xffffd
    80004de2:	604080e7          	jalr	1540(ra) # 800023e2 <killed>
    80004de6:	f945                	bnez	a0,80004d96 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004de8:	2184a783          	lw	a5,536(s1)
    80004dec:	21c4a703          	lw	a4,540(s1)
    80004df0:	2007879b          	addiw	a5,a5,512
    80004df4:	fcf704e3          	beq	a4,a5,80004dbc <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004df8:	4685                	li	a3,1
    80004dfa:	01590633          	add	a2,s2,s5
    80004dfe:	faf40593          	addi	a1,s0,-81
    80004e02:	0509b503          	ld	a0,80(s3)
    80004e06:	ffffd097          	auipc	ra,0xffffd
    80004e0a:	968080e7          	jalr	-1688(ra) # 8000176e <copyin>
    80004e0e:	05650263          	beq	a0,s6,80004e52 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e12:	21c4a783          	lw	a5,540(s1)
    80004e16:	0017871b          	addiw	a4,a5,1
    80004e1a:	20e4ae23          	sw	a4,540(s1)
    80004e1e:	1ff7f793          	andi	a5,a5,511
    80004e22:	97a6                	add	a5,a5,s1
    80004e24:	faf44703          	lbu	a4,-81(s0)
    80004e28:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e2c:	2905                	addiw	s2,s2,1
    80004e2e:	b755                	j	80004dd2 <pipewrite+0x80>
    80004e30:	7b02                	ld	s6,32(sp)
    80004e32:	6be2                	ld	s7,24(sp)
    80004e34:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004e36:	21848513          	addi	a0,s1,536
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	358080e7          	jalr	856(ra) # 80002192 <wakeup>
  release(&pi->lock);
    80004e42:	8526                	mv	a0,s1
    80004e44:	ffffc097          	auipc	ra,0xffffc
    80004e48:	ea8080e7          	jalr	-344(ra) # 80000cec <release>
  return i;
    80004e4c:	bfb1                	j	80004da8 <pipewrite+0x56>
  int i = 0;
    80004e4e:	4901                	li	s2,0
    80004e50:	b7dd                	j	80004e36 <pipewrite+0xe4>
    80004e52:	7b02                	ld	s6,32(sp)
    80004e54:	6be2                	ld	s7,24(sp)
    80004e56:	6c42                	ld	s8,16(sp)
    80004e58:	bff9                	j	80004e36 <pipewrite+0xe4>

0000000080004e5a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e5a:	715d                	addi	sp,sp,-80
    80004e5c:	e486                	sd	ra,72(sp)
    80004e5e:	e0a2                	sd	s0,64(sp)
    80004e60:	fc26                	sd	s1,56(sp)
    80004e62:	f84a                	sd	s2,48(sp)
    80004e64:	f44e                	sd	s3,40(sp)
    80004e66:	f052                	sd	s4,32(sp)
    80004e68:	ec56                	sd	s5,24(sp)
    80004e6a:	0880                	addi	s0,sp,80
    80004e6c:	84aa                	mv	s1,a0
    80004e6e:	892e                	mv	s2,a1
    80004e70:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e72:	ffffd097          	auipc	ra,0xffffd
    80004e76:	bd8080e7          	jalr	-1064(ra) # 80001a4a <myproc>
    80004e7a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e7c:	8526                	mv	a0,s1
    80004e7e:	ffffc097          	auipc	ra,0xffffc
    80004e82:	dba080e7          	jalr	-582(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e86:	2184a703          	lw	a4,536(s1)
    80004e8a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e8e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e92:	02f71963          	bne	a4,a5,80004ec4 <piperead+0x6a>
    80004e96:	2244a783          	lw	a5,548(s1)
    80004e9a:	cf95                	beqz	a5,80004ed6 <piperead+0x7c>
    if(killed(pr)){
    80004e9c:	8552                	mv	a0,s4
    80004e9e:	ffffd097          	auipc	ra,0xffffd
    80004ea2:	544080e7          	jalr	1348(ra) # 800023e2 <killed>
    80004ea6:	e10d                	bnez	a0,80004ec8 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ea8:	85a6                	mv	a1,s1
    80004eaa:	854e                	mv	a0,s3
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	282080e7          	jalr	642(ra) # 8000212e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004eb4:	2184a703          	lw	a4,536(s1)
    80004eb8:	21c4a783          	lw	a5,540(s1)
    80004ebc:	fcf70de3          	beq	a4,a5,80004e96 <piperead+0x3c>
    80004ec0:	e85a                	sd	s6,16(sp)
    80004ec2:	a819                	j	80004ed8 <piperead+0x7e>
    80004ec4:	e85a                	sd	s6,16(sp)
    80004ec6:	a809                	j	80004ed8 <piperead+0x7e>
      release(&pi->lock);
    80004ec8:	8526                	mv	a0,s1
    80004eca:	ffffc097          	auipc	ra,0xffffc
    80004ece:	e22080e7          	jalr	-478(ra) # 80000cec <release>
      return -1;
    80004ed2:	59fd                	li	s3,-1
    80004ed4:	a0a5                	j	80004f3c <piperead+0xe2>
    80004ed6:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ed8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eda:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004edc:	05505463          	blez	s5,80004f24 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004ee0:	2184a783          	lw	a5,536(s1)
    80004ee4:	21c4a703          	lw	a4,540(s1)
    80004ee8:	02f70e63          	beq	a4,a5,80004f24 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004eec:	0017871b          	addiw	a4,a5,1
    80004ef0:	20e4ac23          	sw	a4,536(s1)
    80004ef4:	1ff7f793          	andi	a5,a5,511
    80004ef8:	97a6                	add	a5,a5,s1
    80004efa:	0187c783          	lbu	a5,24(a5)
    80004efe:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f02:	4685                	li	a3,1
    80004f04:	fbf40613          	addi	a2,s0,-65
    80004f08:	85ca                	mv	a1,s2
    80004f0a:	050a3503          	ld	a0,80(s4)
    80004f0e:	ffffc097          	auipc	ra,0xffffc
    80004f12:	7d4080e7          	jalr	2004(ra) # 800016e2 <copyout>
    80004f16:	01650763          	beq	a0,s6,80004f24 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f1a:	2985                	addiw	s3,s3,1
    80004f1c:	0905                	addi	s2,s2,1
    80004f1e:	fd3a91e3          	bne	s5,s3,80004ee0 <piperead+0x86>
    80004f22:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f24:	21c48513          	addi	a0,s1,540
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	26a080e7          	jalr	618(ra) # 80002192 <wakeup>
  release(&pi->lock);
    80004f30:	8526                	mv	a0,s1
    80004f32:	ffffc097          	auipc	ra,0xffffc
    80004f36:	dba080e7          	jalr	-582(ra) # 80000cec <release>
    80004f3a:	6b42                	ld	s6,16(sp)
  return i;
}
    80004f3c:	854e                	mv	a0,s3
    80004f3e:	60a6                	ld	ra,72(sp)
    80004f40:	6406                	ld	s0,64(sp)
    80004f42:	74e2                	ld	s1,56(sp)
    80004f44:	7942                	ld	s2,48(sp)
    80004f46:	79a2                	ld	s3,40(sp)
    80004f48:	7a02                	ld	s4,32(sp)
    80004f4a:	6ae2                	ld	s5,24(sp)
    80004f4c:	6161                	addi	sp,sp,80
    80004f4e:	8082                	ret

0000000080004f50 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004f50:	1141                	addi	sp,sp,-16
    80004f52:	e422                	sd	s0,8(sp)
    80004f54:	0800                	addi	s0,sp,16
    80004f56:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f58:	8905                	andi	a0,a0,1
    80004f5a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004f5c:	8b89                	andi	a5,a5,2
    80004f5e:	c399                	beqz	a5,80004f64 <flags2perm+0x14>
      perm |= PTE_W;
    80004f60:	00456513          	ori	a0,a0,4
    return perm;
}
    80004f64:	6422                	ld	s0,8(sp)
    80004f66:	0141                	addi	sp,sp,16
    80004f68:	8082                	ret

0000000080004f6a <exec>:

int
exec(char *path, char **argv)
{
    80004f6a:	df010113          	addi	sp,sp,-528
    80004f6e:	20113423          	sd	ra,520(sp)
    80004f72:	20813023          	sd	s0,512(sp)
    80004f76:	ffa6                	sd	s1,504(sp)
    80004f78:	fbca                	sd	s2,496(sp)
    80004f7a:	0c00                	addi	s0,sp,528
    80004f7c:	892a                	mv	s2,a0
    80004f7e:	dea43c23          	sd	a0,-520(s0)
    80004f82:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f86:	ffffd097          	auipc	ra,0xffffd
    80004f8a:	ac4080e7          	jalr	-1340(ra) # 80001a4a <myproc>
    80004f8e:	84aa                	mv	s1,a0

  begin_op();
    80004f90:	fffff097          	auipc	ra,0xfffff
    80004f94:	43a080e7          	jalr	1082(ra) # 800043ca <begin_op>

  if((ip = namei(path)) == 0){
    80004f98:	854a                	mv	a0,s2
    80004f9a:	fffff097          	auipc	ra,0xfffff
    80004f9e:	230080e7          	jalr	560(ra) # 800041ca <namei>
    80004fa2:	c135                	beqz	a0,80005006 <exec+0x9c>
    80004fa4:	f3d2                	sd	s4,480(sp)
    80004fa6:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004fa8:	fffff097          	auipc	ra,0xfffff
    80004fac:	a54080e7          	jalr	-1452(ra) # 800039fc <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004fb0:	04000713          	li	a4,64
    80004fb4:	4681                	li	a3,0
    80004fb6:	e5040613          	addi	a2,s0,-432
    80004fba:	4581                	li	a1,0
    80004fbc:	8552                	mv	a0,s4
    80004fbe:	fffff097          	auipc	ra,0xfffff
    80004fc2:	cf6080e7          	jalr	-778(ra) # 80003cb4 <readi>
    80004fc6:	04000793          	li	a5,64
    80004fca:	00f51a63          	bne	a0,a5,80004fde <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004fce:	e5042703          	lw	a4,-432(s0)
    80004fd2:	464c47b7          	lui	a5,0x464c4
    80004fd6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fda:	02f70c63          	beq	a4,a5,80005012 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004fde:	8552                	mv	a0,s4
    80004fe0:	fffff097          	auipc	ra,0xfffff
    80004fe4:	c82080e7          	jalr	-894(ra) # 80003c62 <iunlockput>
    end_op();
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	45c080e7          	jalr	1116(ra) # 80004444 <end_op>
  }
  return -1;
    80004ff0:	557d                	li	a0,-1
    80004ff2:	7a1e                	ld	s4,480(sp)
}
    80004ff4:	20813083          	ld	ra,520(sp)
    80004ff8:	20013403          	ld	s0,512(sp)
    80004ffc:	74fe                	ld	s1,504(sp)
    80004ffe:	795e                	ld	s2,496(sp)
    80005000:	21010113          	addi	sp,sp,528
    80005004:	8082                	ret
    end_op();
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	43e080e7          	jalr	1086(ra) # 80004444 <end_op>
    return -1;
    8000500e:	557d                	li	a0,-1
    80005010:	b7d5                	j	80004ff4 <exec+0x8a>
    80005012:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005014:	8526                	mv	a0,s1
    80005016:	ffffd097          	auipc	ra,0xffffd
    8000501a:	af8080e7          	jalr	-1288(ra) # 80001b0e <proc_pagetable>
    8000501e:	8b2a                	mv	s6,a0
    80005020:	30050f63          	beqz	a0,8000533e <exec+0x3d4>
    80005024:	f7ce                	sd	s3,488(sp)
    80005026:	efd6                	sd	s5,472(sp)
    80005028:	e7de                	sd	s7,456(sp)
    8000502a:	e3e2                	sd	s8,448(sp)
    8000502c:	ff66                	sd	s9,440(sp)
    8000502e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005030:	e7042d03          	lw	s10,-400(s0)
    80005034:	e8845783          	lhu	a5,-376(s0)
    80005038:	14078d63          	beqz	a5,80005192 <exec+0x228>
    8000503c:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000503e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005040:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005042:	6c85                	lui	s9,0x1
    80005044:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005048:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000504c:	6a85                	lui	s5,0x1
    8000504e:	a0b5                	j	800050ba <exec+0x150>
      panic("loadseg: address should exist");
    80005050:	00003517          	auipc	a0,0x3
    80005054:	56850513          	addi	a0,a0,1384 # 800085b8 <etext+0x5b8>
    80005058:	ffffb097          	auipc	ra,0xffffb
    8000505c:	508080e7          	jalr	1288(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005060:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005062:	8726                	mv	a4,s1
    80005064:	012c06bb          	addw	a3,s8,s2
    80005068:	4581                	li	a1,0
    8000506a:	8552                	mv	a0,s4
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	c48080e7          	jalr	-952(ra) # 80003cb4 <readi>
    80005074:	2501                	sext.w	a0,a0
    80005076:	28a49863          	bne	s1,a0,80005306 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    8000507a:	012a893b          	addw	s2,s5,s2
    8000507e:	03397563          	bgeu	s2,s3,800050a8 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005082:	02091593          	slli	a1,s2,0x20
    80005086:	9181                	srli	a1,a1,0x20
    80005088:	95de                	add	a1,a1,s7
    8000508a:	855a                	mv	a0,s6
    8000508c:	ffffc097          	auipc	ra,0xffffc
    80005090:	02a080e7          	jalr	42(ra) # 800010b6 <walkaddr>
    80005094:	862a                	mv	a2,a0
    if(pa == 0)
    80005096:	dd4d                	beqz	a0,80005050 <exec+0xe6>
    if(sz - i < PGSIZE)
    80005098:	412984bb          	subw	s1,s3,s2
    8000509c:	0004879b          	sext.w	a5,s1
    800050a0:	fcfcf0e3          	bgeu	s9,a5,80005060 <exec+0xf6>
    800050a4:	84d6                	mv	s1,s5
    800050a6:	bf6d                	j	80005060 <exec+0xf6>
    sz = sz1;
    800050a8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050ac:	2d85                	addiw	s11,s11,1
    800050ae:	038d0d1b          	addiw	s10,s10,56
    800050b2:	e8845783          	lhu	a5,-376(s0)
    800050b6:	08fdd663          	bge	s11,a5,80005142 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050ba:	2d01                	sext.w	s10,s10
    800050bc:	03800713          	li	a4,56
    800050c0:	86ea                	mv	a3,s10
    800050c2:	e1840613          	addi	a2,s0,-488
    800050c6:	4581                	li	a1,0
    800050c8:	8552                	mv	a0,s4
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	bea080e7          	jalr	-1046(ra) # 80003cb4 <readi>
    800050d2:	03800793          	li	a5,56
    800050d6:	20f51063          	bne	a0,a5,800052d6 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    800050da:	e1842783          	lw	a5,-488(s0)
    800050de:	4705                	li	a4,1
    800050e0:	fce796e3          	bne	a5,a4,800050ac <exec+0x142>
    if(ph.memsz < ph.filesz)
    800050e4:	e4043483          	ld	s1,-448(s0)
    800050e8:	e3843783          	ld	a5,-456(s0)
    800050ec:	1ef4e963          	bltu	s1,a5,800052de <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050f0:	e2843783          	ld	a5,-472(s0)
    800050f4:	94be                	add	s1,s1,a5
    800050f6:	1ef4e863          	bltu	s1,a5,800052e6 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    800050fa:	df043703          	ld	a4,-528(s0)
    800050fe:	8ff9                	and	a5,a5,a4
    80005100:	1e079763          	bnez	a5,800052ee <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005104:	e1c42503          	lw	a0,-484(s0)
    80005108:	00000097          	auipc	ra,0x0
    8000510c:	e48080e7          	jalr	-440(ra) # 80004f50 <flags2perm>
    80005110:	86aa                	mv	a3,a0
    80005112:	8626                	mv	a2,s1
    80005114:	85ca                	mv	a1,s2
    80005116:	855a                	mv	a0,s6
    80005118:	ffffc097          	auipc	ra,0xffffc
    8000511c:	362080e7          	jalr	866(ra) # 8000147a <uvmalloc>
    80005120:	e0a43423          	sd	a0,-504(s0)
    80005124:	1c050963          	beqz	a0,800052f6 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005128:	e2843b83          	ld	s7,-472(s0)
    8000512c:	e2042c03          	lw	s8,-480(s0)
    80005130:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005134:	00098463          	beqz	s3,8000513c <exec+0x1d2>
    80005138:	4901                	li	s2,0
    8000513a:	b7a1                	j	80005082 <exec+0x118>
    sz = sz1;
    8000513c:	e0843903          	ld	s2,-504(s0)
    80005140:	b7b5                	j	800050ac <exec+0x142>
    80005142:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005144:	8552                	mv	a0,s4
    80005146:	fffff097          	auipc	ra,0xfffff
    8000514a:	b1c080e7          	jalr	-1252(ra) # 80003c62 <iunlockput>
  end_op();
    8000514e:	fffff097          	auipc	ra,0xfffff
    80005152:	2f6080e7          	jalr	758(ra) # 80004444 <end_op>
  p = myproc();
    80005156:	ffffd097          	auipc	ra,0xffffd
    8000515a:	8f4080e7          	jalr	-1804(ra) # 80001a4a <myproc>
    8000515e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005160:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005164:	6985                	lui	s3,0x1
    80005166:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005168:	99ca                	add	s3,s3,s2
    8000516a:	77fd                	lui	a5,0xfffff
    8000516c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005170:	4691                	li	a3,4
    80005172:	6609                	lui	a2,0x2
    80005174:	964e                	add	a2,a2,s3
    80005176:	85ce                	mv	a1,s3
    80005178:	855a                	mv	a0,s6
    8000517a:	ffffc097          	auipc	ra,0xffffc
    8000517e:	300080e7          	jalr	768(ra) # 8000147a <uvmalloc>
    80005182:	892a                	mv	s2,a0
    80005184:	e0a43423          	sd	a0,-504(s0)
    80005188:	e519                	bnez	a0,80005196 <exec+0x22c>
  if(pagetable)
    8000518a:	e1343423          	sd	s3,-504(s0)
    8000518e:	4a01                	li	s4,0
    80005190:	aaa5                	j	80005308 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005192:	4901                	li	s2,0
    80005194:	bf45                	j	80005144 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005196:	75f9                	lui	a1,0xffffe
    80005198:	95aa                	add	a1,a1,a0
    8000519a:	855a                	mv	a0,s6
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	514080e7          	jalr	1300(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    800051a4:	7bfd                	lui	s7,0xfffff
    800051a6:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800051a8:	e0043783          	ld	a5,-512(s0)
    800051ac:	6388                	ld	a0,0(a5)
    800051ae:	c52d                	beqz	a0,80005218 <exec+0x2ae>
    800051b0:	e9040993          	addi	s3,s0,-368
    800051b4:	f9040c13          	addi	s8,s0,-112
    800051b8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051ba:	ffffc097          	auipc	ra,0xffffc
    800051be:	cee080e7          	jalr	-786(ra) # 80000ea8 <strlen>
    800051c2:	0015079b          	addiw	a5,a0,1
    800051c6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051ca:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800051ce:	13796863          	bltu	s2,s7,800052fe <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051d2:	e0043d03          	ld	s10,-512(s0)
    800051d6:	000d3a03          	ld	s4,0(s10)
    800051da:	8552                	mv	a0,s4
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	ccc080e7          	jalr	-820(ra) # 80000ea8 <strlen>
    800051e4:	0015069b          	addiw	a3,a0,1
    800051e8:	8652                	mv	a2,s4
    800051ea:	85ca                	mv	a1,s2
    800051ec:	855a                	mv	a0,s6
    800051ee:	ffffc097          	auipc	ra,0xffffc
    800051f2:	4f4080e7          	jalr	1268(ra) # 800016e2 <copyout>
    800051f6:	10054663          	bltz	a0,80005302 <exec+0x398>
    ustack[argc] = sp;
    800051fa:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051fe:	0485                	addi	s1,s1,1
    80005200:	008d0793          	addi	a5,s10,8
    80005204:	e0f43023          	sd	a5,-512(s0)
    80005208:	008d3503          	ld	a0,8(s10)
    8000520c:	c909                	beqz	a0,8000521e <exec+0x2b4>
    if(argc >= MAXARG)
    8000520e:	09a1                	addi	s3,s3,8
    80005210:	fb8995e3          	bne	s3,s8,800051ba <exec+0x250>
  ip = 0;
    80005214:	4a01                	li	s4,0
    80005216:	a8cd                	j	80005308 <exec+0x39e>
  sp = sz;
    80005218:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000521c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000521e:	00349793          	slli	a5,s1,0x3
    80005222:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd73c0>
    80005226:	97a2                	add	a5,a5,s0
    80005228:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000522c:	00148693          	addi	a3,s1,1
    80005230:	068e                	slli	a3,a3,0x3
    80005232:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005236:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000523a:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000523e:	f57966e3          	bltu	s2,s7,8000518a <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005242:	e9040613          	addi	a2,s0,-368
    80005246:	85ca                	mv	a1,s2
    80005248:	855a                	mv	a0,s6
    8000524a:	ffffc097          	auipc	ra,0xffffc
    8000524e:	498080e7          	jalr	1176(ra) # 800016e2 <copyout>
    80005252:	0e054863          	bltz	a0,80005342 <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005256:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000525a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000525e:	df843783          	ld	a5,-520(s0)
    80005262:	0007c703          	lbu	a4,0(a5)
    80005266:	cf11                	beqz	a4,80005282 <exec+0x318>
    80005268:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000526a:	02f00693          	li	a3,47
    8000526e:	a039                	j	8000527c <exec+0x312>
      last = s+1;
    80005270:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005274:	0785                	addi	a5,a5,1
    80005276:	fff7c703          	lbu	a4,-1(a5)
    8000527a:	c701                	beqz	a4,80005282 <exec+0x318>
    if(*s == '/')
    8000527c:	fed71ce3          	bne	a4,a3,80005274 <exec+0x30a>
    80005280:	bfc5                	j	80005270 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005282:	4641                	li	a2,16
    80005284:	df843583          	ld	a1,-520(s0)
    80005288:	158a8513          	addi	a0,s5,344
    8000528c:	ffffc097          	auipc	ra,0xffffc
    80005290:	bea080e7          	jalr	-1046(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    80005294:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005298:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000529c:	e0843783          	ld	a5,-504(s0)
    800052a0:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052a4:	058ab783          	ld	a5,88(s5)
    800052a8:	e6843703          	ld	a4,-408(s0)
    800052ac:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052ae:	058ab783          	ld	a5,88(s5)
    800052b2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052b6:	85e6                	mv	a1,s9
    800052b8:	ffffd097          	auipc	ra,0xffffd
    800052bc:	8f2080e7          	jalr	-1806(ra) # 80001baa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052c0:	0004851b          	sext.w	a0,s1
    800052c4:	79be                	ld	s3,488(sp)
    800052c6:	7a1e                	ld	s4,480(sp)
    800052c8:	6afe                	ld	s5,472(sp)
    800052ca:	6b5e                	ld	s6,464(sp)
    800052cc:	6bbe                	ld	s7,456(sp)
    800052ce:	6c1e                	ld	s8,448(sp)
    800052d0:	7cfa                	ld	s9,440(sp)
    800052d2:	7d5a                	ld	s10,432(sp)
    800052d4:	b305                	j	80004ff4 <exec+0x8a>
    800052d6:	e1243423          	sd	s2,-504(s0)
    800052da:	7dba                	ld	s11,424(sp)
    800052dc:	a035                	j	80005308 <exec+0x39e>
    800052de:	e1243423          	sd	s2,-504(s0)
    800052e2:	7dba                	ld	s11,424(sp)
    800052e4:	a015                	j	80005308 <exec+0x39e>
    800052e6:	e1243423          	sd	s2,-504(s0)
    800052ea:	7dba                	ld	s11,424(sp)
    800052ec:	a831                	j	80005308 <exec+0x39e>
    800052ee:	e1243423          	sd	s2,-504(s0)
    800052f2:	7dba                	ld	s11,424(sp)
    800052f4:	a811                	j	80005308 <exec+0x39e>
    800052f6:	e1243423          	sd	s2,-504(s0)
    800052fa:	7dba                	ld	s11,424(sp)
    800052fc:	a031                	j	80005308 <exec+0x39e>
  ip = 0;
    800052fe:	4a01                	li	s4,0
    80005300:	a021                	j	80005308 <exec+0x39e>
    80005302:	4a01                	li	s4,0
  if(pagetable)
    80005304:	a011                	j	80005308 <exec+0x39e>
    80005306:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005308:	e0843583          	ld	a1,-504(s0)
    8000530c:	855a                	mv	a0,s6
    8000530e:	ffffd097          	auipc	ra,0xffffd
    80005312:	89c080e7          	jalr	-1892(ra) # 80001baa <proc_freepagetable>
  return -1;
    80005316:	557d                	li	a0,-1
  if(ip){
    80005318:	000a1b63          	bnez	s4,8000532e <exec+0x3c4>
    8000531c:	79be                	ld	s3,488(sp)
    8000531e:	7a1e                	ld	s4,480(sp)
    80005320:	6afe                	ld	s5,472(sp)
    80005322:	6b5e                	ld	s6,464(sp)
    80005324:	6bbe                	ld	s7,456(sp)
    80005326:	6c1e                	ld	s8,448(sp)
    80005328:	7cfa                	ld	s9,440(sp)
    8000532a:	7d5a                	ld	s10,432(sp)
    8000532c:	b1e1                	j	80004ff4 <exec+0x8a>
    8000532e:	79be                	ld	s3,488(sp)
    80005330:	6afe                	ld	s5,472(sp)
    80005332:	6b5e                	ld	s6,464(sp)
    80005334:	6bbe                	ld	s7,456(sp)
    80005336:	6c1e                	ld	s8,448(sp)
    80005338:	7cfa                	ld	s9,440(sp)
    8000533a:	7d5a                	ld	s10,432(sp)
    8000533c:	b14d                	j	80004fde <exec+0x74>
    8000533e:	6b5e                	ld	s6,464(sp)
    80005340:	b979                	j	80004fde <exec+0x74>
  sz = sz1;
    80005342:	e0843983          	ld	s3,-504(s0)
    80005346:	b591                	j	8000518a <exec+0x220>

0000000080005348 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005348:	7179                	addi	sp,sp,-48
    8000534a:	f406                	sd	ra,40(sp)
    8000534c:	f022                	sd	s0,32(sp)
    8000534e:	ec26                	sd	s1,24(sp)
    80005350:	e84a                	sd	s2,16(sp)
    80005352:	1800                	addi	s0,sp,48
    80005354:	892e                	mv	s2,a1
    80005356:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005358:	fdc40593          	addi	a1,s0,-36
    8000535c:	ffffe097          	auipc	ra,0xffffe
    80005360:	a0c080e7          	jalr	-1524(ra) # 80002d68 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005364:	fdc42703          	lw	a4,-36(s0)
    80005368:	47bd                	li	a5,15
    8000536a:	02e7eb63          	bltu	a5,a4,800053a0 <argfd+0x58>
    8000536e:	ffffc097          	auipc	ra,0xffffc
    80005372:	6dc080e7          	jalr	1756(ra) # 80001a4a <myproc>
    80005376:	fdc42703          	lw	a4,-36(s0)
    8000537a:	01a70793          	addi	a5,a4,26
    8000537e:	078e                	slli	a5,a5,0x3
    80005380:	953e                	add	a0,a0,a5
    80005382:	611c                	ld	a5,0(a0)
    80005384:	c385                	beqz	a5,800053a4 <argfd+0x5c>
    return -1;
  if(pfd)
    80005386:	00090463          	beqz	s2,8000538e <argfd+0x46>
    *pfd = fd;
    8000538a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000538e:	4501                	li	a0,0
  if(pf)
    80005390:	c091                	beqz	s1,80005394 <argfd+0x4c>
    *pf = f;
    80005392:	e09c                	sd	a5,0(s1)
}
    80005394:	70a2                	ld	ra,40(sp)
    80005396:	7402                	ld	s0,32(sp)
    80005398:	64e2                	ld	s1,24(sp)
    8000539a:	6942                	ld	s2,16(sp)
    8000539c:	6145                	addi	sp,sp,48
    8000539e:	8082                	ret
    return -1;
    800053a0:	557d                	li	a0,-1
    800053a2:	bfcd                	j	80005394 <argfd+0x4c>
    800053a4:	557d                	li	a0,-1
    800053a6:	b7fd                	j	80005394 <argfd+0x4c>

00000000800053a8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053a8:	1101                	addi	sp,sp,-32
    800053aa:	ec06                	sd	ra,24(sp)
    800053ac:	e822                	sd	s0,16(sp)
    800053ae:	e426                	sd	s1,8(sp)
    800053b0:	1000                	addi	s0,sp,32
    800053b2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053b4:	ffffc097          	auipc	ra,0xffffc
    800053b8:	696080e7          	jalr	1686(ra) # 80001a4a <myproc>
    800053bc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053be:	0d050793          	addi	a5,a0,208
    800053c2:	4501                	li	a0,0
    800053c4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053c6:	6398                	ld	a4,0(a5)
    800053c8:	cb19                	beqz	a4,800053de <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053ca:	2505                	addiw	a0,a0,1
    800053cc:	07a1                	addi	a5,a5,8
    800053ce:	fed51ce3          	bne	a0,a3,800053c6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053d2:	557d                	li	a0,-1
}
    800053d4:	60e2                	ld	ra,24(sp)
    800053d6:	6442                	ld	s0,16(sp)
    800053d8:	64a2                	ld	s1,8(sp)
    800053da:	6105                	addi	sp,sp,32
    800053dc:	8082                	ret
      p->ofile[fd] = f;
    800053de:	01a50793          	addi	a5,a0,26
    800053e2:	078e                	slli	a5,a5,0x3
    800053e4:	963e                	add	a2,a2,a5
    800053e6:	e204                	sd	s1,0(a2)
      return fd;
    800053e8:	b7f5                	j	800053d4 <fdalloc+0x2c>

00000000800053ea <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053ea:	715d                	addi	sp,sp,-80
    800053ec:	e486                	sd	ra,72(sp)
    800053ee:	e0a2                	sd	s0,64(sp)
    800053f0:	fc26                	sd	s1,56(sp)
    800053f2:	f84a                	sd	s2,48(sp)
    800053f4:	f44e                	sd	s3,40(sp)
    800053f6:	ec56                	sd	s5,24(sp)
    800053f8:	e85a                	sd	s6,16(sp)
    800053fa:	0880                	addi	s0,sp,80
    800053fc:	8b2e                	mv	s6,a1
    800053fe:	89b2                	mv	s3,a2
    80005400:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005402:	fb040593          	addi	a1,s0,-80
    80005406:	fffff097          	auipc	ra,0xfffff
    8000540a:	de2080e7          	jalr	-542(ra) # 800041e8 <nameiparent>
    8000540e:	84aa                	mv	s1,a0
    80005410:	14050e63          	beqz	a0,8000556c <create+0x182>
    return 0;

  ilock(dp);
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	5e8080e7          	jalr	1512(ra) # 800039fc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000541c:	4601                	li	a2,0
    8000541e:	fb040593          	addi	a1,s0,-80
    80005422:	8526                	mv	a0,s1
    80005424:	fffff097          	auipc	ra,0xfffff
    80005428:	ae4080e7          	jalr	-1308(ra) # 80003f08 <dirlookup>
    8000542c:	8aaa                	mv	s5,a0
    8000542e:	c539                	beqz	a0,8000547c <create+0x92>
    iunlockput(dp);
    80005430:	8526                	mv	a0,s1
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	830080e7          	jalr	-2000(ra) # 80003c62 <iunlockput>
    ilock(ip);
    8000543a:	8556                	mv	a0,s5
    8000543c:	ffffe097          	auipc	ra,0xffffe
    80005440:	5c0080e7          	jalr	1472(ra) # 800039fc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005444:	4789                	li	a5,2
    80005446:	02fb1463          	bne	s6,a5,8000546e <create+0x84>
    8000544a:	044ad783          	lhu	a5,68(s5)
    8000544e:	37f9                	addiw	a5,a5,-2
    80005450:	17c2                	slli	a5,a5,0x30
    80005452:	93c1                	srli	a5,a5,0x30
    80005454:	4705                	li	a4,1
    80005456:	00f76c63          	bltu	a4,a5,8000546e <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000545a:	8556                	mv	a0,s5
    8000545c:	60a6                	ld	ra,72(sp)
    8000545e:	6406                	ld	s0,64(sp)
    80005460:	74e2                	ld	s1,56(sp)
    80005462:	7942                	ld	s2,48(sp)
    80005464:	79a2                	ld	s3,40(sp)
    80005466:	6ae2                	ld	s5,24(sp)
    80005468:	6b42                	ld	s6,16(sp)
    8000546a:	6161                	addi	sp,sp,80
    8000546c:	8082                	ret
    iunlockput(ip);
    8000546e:	8556                	mv	a0,s5
    80005470:	ffffe097          	auipc	ra,0xffffe
    80005474:	7f2080e7          	jalr	2034(ra) # 80003c62 <iunlockput>
    return 0;
    80005478:	4a81                	li	s5,0
    8000547a:	b7c5                	j	8000545a <create+0x70>
    8000547c:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000547e:	85da                	mv	a1,s6
    80005480:	4088                	lw	a0,0(s1)
    80005482:	ffffe097          	auipc	ra,0xffffe
    80005486:	3d6080e7          	jalr	982(ra) # 80003858 <ialloc>
    8000548a:	8a2a                	mv	s4,a0
    8000548c:	c531                	beqz	a0,800054d8 <create+0xee>
  ilock(ip);
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	56e080e7          	jalr	1390(ra) # 800039fc <ilock>
  ip->major = major;
    80005496:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000549a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000549e:	4905                	li	s2,1
    800054a0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800054a4:	8552                	mv	a0,s4
    800054a6:	ffffe097          	auipc	ra,0xffffe
    800054aa:	48a080e7          	jalr	1162(ra) # 80003930 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054ae:	032b0d63          	beq	s6,s2,800054e8 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800054b2:	004a2603          	lw	a2,4(s4)
    800054b6:	fb040593          	addi	a1,s0,-80
    800054ba:	8526                	mv	a0,s1
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	c5c080e7          	jalr	-932(ra) # 80004118 <dirlink>
    800054c4:	08054163          	bltz	a0,80005546 <create+0x15c>
  iunlockput(dp);
    800054c8:	8526                	mv	a0,s1
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	798080e7          	jalr	1944(ra) # 80003c62 <iunlockput>
  return ip;
    800054d2:	8ad2                	mv	s5,s4
    800054d4:	7a02                	ld	s4,32(sp)
    800054d6:	b751                	j	8000545a <create+0x70>
    iunlockput(dp);
    800054d8:	8526                	mv	a0,s1
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	788080e7          	jalr	1928(ra) # 80003c62 <iunlockput>
    return 0;
    800054e2:	8ad2                	mv	s5,s4
    800054e4:	7a02                	ld	s4,32(sp)
    800054e6:	bf95                	j	8000545a <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054e8:	004a2603          	lw	a2,4(s4)
    800054ec:	00003597          	auipc	a1,0x3
    800054f0:	0ec58593          	addi	a1,a1,236 # 800085d8 <etext+0x5d8>
    800054f4:	8552                	mv	a0,s4
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	c22080e7          	jalr	-990(ra) # 80004118 <dirlink>
    800054fe:	04054463          	bltz	a0,80005546 <create+0x15c>
    80005502:	40d0                	lw	a2,4(s1)
    80005504:	00003597          	auipc	a1,0x3
    80005508:	0dc58593          	addi	a1,a1,220 # 800085e0 <etext+0x5e0>
    8000550c:	8552                	mv	a0,s4
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	c0a080e7          	jalr	-1014(ra) # 80004118 <dirlink>
    80005516:	02054863          	bltz	a0,80005546 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000551a:	004a2603          	lw	a2,4(s4)
    8000551e:	fb040593          	addi	a1,s0,-80
    80005522:	8526                	mv	a0,s1
    80005524:	fffff097          	auipc	ra,0xfffff
    80005528:	bf4080e7          	jalr	-1036(ra) # 80004118 <dirlink>
    8000552c:	00054d63          	bltz	a0,80005546 <create+0x15c>
    dp->nlink++;  // for ".."
    80005530:	04a4d783          	lhu	a5,74(s1)
    80005534:	2785                	addiw	a5,a5,1
    80005536:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000553a:	8526                	mv	a0,s1
    8000553c:	ffffe097          	auipc	ra,0xffffe
    80005540:	3f4080e7          	jalr	1012(ra) # 80003930 <iupdate>
    80005544:	b751                	j	800054c8 <create+0xde>
  ip->nlink = 0;
    80005546:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000554a:	8552                	mv	a0,s4
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	3e4080e7          	jalr	996(ra) # 80003930 <iupdate>
  iunlockput(ip);
    80005554:	8552                	mv	a0,s4
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	70c080e7          	jalr	1804(ra) # 80003c62 <iunlockput>
  iunlockput(dp);
    8000555e:	8526                	mv	a0,s1
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	702080e7          	jalr	1794(ra) # 80003c62 <iunlockput>
  return 0;
    80005568:	7a02                	ld	s4,32(sp)
    8000556a:	bdc5                	j	8000545a <create+0x70>
    return 0;
    8000556c:	8aaa                	mv	s5,a0
    8000556e:	b5f5                	j	8000545a <create+0x70>

0000000080005570 <sys_dup>:
{
    80005570:	7179                	addi	sp,sp,-48
    80005572:	f406                	sd	ra,40(sp)
    80005574:	f022                	sd	s0,32(sp)
    80005576:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005578:	fd840613          	addi	a2,s0,-40
    8000557c:	4581                	li	a1,0
    8000557e:	4501                	li	a0,0
    80005580:	00000097          	auipc	ra,0x0
    80005584:	dc8080e7          	jalr	-568(ra) # 80005348 <argfd>
    return -1;
    80005588:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000558a:	02054763          	bltz	a0,800055b8 <sys_dup+0x48>
    8000558e:	ec26                	sd	s1,24(sp)
    80005590:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005592:	fd843903          	ld	s2,-40(s0)
    80005596:	854a                	mv	a0,s2
    80005598:	00000097          	auipc	ra,0x0
    8000559c:	e10080e7          	jalr	-496(ra) # 800053a8 <fdalloc>
    800055a0:	84aa                	mv	s1,a0
    return -1;
    800055a2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055a4:	00054f63          	bltz	a0,800055c2 <sys_dup+0x52>
  filedup(f);
    800055a8:	854a                	mv	a0,s2
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	298080e7          	jalr	664(ra) # 80004842 <filedup>
  return fd;
    800055b2:	87a6                	mv	a5,s1
    800055b4:	64e2                	ld	s1,24(sp)
    800055b6:	6942                	ld	s2,16(sp)
}
    800055b8:	853e                	mv	a0,a5
    800055ba:	70a2                	ld	ra,40(sp)
    800055bc:	7402                	ld	s0,32(sp)
    800055be:	6145                	addi	sp,sp,48
    800055c0:	8082                	ret
    800055c2:	64e2                	ld	s1,24(sp)
    800055c4:	6942                	ld	s2,16(sp)
    800055c6:	bfcd                	j	800055b8 <sys_dup+0x48>

00000000800055c8 <sys_read>:
{
    800055c8:	7179                	addi	sp,sp,-48
    800055ca:	f406                	sd	ra,40(sp)
    800055cc:	f022                	sd	s0,32(sp)
    800055ce:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055d0:	fd840593          	addi	a1,s0,-40
    800055d4:	4505                	li	a0,1
    800055d6:	ffffd097          	auipc	ra,0xffffd
    800055da:	7b2080e7          	jalr	1970(ra) # 80002d88 <argaddr>
  argint(2, &n);
    800055de:	fe440593          	addi	a1,s0,-28
    800055e2:	4509                	li	a0,2
    800055e4:	ffffd097          	auipc	ra,0xffffd
    800055e8:	784080e7          	jalr	1924(ra) # 80002d68 <argint>
  if(argfd(0, 0, &f) < 0)
    800055ec:	fe840613          	addi	a2,s0,-24
    800055f0:	4581                	li	a1,0
    800055f2:	4501                	li	a0,0
    800055f4:	00000097          	auipc	ra,0x0
    800055f8:	d54080e7          	jalr	-684(ra) # 80005348 <argfd>
    800055fc:	87aa                	mv	a5,a0
    return -1;
    800055fe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005600:	0007cc63          	bltz	a5,80005618 <sys_read+0x50>
  return fileread(f, p, n);
    80005604:	fe442603          	lw	a2,-28(s0)
    80005608:	fd843583          	ld	a1,-40(s0)
    8000560c:	fe843503          	ld	a0,-24(s0)
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	3d8080e7          	jalr	984(ra) # 800049e8 <fileread>
}
    80005618:	70a2                	ld	ra,40(sp)
    8000561a:	7402                	ld	s0,32(sp)
    8000561c:	6145                	addi	sp,sp,48
    8000561e:	8082                	ret

0000000080005620 <sys_write>:
{
    80005620:	7179                	addi	sp,sp,-48
    80005622:	f406                	sd	ra,40(sp)
    80005624:	f022                	sd	s0,32(sp)
    80005626:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005628:	fd840593          	addi	a1,s0,-40
    8000562c:	4505                	li	a0,1
    8000562e:	ffffd097          	auipc	ra,0xffffd
    80005632:	75a080e7          	jalr	1882(ra) # 80002d88 <argaddr>
  argint(2, &n);
    80005636:	fe440593          	addi	a1,s0,-28
    8000563a:	4509                	li	a0,2
    8000563c:	ffffd097          	auipc	ra,0xffffd
    80005640:	72c080e7          	jalr	1836(ra) # 80002d68 <argint>
  if(argfd(0, 0, &f) < 0)
    80005644:	fe840613          	addi	a2,s0,-24
    80005648:	4581                	li	a1,0
    8000564a:	4501                	li	a0,0
    8000564c:	00000097          	auipc	ra,0x0
    80005650:	cfc080e7          	jalr	-772(ra) # 80005348 <argfd>
    80005654:	87aa                	mv	a5,a0
    return -1;
    80005656:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005658:	0007cc63          	bltz	a5,80005670 <sys_write+0x50>
  return filewrite(f, p, n);
    8000565c:	fe442603          	lw	a2,-28(s0)
    80005660:	fd843583          	ld	a1,-40(s0)
    80005664:	fe843503          	ld	a0,-24(s0)
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	452080e7          	jalr	1106(ra) # 80004aba <filewrite>
}
    80005670:	70a2                	ld	ra,40(sp)
    80005672:	7402                	ld	s0,32(sp)
    80005674:	6145                	addi	sp,sp,48
    80005676:	8082                	ret

0000000080005678 <sys_close>:
{
    80005678:	1101                	addi	sp,sp,-32
    8000567a:	ec06                	sd	ra,24(sp)
    8000567c:	e822                	sd	s0,16(sp)
    8000567e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005680:	fe040613          	addi	a2,s0,-32
    80005684:	fec40593          	addi	a1,s0,-20
    80005688:	4501                	li	a0,0
    8000568a:	00000097          	auipc	ra,0x0
    8000568e:	cbe080e7          	jalr	-834(ra) # 80005348 <argfd>
    return -1;
    80005692:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005694:	02054463          	bltz	a0,800056bc <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005698:	ffffc097          	auipc	ra,0xffffc
    8000569c:	3b2080e7          	jalr	946(ra) # 80001a4a <myproc>
    800056a0:	fec42783          	lw	a5,-20(s0)
    800056a4:	07e9                	addi	a5,a5,26
    800056a6:	078e                	slli	a5,a5,0x3
    800056a8:	953e                	add	a0,a0,a5
    800056aa:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800056ae:	fe043503          	ld	a0,-32(s0)
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	1e2080e7          	jalr	482(ra) # 80004894 <fileclose>
  return 0;
    800056ba:	4781                	li	a5,0
}
    800056bc:	853e                	mv	a0,a5
    800056be:	60e2                	ld	ra,24(sp)
    800056c0:	6442                	ld	s0,16(sp)
    800056c2:	6105                	addi	sp,sp,32
    800056c4:	8082                	ret

00000000800056c6 <sys_fstat>:
{
    800056c6:	1101                	addi	sp,sp,-32
    800056c8:	ec06                	sd	ra,24(sp)
    800056ca:	e822                	sd	s0,16(sp)
    800056cc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800056ce:	fe040593          	addi	a1,s0,-32
    800056d2:	4505                	li	a0,1
    800056d4:	ffffd097          	auipc	ra,0xffffd
    800056d8:	6b4080e7          	jalr	1716(ra) # 80002d88 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800056dc:	fe840613          	addi	a2,s0,-24
    800056e0:	4581                	li	a1,0
    800056e2:	4501                	li	a0,0
    800056e4:	00000097          	auipc	ra,0x0
    800056e8:	c64080e7          	jalr	-924(ra) # 80005348 <argfd>
    800056ec:	87aa                	mv	a5,a0
    return -1;
    800056ee:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056f0:	0007ca63          	bltz	a5,80005704 <sys_fstat+0x3e>
  return filestat(f, st);
    800056f4:	fe043583          	ld	a1,-32(s0)
    800056f8:	fe843503          	ld	a0,-24(s0)
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	27a080e7          	jalr	634(ra) # 80004976 <filestat>
}
    80005704:	60e2                	ld	ra,24(sp)
    80005706:	6442                	ld	s0,16(sp)
    80005708:	6105                	addi	sp,sp,32
    8000570a:	8082                	ret

000000008000570c <sys_link>:
{
    8000570c:	7169                	addi	sp,sp,-304
    8000570e:	f606                	sd	ra,296(sp)
    80005710:	f222                	sd	s0,288(sp)
    80005712:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005714:	08000613          	li	a2,128
    80005718:	ed040593          	addi	a1,s0,-304
    8000571c:	4501                	li	a0,0
    8000571e:	ffffd097          	auipc	ra,0xffffd
    80005722:	68a080e7          	jalr	1674(ra) # 80002da8 <argstr>
    return -1;
    80005726:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005728:	12054663          	bltz	a0,80005854 <sys_link+0x148>
    8000572c:	08000613          	li	a2,128
    80005730:	f5040593          	addi	a1,s0,-176
    80005734:	4505                	li	a0,1
    80005736:	ffffd097          	auipc	ra,0xffffd
    8000573a:	672080e7          	jalr	1650(ra) # 80002da8 <argstr>
    return -1;
    8000573e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005740:	10054a63          	bltz	a0,80005854 <sys_link+0x148>
    80005744:	ee26                	sd	s1,280(sp)
  begin_op();
    80005746:	fffff097          	auipc	ra,0xfffff
    8000574a:	c84080e7          	jalr	-892(ra) # 800043ca <begin_op>
  if((ip = namei(old)) == 0){
    8000574e:	ed040513          	addi	a0,s0,-304
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	a78080e7          	jalr	-1416(ra) # 800041ca <namei>
    8000575a:	84aa                	mv	s1,a0
    8000575c:	c949                	beqz	a0,800057ee <sys_link+0xe2>
  ilock(ip);
    8000575e:	ffffe097          	auipc	ra,0xffffe
    80005762:	29e080e7          	jalr	670(ra) # 800039fc <ilock>
  if(ip->type == T_DIR){
    80005766:	04449703          	lh	a4,68(s1)
    8000576a:	4785                	li	a5,1
    8000576c:	08f70863          	beq	a4,a5,800057fc <sys_link+0xf0>
    80005770:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005772:	04a4d783          	lhu	a5,74(s1)
    80005776:	2785                	addiw	a5,a5,1
    80005778:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000577c:	8526                	mv	a0,s1
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	1b2080e7          	jalr	434(ra) # 80003930 <iupdate>
  iunlock(ip);
    80005786:	8526                	mv	a0,s1
    80005788:	ffffe097          	auipc	ra,0xffffe
    8000578c:	33a080e7          	jalr	826(ra) # 80003ac2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005790:	fd040593          	addi	a1,s0,-48
    80005794:	f5040513          	addi	a0,s0,-176
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	a50080e7          	jalr	-1456(ra) # 800041e8 <nameiparent>
    800057a0:	892a                	mv	s2,a0
    800057a2:	cd35                	beqz	a0,8000581e <sys_link+0x112>
  ilock(dp);
    800057a4:	ffffe097          	auipc	ra,0xffffe
    800057a8:	258080e7          	jalr	600(ra) # 800039fc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057ac:	00092703          	lw	a4,0(s2)
    800057b0:	409c                	lw	a5,0(s1)
    800057b2:	06f71163          	bne	a4,a5,80005814 <sys_link+0x108>
    800057b6:	40d0                	lw	a2,4(s1)
    800057b8:	fd040593          	addi	a1,s0,-48
    800057bc:	854a                	mv	a0,s2
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	95a080e7          	jalr	-1702(ra) # 80004118 <dirlink>
    800057c6:	04054763          	bltz	a0,80005814 <sys_link+0x108>
  iunlockput(dp);
    800057ca:	854a                	mv	a0,s2
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	496080e7          	jalr	1174(ra) # 80003c62 <iunlockput>
  iput(ip);
    800057d4:	8526                	mv	a0,s1
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	3e4080e7          	jalr	996(ra) # 80003bba <iput>
  end_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	c66080e7          	jalr	-922(ra) # 80004444 <end_op>
  return 0;
    800057e6:	4781                	li	a5,0
    800057e8:	64f2                	ld	s1,280(sp)
    800057ea:	6952                	ld	s2,272(sp)
    800057ec:	a0a5                	j	80005854 <sys_link+0x148>
    end_op();
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	c56080e7          	jalr	-938(ra) # 80004444 <end_op>
    return -1;
    800057f6:	57fd                	li	a5,-1
    800057f8:	64f2                	ld	s1,280(sp)
    800057fa:	a8a9                	j	80005854 <sys_link+0x148>
    iunlockput(ip);
    800057fc:	8526                	mv	a0,s1
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	464080e7          	jalr	1124(ra) # 80003c62 <iunlockput>
    end_op();
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	c3e080e7          	jalr	-962(ra) # 80004444 <end_op>
    return -1;
    8000580e:	57fd                	li	a5,-1
    80005810:	64f2                	ld	s1,280(sp)
    80005812:	a089                	j	80005854 <sys_link+0x148>
    iunlockput(dp);
    80005814:	854a                	mv	a0,s2
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	44c080e7          	jalr	1100(ra) # 80003c62 <iunlockput>
  ilock(ip);
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	1dc080e7          	jalr	476(ra) # 800039fc <ilock>
  ip->nlink--;
    80005828:	04a4d783          	lhu	a5,74(s1)
    8000582c:	37fd                	addiw	a5,a5,-1
    8000582e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005832:	8526                	mv	a0,s1
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	0fc080e7          	jalr	252(ra) # 80003930 <iupdate>
  iunlockput(ip);
    8000583c:	8526                	mv	a0,s1
    8000583e:	ffffe097          	auipc	ra,0xffffe
    80005842:	424080e7          	jalr	1060(ra) # 80003c62 <iunlockput>
  end_op();
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	bfe080e7          	jalr	-1026(ra) # 80004444 <end_op>
  return -1;
    8000584e:	57fd                	li	a5,-1
    80005850:	64f2                	ld	s1,280(sp)
    80005852:	6952                	ld	s2,272(sp)
}
    80005854:	853e                	mv	a0,a5
    80005856:	70b2                	ld	ra,296(sp)
    80005858:	7412                	ld	s0,288(sp)
    8000585a:	6155                	addi	sp,sp,304
    8000585c:	8082                	ret

000000008000585e <sys_unlink>:
{
    8000585e:	7151                	addi	sp,sp,-240
    80005860:	f586                	sd	ra,232(sp)
    80005862:	f1a2                	sd	s0,224(sp)
    80005864:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005866:	08000613          	li	a2,128
    8000586a:	f3040593          	addi	a1,s0,-208
    8000586e:	4501                	li	a0,0
    80005870:	ffffd097          	auipc	ra,0xffffd
    80005874:	538080e7          	jalr	1336(ra) # 80002da8 <argstr>
    80005878:	1a054a63          	bltz	a0,80005a2c <sys_unlink+0x1ce>
    8000587c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	b4c080e7          	jalr	-1204(ra) # 800043ca <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005886:	fb040593          	addi	a1,s0,-80
    8000588a:	f3040513          	addi	a0,s0,-208
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	95a080e7          	jalr	-1702(ra) # 800041e8 <nameiparent>
    80005896:	84aa                	mv	s1,a0
    80005898:	cd71                	beqz	a0,80005974 <sys_unlink+0x116>
  ilock(dp);
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	162080e7          	jalr	354(ra) # 800039fc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058a2:	00003597          	auipc	a1,0x3
    800058a6:	d3658593          	addi	a1,a1,-714 # 800085d8 <etext+0x5d8>
    800058aa:	fb040513          	addi	a0,s0,-80
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	640080e7          	jalr	1600(ra) # 80003eee <namecmp>
    800058b6:	14050c63          	beqz	a0,80005a0e <sys_unlink+0x1b0>
    800058ba:	00003597          	auipc	a1,0x3
    800058be:	d2658593          	addi	a1,a1,-730 # 800085e0 <etext+0x5e0>
    800058c2:	fb040513          	addi	a0,s0,-80
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	628080e7          	jalr	1576(ra) # 80003eee <namecmp>
    800058ce:	14050063          	beqz	a0,80005a0e <sys_unlink+0x1b0>
    800058d2:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058d4:	f2c40613          	addi	a2,s0,-212
    800058d8:	fb040593          	addi	a1,s0,-80
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	62a080e7          	jalr	1578(ra) # 80003f08 <dirlookup>
    800058e6:	892a                	mv	s2,a0
    800058e8:	12050263          	beqz	a0,80005a0c <sys_unlink+0x1ae>
  ilock(ip);
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	110080e7          	jalr	272(ra) # 800039fc <ilock>
  if(ip->nlink < 1)
    800058f4:	04a91783          	lh	a5,74(s2)
    800058f8:	08f05563          	blez	a5,80005982 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058fc:	04491703          	lh	a4,68(s2)
    80005900:	4785                	li	a5,1
    80005902:	08f70963          	beq	a4,a5,80005994 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005906:	4641                	li	a2,16
    80005908:	4581                	li	a1,0
    8000590a:	fc040513          	addi	a0,s0,-64
    8000590e:	ffffb097          	auipc	ra,0xffffb
    80005912:	426080e7          	jalr	1062(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005916:	4741                	li	a4,16
    80005918:	f2c42683          	lw	a3,-212(s0)
    8000591c:	fc040613          	addi	a2,s0,-64
    80005920:	4581                	li	a1,0
    80005922:	8526                	mv	a0,s1
    80005924:	ffffe097          	auipc	ra,0xffffe
    80005928:	4a0080e7          	jalr	1184(ra) # 80003dc4 <writei>
    8000592c:	47c1                	li	a5,16
    8000592e:	0af51b63          	bne	a0,a5,800059e4 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005932:	04491703          	lh	a4,68(s2)
    80005936:	4785                	li	a5,1
    80005938:	0af70f63          	beq	a4,a5,800059f6 <sys_unlink+0x198>
  iunlockput(dp);
    8000593c:	8526                	mv	a0,s1
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	324080e7          	jalr	804(ra) # 80003c62 <iunlockput>
  ip->nlink--;
    80005946:	04a95783          	lhu	a5,74(s2)
    8000594a:	37fd                	addiw	a5,a5,-1
    8000594c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005950:	854a                	mv	a0,s2
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	fde080e7          	jalr	-34(ra) # 80003930 <iupdate>
  iunlockput(ip);
    8000595a:	854a                	mv	a0,s2
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	306080e7          	jalr	774(ra) # 80003c62 <iunlockput>
  end_op();
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	ae0080e7          	jalr	-1312(ra) # 80004444 <end_op>
  return 0;
    8000596c:	4501                	li	a0,0
    8000596e:	64ee                	ld	s1,216(sp)
    80005970:	694e                	ld	s2,208(sp)
    80005972:	a84d                	j	80005a24 <sys_unlink+0x1c6>
    end_op();
    80005974:	fffff097          	auipc	ra,0xfffff
    80005978:	ad0080e7          	jalr	-1328(ra) # 80004444 <end_op>
    return -1;
    8000597c:	557d                	li	a0,-1
    8000597e:	64ee                	ld	s1,216(sp)
    80005980:	a055                	j	80005a24 <sys_unlink+0x1c6>
    80005982:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005984:	00003517          	auipc	a0,0x3
    80005988:	c6450513          	addi	a0,a0,-924 # 800085e8 <etext+0x5e8>
    8000598c:	ffffb097          	auipc	ra,0xffffb
    80005990:	bd4080e7          	jalr	-1068(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005994:	04c92703          	lw	a4,76(s2)
    80005998:	02000793          	li	a5,32
    8000599c:	f6e7f5e3          	bgeu	a5,a4,80005906 <sys_unlink+0xa8>
    800059a0:	e5ce                	sd	s3,200(sp)
    800059a2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059a6:	4741                	li	a4,16
    800059a8:	86ce                	mv	a3,s3
    800059aa:	f1840613          	addi	a2,s0,-232
    800059ae:	4581                	li	a1,0
    800059b0:	854a                	mv	a0,s2
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	302080e7          	jalr	770(ra) # 80003cb4 <readi>
    800059ba:	47c1                	li	a5,16
    800059bc:	00f51c63          	bne	a0,a5,800059d4 <sys_unlink+0x176>
    if(de.inum != 0)
    800059c0:	f1845783          	lhu	a5,-232(s0)
    800059c4:	e7b5                	bnez	a5,80005a30 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059c6:	29c1                	addiw	s3,s3,16
    800059c8:	04c92783          	lw	a5,76(s2)
    800059cc:	fcf9ede3          	bltu	s3,a5,800059a6 <sys_unlink+0x148>
    800059d0:	69ae                	ld	s3,200(sp)
    800059d2:	bf15                	j	80005906 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    800059d4:	00003517          	auipc	a0,0x3
    800059d8:	c2c50513          	addi	a0,a0,-980 # 80008600 <etext+0x600>
    800059dc:	ffffb097          	auipc	ra,0xffffb
    800059e0:	b84080e7          	jalr	-1148(ra) # 80000560 <panic>
    800059e4:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800059e6:	00003517          	auipc	a0,0x3
    800059ea:	c3250513          	addi	a0,a0,-974 # 80008618 <etext+0x618>
    800059ee:	ffffb097          	auipc	ra,0xffffb
    800059f2:	b72080e7          	jalr	-1166(ra) # 80000560 <panic>
    dp->nlink--;
    800059f6:	04a4d783          	lhu	a5,74(s1)
    800059fa:	37fd                	addiw	a5,a5,-1
    800059fc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a00:	8526                	mv	a0,s1
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	f2e080e7          	jalr	-210(ra) # 80003930 <iupdate>
    80005a0a:	bf0d                	j	8000593c <sys_unlink+0xde>
    80005a0c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005a0e:	8526                	mv	a0,s1
    80005a10:	ffffe097          	auipc	ra,0xffffe
    80005a14:	252080e7          	jalr	594(ra) # 80003c62 <iunlockput>
  end_op();
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	a2c080e7          	jalr	-1492(ra) # 80004444 <end_op>
  return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	64ee                	ld	s1,216(sp)
}
    80005a24:	70ae                	ld	ra,232(sp)
    80005a26:	740e                	ld	s0,224(sp)
    80005a28:	616d                	addi	sp,sp,240
    80005a2a:	8082                	ret
    return -1;
    80005a2c:	557d                	li	a0,-1
    80005a2e:	bfdd                	j	80005a24 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005a30:	854a                	mv	a0,s2
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	230080e7          	jalr	560(ra) # 80003c62 <iunlockput>
    goto bad;
    80005a3a:	694e                	ld	s2,208(sp)
    80005a3c:	69ae                	ld	s3,200(sp)
    80005a3e:	bfc1                	j	80005a0e <sys_unlink+0x1b0>

0000000080005a40 <sys_open>:

uint64
sys_open(void)
{
    80005a40:	7131                	addi	sp,sp,-192
    80005a42:	fd06                	sd	ra,184(sp)
    80005a44:	f922                	sd	s0,176(sp)
    80005a46:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a48:	f4c40593          	addi	a1,s0,-180
    80005a4c:	4505                	li	a0,1
    80005a4e:	ffffd097          	auipc	ra,0xffffd
    80005a52:	31a080e7          	jalr	794(ra) # 80002d68 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a56:	08000613          	li	a2,128
    80005a5a:	f5040593          	addi	a1,s0,-176
    80005a5e:	4501                	li	a0,0
    80005a60:	ffffd097          	auipc	ra,0xffffd
    80005a64:	348080e7          	jalr	840(ra) # 80002da8 <argstr>
    80005a68:	87aa                	mv	a5,a0
    return -1;
    80005a6a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a6c:	0a07ce63          	bltz	a5,80005b28 <sys_open+0xe8>
    80005a70:	f526                	sd	s1,168(sp)

  begin_op();
    80005a72:	fffff097          	auipc	ra,0xfffff
    80005a76:	958080e7          	jalr	-1704(ra) # 800043ca <begin_op>

  if(omode & O_CREATE){
    80005a7a:	f4c42783          	lw	a5,-180(s0)
    80005a7e:	2007f793          	andi	a5,a5,512
    80005a82:	cfd5                	beqz	a5,80005b3e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a84:	4681                	li	a3,0
    80005a86:	4601                	li	a2,0
    80005a88:	4589                	li	a1,2
    80005a8a:	f5040513          	addi	a0,s0,-176
    80005a8e:	00000097          	auipc	ra,0x0
    80005a92:	95c080e7          	jalr	-1700(ra) # 800053ea <create>
    80005a96:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a98:	cd41                	beqz	a0,80005b30 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a9a:	04449703          	lh	a4,68(s1)
    80005a9e:	478d                	li	a5,3
    80005aa0:	00f71763          	bne	a4,a5,80005aae <sys_open+0x6e>
    80005aa4:	0464d703          	lhu	a4,70(s1)
    80005aa8:	47a5                	li	a5,9
    80005aaa:	0ee7e163          	bltu	a5,a4,80005b8c <sys_open+0x14c>
    80005aae:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	d28080e7          	jalr	-728(ra) # 800047d8 <filealloc>
    80005ab8:	892a                	mv	s2,a0
    80005aba:	c97d                	beqz	a0,80005bb0 <sys_open+0x170>
    80005abc:	ed4e                	sd	s3,152(sp)
    80005abe:	00000097          	auipc	ra,0x0
    80005ac2:	8ea080e7          	jalr	-1814(ra) # 800053a8 <fdalloc>
    80005ac6:	89aa                	mv	s3,a0
    80005ac8:	0c054e63          	bltz	a0,80005ba4 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005acc:	04449703          	lh	a4,68(s1)
    80005ad0:	478d                	li	a5,3
    80005ad2:	0ef70c63          	beq	a4,a5,80005bca <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ad6:	4789                	li	a5,2
    80005ad8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005adc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005ae0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005ae4:	f4c42783          	lw	a5,-180(s0)
    80005ae8:	0017c713          	xori	a4,a5,1
    80005aec:	8b05                	andi	a4,a4,1
    80005aee:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005af2:	0037f713          	andi	a4,a5,3
    80005af6:	00e03733          	snez	a4,a4
    80005afa:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005afe:	4007f793          	andi	a5,a5,1024
    80005b02:	c791                	beqz	a5,80005b0e <sys_open+0xce>
    80005b04:	04449703          	lh	a4,68(s1)
    80005b08:	4789                	li	a5,2
    80005b0a:	0cf70763          	beq	a4,a5,80005bd8 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	fb2080e7          	jalr	-78(ra) # 80003ac2 <iunlock>
  end_op();
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	92c080e7          	jalr	-1748(ra) # 80004444 <end_op>

  return fd;
    80005b20:	854e                	mv	a0,s3
    80005b22:	74aa                	ld	s1,168(sp)
    80005b24:	790a                	ld	s2,160(sp)
    80005b26:	69ea                	ld	s3,152(sp)
}
    80005b28:	70ea                	ld	ra,184(sp)
    80005b2a:	744a                	ld	s0,176(sp)
    80005b2c:	6129                	addi	sp,sp,192
    80005b2e:	8082                	ret
      end_op();
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	914080e7          	jalr	-1772(ra) # 80004444 <end_op>
      return -1;
    80005b38:	557d                	li	a0,-1
    80005b3a:	74aa                	ld	s1,168(sp)
    80005b3c:	b7f5                	j	80005b28 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005b3e:	f5040513          	addi	a0,s0,-176
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	688080e7          	jalr	1672(ra) # 800041ca <namei>
    80005b4a:	84aa                	mv	s1,a0
    80005b4c:	c90d                	beqz	a0,80005b7e <sys_open+0x13e>
    ilock(ip);
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	eae080e7          	jalr	-338(ra) # 800039fc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b56:	04449703          	lh	a4,68(s1)
    80005b5a:	4785                	li	a5,1
    80005b5c:	f2f71fe3          	bne	a4,a5,80005a9a <sys_open+0x5a>
    80005b60:	f4c42783          	lw	a5,-180(s0)
    80005b64:	d7a9                	beqz	a5,80005aae <sys_open+0x6e>
      iunlockput(ip);
    80005b66:	8526                	mv	a0,s1
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	0fa080e7          	jalr	250(ra) # 80003c62 <iunlockput>
      end_op();
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	8d4080e7          	jalr	-1836(ra) # 80004444 <end_op>
      return -1;
    80005b78:	557d                	li	a0,-1
    80005b7a:	74aa                	ld	s1,168(sp)
    80005b7c:	b775                	j	80005b28 <sys_open+0xe8>
      end_op();
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	8c6080e7          	jalr	-1850(ra) # 80004444 <end_op>
      return -1;
    80005b86:	557d                	li	a0,-1
    80005b88:	74aa                	ld	s1,168(sp)
    80005b8a:	bf79                	j	80005b28 <sys_open+0xe8>
    iunlockput(ip);
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	0d4080e7          	jalr	212(ra) # 80003c62 <iunlockput>
    end_op();
    80005b96:	fffff097          	auipc	ra,0xfffff
    80005b9a:	8ae080e7          	jalr	-1874(ra) # 80004444 <end_op>
    return -1;
    80005b9e:	557d                	li	a0,-1
    80005ba0:	74aa                	ld	s1,168(sp)
    80005ba2:	b759                	j	80005b28 <sys_open+0xe8>
      fileclose(f);
    80005ba4:	854a                	mv	a0,s2
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	cee080e7          	jalr	-786(ra) # 80004894 <fileclose>
    80005bae:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005bb0:	8526                	mv	a0,s1
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	0b0080e7          	jalr	176(ra) # 80003c62 <iunlockput>
    end_op();
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	88a080e7          	jalr	-1910(ra) # 80004444 <end_op>
    return -1;
    80005bc2:	557d                	li	a0,-1
    80005bc4:	74aa                	ld	s1,168(sp)
    80005bc6:	790a                	ld	s2,160(sp)
    80005bc8:	b785                	j	80005b28 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005bca:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005bce:	04649783          	lh	a5,70(s1)
    80005bd2:	02f91223          	sh	a5,36(s2)
    80005bd6:	b729                	j	80005ae0 <sys_open+0xa0>
    itrunc(ip);
    80005bd8:	8526                	mv	a0,s1
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	f34080e7          	jalr	-204(ra) # 80003b0e <itrunc>
    80005be2:	b735                	j	80005b0e <sys_open+0xce>

0000000080005be4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005be4:	7175                	addi	sp,sp,-144
    80005be6:	e506                	sd	ra,136(sp)
    80005be8:	e122                	sd	s0,128(sp)
    80005bea:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bec:	ffffe097          	auipc	ra,0xffffe
    80005bf0:	7de080e7          	jalr	2014(ra) # 800043ca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bf4:	08000613          	li	a2,128
    80005bf8:	f7040593          	addi	a1,s0,-144
    80005bfc:	4501                	li	a0,0
    80005bfe:	ffffd097          	auipc	ra,0xffffd
    80005c02:	1aa080e7          	jalr	426(ra) # 80002da8 <argstr>
    80005c06:	02054963          	bltz	a0,80005c38 <sys_mkdir+0x54>
    80005c0a:	4681                	li	a3,0
    80005c0c:	4601                	li	a2,0
    80005c0e:	4585                	li	a1,1
    80005c10:	f7040513          	addi	a0,s0,-144
    80005c14:	fffff097          	auipc	ra,0xfffff
    80005c18:	7d6080e7          	jalr	2006(ra) # 800053ea <create>
    80005c1c:	cd11                	beqz	a0,80005c38 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	044080e7          	jalr	68(ra) # 80003c62 <iunlockput>
  end_op();
    80005c26:	fffff097          	auipc	ra,0xfffff
    80005c2a:	81e080e7          	jalr	-2018(ra) # 80004444 <end_op>
  return 0;
    80005c2e:	4501                	li	a0,0
}
    80005c30:	60aa                	ld	ra,136(sp)
    80005c32:	640a                	ld	s0,128(sp)
    80005c34:	6149                	addi	sp,sp,144
    80005c36:	8082                	ret
    end_op();
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	80c080e7          	jalr	-2036(ra) # 80004444 <end_op>
    return -1;
    80005c40:	557d                	li	a0,-1
    80005c42:	b7fd                	j	80005c30 <sys_mkdir+0x4c>

0000000080005c44 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c44:	7135                	addi	sp,sp,-160
    80005c46:	ed06                	sd	ra,152(sp)
    80005c48:	e922                	sd	s0,144(sp)
    80005c4a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	77e080e7          	jalr	1918(ra) # 800043ca <begin_op>
  argint(1, &major);
    80005c54:	f6c40593          	addi	a1,s0,-148
    80005c58:	4505                	li	a0,1
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	10e080e7          	jalr	270(ra) # 80002d68 <argint>
  argint(2, &minor);
    80005c62:	f6840593          	addi	a1,s0,-152
    80005c66:	4509                	li	a0,2
    80005c68:	ffffd097          	auipc	ra,0xffffd
    80005c6c:	100080e7          	jalr	256(ra) # 80002d68 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c70:	08000613          	li	a2,128
    80005c74:	f7040593          	addi	a1,s0,-144
    80005c78:	4501                	li	a0,0
    80005c7a:	ffffd097          	auipc	ra,0xffffd
    80005c7e:	12e080e7          	jalr	302(ra) # 80002da8 <argstr>
    80005c82:	02054b63          	bltz	a0,80005cb8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c86:	f6841683          	lh	a3,-152(s0)
    80005c8a:	f6c41603          	lh	a2,-148(s0)
    80005c8e:	458d                	li	a1,3
    80005c90:	f7040513          	addi	a0,s0,-144
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	756080e7          	jalr	1878(ra) # 800053ea <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c9c:	cd11                	beqz	a0,80005cb8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c9e:	ffffe097          	auipc	ra,0xffffe
    80005ca2:	fc4080e7          	jalr	-60(ra) # 80003c62 <iunlockput>
  end_op();
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	79e080e7          	jalr	1950(ra) # 80004444 <end_op>
  return 0;
    80005cae:	4501                	li	a0,0
}
    80005cb0:	60ea                	ld	ra,152(sp)
    80005cb2:	644a                	ld	s0,144(sp)
    80005cb4:	610d                	addi	sp,sp,160
    80005cb6:	8082                	ret
    end_op();
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	78c080e7          	jalr	1932(ra) # 80004444 <end_op>
    return -1;
    80005cc0:	557d                	li	a0,-1
    80005cc2:	b7fd                	j	80005cb0 <sys_mknod+0x6c>

0000000080005cc4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cc4:	7135                	addi	sp,sp,-160
    80005cc6:	ed06                	sd	ra,152(sp)
    80005cc8:	e922                	sd	s0,144(sp)
    80005cca:	e14a                	sd	s2,128(sp)
    80005ccc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cce:	ffffc097          	auipc	ra,0xffffc
    80005cd2:	d7c080e7          	jalr	-644(ra) # 80001a4a <myproc>
    80005cd6:	892a                	mv	s2,a0
  
  begin_op();
    80005cd8:	ffffe097          	auipc	ra,0xffffe
    80005cdc:	6f2080e7          	jalr	1778(ra) # 800043ca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ce0:	08000613          	li	a2,128
    80005ce4:	f6040593          	addi	a1,s0,-160
    80005ce8:	4501                	li	a0,0
    80005cea:	ffffd097          	auipc	ra,0xffffd
    80005cee:	0be080e7          	jalr	190(ra) # 80002da8 <argstr>
    80005cf2:	04054d63          	bltz	a0,80005d4c <sys_chdir+0x88>
    80005cf6:	e526                	sd	s1,136(sp)
    80005cf8:	f6040513          	addi	a0,s0,-160
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	4ce080e7          	jalr	1230(ra) # 800041ca <namei>
    80005d04:	84aa                	mv	s1,a0
    80005d06:	c131                	beqz	a0,80005d4a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d08:	ffffe097          	auipc	ra,0xffffe
    80005d0c:	cf4080e7          	jalr	-780(ra) # 800039fc <ilock>
  if(ip->type != T_DIR){
    80005d10:	04449703          	lh	a4,68(s1)
    80005d14:	4785                	li	a5,1
    80005d16:	04f71163          	bne	a4,a5,80005d58 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d1a:	8526                	mv	a0,s1
    80005d1c:	ffffe097          	auipc	ra,0xffffe
    80005d20:	da6080e7          	jalr	-602(ra) # 80003ac2 <iunlock>
  iput(p->cwd);
    80005d24:	15093503          	ld	a0,336(s2)
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	e92080e7          	jalr	-366(ra) # 80003bba <iput>
  end_op();
    80005d30:	ffffe097          	auipc	ra,0xffffe
    80005d34:	714080e7          	jalr	1812(ra) # 80004444 <end_op>
  p->cwd = ip;
    80005d38:	14993823          	sd	s1,336(s2)
  return 0;
    80005d3c:	4501                	li	a0,0
    80005d3e:	64aa                	ld	s1,136(sp)
}
    80005d40:	60ea                	ld	ra,152(sp)
    80005d42:	644a                	ld	s0,144(sp)
    80005d44:	690a                	ld	s2,128(sp)
    80005d46:	610d                	addi	sp,sp,160
    80005d48:	8082                	ret
    80005d4a:	64aa                	ld	s1,136(sp)
    end_op();
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	6f8080e7          	jalr	1784(ra) # 80004444 <end_op>
    return -1;
    80005d54:	557d                	li	a0,-1
    80005d56:	b7ed                	j	80005d40 <sys_chdir+0x7c>
    iunlockput(ip);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	f08080e7          	jalr	-248(ra) # 80003c62 <iunlockput>
    end_op();
    80005d62:	ffffe097          	auipc	ra,0xffffe
    80005d66:	6e2080e7          	jalr	1762(ra) # 80004444 <end_op>
    return -1;
    80005d6a:	557d                	li	a0,-1
    80005d6c:	64aa                	ld	s1,136(sp)
    80005d6e:	bfc9                	j	80005d40 <sys_chdir+0x7c>

0000000080005d70 <sys_exec>:

uint64
sys_exec(void)
{
    80005d70:	7121                	addi	sp,sp,-448
    80005d72:	ff06                	sd	ra,440(sp)
    80005d74:	fb22                	sd	s0,432(sp)
    80005d76:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d78:	e4840593          	addi	a1,s0,-440
    80005d7c:	4505                	li	a0,1
    80005d7e:	ffffd097          	auipc	ra,0xffffd
    80005d82:	00a080e7          	jalr	10(ra) # 80002d88 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005d86:	08000613          	li	a2,128
    80005d8a:	f5040593          	addi	a1,s0,-176
    80005d8e:	4501                	li	a0,0
    80005d90:	ffffd097          	auipc	ra,0xffffd
    80005d94:	018080e7          	jalr	24(ra) # 80002da8 <argstr>
    80005d98:	87aa                	mv	a5,a0
    return -1;
    80005d9a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d9c:	0e07c263          	bltz	a5,80005e80 <sys_exec+0x110>
    80005da0:	f726                	sd	s1,424(sp)
    80005da2:	f34a                	sd	s2,416(sp)
    80005da4:	ef4e                	sd	s3,408(sp)
    80005da6:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005da8:	10000613          	li	a2,256
    80005dac:	4581                	li	a1,0
    80005dae:	e5040513          	addi	a0,s0,-432
    80005db2:	ffffb097          	auipc	ra,0xffffb
    80005db6:	f82080e7          	jalr	-126(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005dba:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005dbe:	89a6                	mv	s3,s1
    80005dc0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005dc2:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005dc6:	00391513          	slli	a0,s2,0x3
    80005dca:	e4040593          	addi	a1,s0,-448
    80005dce:	e4843783          	ld	a5,-440(s0)
    80005dd2:	953e                	add	a0,a0,a5
    80005dd4:	ffffd097          	auipc	ra,0xffffd
    80005dd8:	ef6080e7          	jalr	-266(ra) # 80002cca <fetchaddr>
    80005ddc:	02054a63          	bltz	a0,80005e10 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005de0:	e4043783          	ld	a5,-448(s0)
    80005de4:	c7b9                	beqz	a5,80005e32 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005de6:	ffffb097          	auipc	ra,0xffffb
    80005dea:	d62080e7          	jalr	-670(ra) # 80000b48 <kalloc>
    80005dee:	85aa                	mv	a1,a0
    80005df0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005df4:	cd11                	beqz	a0,80005e10 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005df6:	6605                	lui	a2,0x1
    80005df8:	e4043503          	ld	a0,-448(s0)
    80005dfc:	ffffd097          	auipc	ra,0xffffd
    80005e00:	f20080e7          	jalr	-224(ra) # 80002d1c <fetchstr>
    80005e04:	00054663          	bltz	a0,80005e10 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005e08:	0905                	addi	s2,s2,1
    80005e0a:	09a1                	addi	s3,s3,8
    80005e0c:	fb491de3          	bne	s2,s4,80005dc6 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e10:	f5040913          	addi	s2,s0,-176
    80005e14:	6088                	ld	a0,0(s1)
    80005e16:	c125                	beqz	a0,80005e76 <sys_exec+0x106>
    kfree(argv[i]);
    80005e18:	ffffb097          	auipc	ra,0xffffb
    80005e1c:	c32080e7          	jalr	-974(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e20:	04a1                	addi	s1,s1,8
    80005e22:	ff2499e3          	bne	s1,s2,80005e14 <sys_exec+0xa4>
  return -1;
    80005e26:	557d                	li	a0,-1
    80005e28:	74ba                	ld	s1,424(sp)
    80005e2a:	791a                	ld	s2,416(sp)
    80005e2c:	69fa                	ld	s3,408(sp)
    80005e2e:	6a5a                	ld	s4,400(sp)
    80005e30:	a881                	j	80005e80 <sys_exec+0x110>
      argv[i] = 0;
    80005e32:	0009079b          	sext.w	a5,s2
    80005e36:	078e                	slli	a5,a5,0x3
    80005e38:	fd078793          	addi	a5,a5,-48
    80005e3c:	97a2                	add	a5,a5,s0
    80005e3e:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005e42:	e5040593          	addi	a1,s0,-432
    80005e46:	f5040513          	addi	a0,s0,-176
    80005e4a:	fffff097          	auipc	ra,0xfffff
    80005e4e:	120080e7          	jalr	288(ra) # 80004f6a <exec>
    80005e52:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e54:	f5040993          	addi	s3,s0,-176
    80005e58:	6088                	ld	a0,0(s1)
    80005e5a:	c901                	beqz	a0,80005e6a <sys_exec+0xfa>
    kfree(argv[i]);
    80005e5c:	ffffb097          	auipc	ra,0xffffb
    80005e60:	bee080e7          	jalr	-1042(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e64:	04a1                	addi	s1,s1,8
    80005e66:	ff3499e3          	bne	s1,s3,80005e58 <sys_exec+0xe8>
  return ret;
    80005e6a:	854a                	mv	a0,s2
    80005e6c:	74ba                	ld	s1,424(sp)
    80005e6e:	791a                	ld	s2,416(sp)
    80005e70:	69fa                	ld	s3,408(sp)
    80005e72:	6a5a                	ld	s4,400(sp)
    80005e74:	a031                	j	80005e80 <sys_exec+0x110>
  return -1;
    80005e76:	557d                	li	a0,-1
    80005e78:	74ba                	ld	s1,424(sp)
    80005e7a:	791a                	ld	s2,416(sp)
    80005e7c:	69fa                	ld	s3,408(sp)
    80005e7e:	6a5a                	ld	s4,400(sp)
}
    80005e80:	70fa                	ld	ra,440(sp)
    80005e82:	745a                	ld	s0,432(sp)
    80005e84:	6139                	addi	sp,sp,448
    80005e86:	8082                	ret

0000000080005e88 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e88:	7139                	addi	sp,sp,-64
    80005e8a:	fc06                	sd	ra,56(sp)
    80005e8c:	f822                	sd	s0,48(sp)
    80005e8e:	f426                	sd	s1,40(sp)
    80005e90:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e92:	ffffc097          	auipc	ra,0xffffc
    80005e96:	bb8080e7          	jalr	-1096(ra) # 80001a4a <myproc>
    80005e9a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e9c:	fd840593          	addi	a1,s0,-40
    80005ea0:	4501                	li	a0,0
    80005ea2:	ffffd097          	auipc	ra,0xffffd
    80005ea6:	ee6080e7          	jalr	-282(ra) # 80002d88 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005eaa:	fc840593          	addi	a1,s0,-56
    80005eae:	fd040513          	addi	a0,s0,-48
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	d50080e7          	jalr	-688(ra) # 80004c02 <pipealloc>
    return -1;
    80005eba:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ebc:	0c054463          	bltz	a0,80005f84 <sys_pipe+0xfc>
  fd0 = -1;
    80005ec0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ec4:	fd043503          	ld	a0,-48(s0)
    80005ec8:	fffff097          	auipc	ra,0xfffff
    80005ecc:	4e0080e7          	jalr	1248(ra) # 800053a8 <fdalloc>
    80005ed0:	fca42223          	sw	a0,-60(s0)
    80005ed4:	08054b63          	bltz	a0,80005f6a <sys_pipe+0xe2>
    80005ed8:	fc843503          	ld	a0,-56(s0)
    80005edc:	fffff097          	auipc	ra,0xfffff
    80005ee0:	4cc080e7          	jalr	1228(ra) # 800053a8 <fdalloc>
    80005ee4:	fca42023          	sw	a0,-64(s0)
    80005ee8:	06054863          	bltz	a0,80005f58 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005eec:	4691                	li	a3,4
    80005eee:	fc440613          	addi	a2,s0,-60
    80005ef2:	fd843583          	ld	a1,-40(s0)
    80005ef6:	68a8                	ld	a0,80(s1)
    80005ef8:	ffffb097          	auipc	ra,0xffffb
    80005efc:	7ea080e7          	jalr	2026(ra) # 800016e2 <copyout>
    80005f00:	02054063          	bltz	a0,80005f20 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f04:	4691                	li	a3,4
    80005f06:	fc040613          	addi	a2,s0,-64
    80005f0a:	fd843583          	ld	a1,-40(s0)
    80005f0e:	0591                	addi	a1,a1,4
    80005f10:	68a8                	ld	a0,80(s1)
    80005f12:	ffffb097          	auipc	ra,0xffffb
    80005f16:	7d0080e7          	jalr	2000(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f1a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f1c:	06055463          	bgez	a0,80005f84 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f20:	fc442783          	lw	a5,-60(s0)
    80005f24:	07e9                	addi	a5,a5,26
    80005f26:	078e                	slli	a5,a5,0x3
    80005f28:	97a6                	add	a5,a5,s1
    80005f2a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f2e:	fc042783          	lw	a5,-64(s0)
    80005f32:	07e9                	addi	a5,a5,26
    80005f34:	078e                	slli	a5,a5,0x3
    80005f36:	94be                	add	s1,s1,a5
    80005f38:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f3c:	fd043503          	ld	a0,-48(s0)
    80005f40:	fffff097          	auipc	ra,0xfffff
    80005f44:	954080e7          	jalr	-1708(ra) # 80004894 <fileclose>
    fileclose(wf);
    80005f48:	fc843503          	ld	a0,-56(s0)
    80005f4c:	fffff097          	auipc	ra,0xfffff
    80005f50:	948080e7          	jalr	-1720(ra) # 80004894 <fileclose>
    return -1;
    80005f54:	57fd                	li	a5,-1
    80005f56:	a03d                	j	80005f84 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005f58:	fc442783          	lw	a5,-60(s0)
    80005f5c:	0007c763          	bltz	a5,80005f6a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005f60:	07e9                	addi	a5,a5,26
    80005f62:	078e                	slli	a5,a5,0x3
    80005f64:	97a6                	add	a5,a5,s1
    80005f66:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005f6a:	fd043503          	ld	a0,-48(s0)
    80005f6e:	fffff097          	auipc	ra,0xfffff
    80005f72:	926080e7          	jalr	-1754(ra) # 80004894 <fileclose>
    fileclose(wf);
    80005f76:	fc843503          	ld	a0,-56(s0)
    80005f7a:	fffff097          	auipc	ra,0xfffff
    80005f7e:	91a080e7          	jalr	-1766(ra) # 80004894 <fileclose>
    return -1;
    80005f82:	57fd                	li	a5,-1
}
    80005f84:	853e                	mv	a0,a5
    80005f86:	70e2                	ld	ra,56(sp)
    80005f88:	7442                	ld	s0,48(sp)
    80005f8a:	74a2                	ld	s1,40(sp)
    80005f8c:	6121                	addi	sp,sp,64
    80005f8e:	8082                	ret

0000000080005f90 <kernelvec>:
    80005f90:	7111                	addi	sp,sp,-256
    80005f92:	e006                	sd	ra,0(sp)
    80005f94:	e40a                	sd	sp,8(sp)
    80005f96:	e80e                	sd	gp,16(sp)
    80005f98:	ec12                	sd	tp,24(sp)
    80005f9a:	f016                	sd	t0,32(sp)
    80005f9c:	f41a                	sd	t1,40(sp)
    80005f9e:	f81e                	sd	t2,48(sp)
    80005fa0:	fc22                	sd	s0,56(sp)
    80005fa2:	e0a6                	sd	s1,64(sp)
    80005fa4:	e4aa                	sd	a0,72(sp)
    80005fa6:	e8ae                	sd	a1,80(sp)
    80005fa8:	ecb2                	sd	a2,88(sp)
    80005faa:	f0b6                	sd	a3,96(sp)
    80005fac:	f4ba                	sd	a4,104(sp)
    80005fae:	f8be                	sd	a5,112(sp)
    80005fb0:	fcc2                	sd	a6,120(sp)
    80005fb2:	e146                	sd	a7,128(sp)
    80005fb4:	e54a                	sd	s2,136(sp)
    80005fb6:	e94e                	sd	s3,144(sp)
    80005fb8:	ed52                	sd	s4,152(sp)
    80005fba:	f156                	sd	s5,160(sp)
    80005fbc:	f55a                	sd	s6,168(sp)
    80005fbe:	f95e                	sd	s7,176(sp)
    80005fc0:	fd62                	sd	s8,184(sp)
    80005fc2:	e1e6                	sd	s9,192(sp)
    80005fc4:	e5ea                	sd	s10,200(sp)
    80005fc6:	e9ee                	sd	s11,208(sp)
    80005fc8:	edf2                	sd	t3,216(sp)
    80005fca:	f1f6                	sd	t4,224(sp)
    80005fcc:	f5fa                	sd	t5,232(sp)
    80005fce:	f9fe                	sd	t6,240(sp)
    80005fd0:	bc7fc0ef          	jal	80002b96 <kerneltrap>
    80005fd4:	6082                	ld	ra,0(sp)
    80005fd6:	6122                	ld	sp,8(sp)
    80005fd8:	61c2                	ld	gp,16(sp)
    80005fda:	7282                	ld	t0,32(sp)
    80005fdc:	7322                	ld	t1,40(sp)
    80005fde:	73c2                	ld	t2,48(sp)
    80005fe0:	7462                	ld	s0,56(sp)
    80005fe2:	6486                	ld	s1,64(sp)
    80005fe4:	6526                	ld	a0,72(sp)
    80005fe6:	65c6                	ld	a1,80(sp)
    80005fe8:	6666                	ld	a2,88(sp)
    80005fea:	7686                	ld	a3,96(sp)
    80005fec:	7726                	ld	a4,104(sp)
    80005fee:	77c6                	ld	a5,112(sp)
    80005ff0:	7866                	ld	a6,120(sp)
    80005ff2:	688a                	ld	a7,128(sp)
    80005ff4:	692a                	ld	s2,136(sp)
    80005ff6:	69ca                	ld	s3,144(sp)
    80005ff8:	6a6a                	ld	s4,152(sp)
    80005ffa:	7a8a                	ld	s5,160(sp)
    80005ffc:	7b2a                	ld	s6,168(sp)
    80005ffe:	7bca                	ld	s7,176(sp)
    80006000:	7c6a                	ld	s8,184(sp)
    80006002:	6c8e                	ld	s9,192(sp)
    80006004:	6d2e                	ld	s10,200(sp)
    80006006:	6dce                	ld	s11,208(sp)
    80006008:	6e6e                	ld	t3,216(sp)
    8000600a:	7e8e                	ld	t4,224(sp)
    8000600c:	7f2e                	ld	t5,232(sp)
    8000600e:	7fce                	ld	t6,240(sp)
    80006010:	6111                	addi	sp,sp,256
    80006012:	10200073          	sret
    80006016:	00000013          	nop
    8000601a:	00000013          	nop
    8000601e:	0001                	nop

0000000080006020 <timervec>:
    80006020:	34051573          	csrrw	a0,mscratch,a0
    80006024:	e10c                	sd	a1,0(a0)
    80006026:	e510                	sd	a2,8(a0)
    80006028:	e914                	sd	a3,16(a0)
    8000602a:	6d0c                	ld	a1,24(a0)
    8000602c:	7110                	ld	a2,32(a0)
    8000602e:	6194                	ld	a3,0(a1)
    80006030:	96b2                	add	a3,a3,a2
    80006032:	e194                	sd	a3,0(a1)
    80006034:	4589                	li	a1,2
    80006036:	14459073          	csrw	sip,a1
    8000603a:	6914                	ld	a3,16(a0)
    8000603c:	6510                	ld	a2,8(a0)
    8000603e:	610c                	ld	a1,0(a0)
    80006040:	34051573          	csrrw	a0,mscratch,a0
    80006044:	30200073          	mret
	...

000000008000604a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000604a:	1141                	addi	sp,sp,-16
    8000604c:	e422                	sd	s0,8(sp)
    8000604e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006050:	0c0007b7          	lui	a5,0xc000
    80006054:	4705                	li	a4,1
    80006056:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006058:	0c0007b7          	lui	a5,0xc000
    8000605c:	c3d8                	sw	a4,4(a5)
}
    8000605e:	6422                	ld	s0,8(sp)
    80006060:	0141                	addi	sp,sp,16
    80006062:	8082                	ret

0000000080006064 <plicinithart>:

void
plicinithart(void)
{
    80006064:	1141                	addi	sp,sp,-16
    80006066:	e406                	sd	ra,8(sp)
    80006068:	e022                	sd	s0,0(sp)
    8000606a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000606c:	ffffc097          	auipc	ra,0xffffc
    80006070:	9b2080e7          	jalr	-1614(ra) # 80001a1e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006074:	0085171b          	slliw	a4,a0,0x8
    80006078:	0c0027b7          	lui	a5,0xc002
    8000607c:	97ba                	add	a5,a5,a4
    8000607e:	40200713          	li	a4,1026
    80006082:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006086:	00d5151b          	slliw	a0,a0,0xd
    8000608a:	0c2017b7          	lui	a5,0xc201
    8000608e:	97aa                	add	a5,a5,a0
    80006090:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006094:	60a2                	ld	ra,8(sp)
    80006096:	6402                	ld	s0,0(sp)
    80006098:	0141                	addi	sp,sp,16
    8000609a:	8082                	ret

000000008000609c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000609c:	1141                	addi	sp,sp,-16
    8000609e:	e406                	sd	ra,8(sp)
    800060a0:	e022                	sd	s0,0(sp)
    800060a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060a4:	ffffc097          	auipc	ra,0xffffc
    800060a8:	97a080e7          	jalr	-1670(ra) # 80001a1e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060ac:	00d5151b          	slliw	a0,a0,0xd
    800060b0:	0c2017b7          	lui	a5,0xc201
    800060b4:	97aa                	add	a5,a5,a0
  return irq;
}
    800060b6:	43c8                	lw	a0,4(a5)
    800060b8:	60a2                	ld	ra,8(sp)
    800060ba:	6402                	ld	s0,0(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret

00000000800060c0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060c0:	1101                	addi	sp,sp,-32
    800060c2:	ec06                	sd	ra,24(sp)
    800060c4:	e822                	sd	s0,16(sp)
    800060c6:	e426                	sd	s1,8(sp)
    800060c8:	1000                	addi	s0,sp,32
    800060ca:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060cc:	ffffc097          	auipc	ra,0xffffc
    800060d0:	952080e7          	jalr	-1710(ra) # 80001a1e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060d4:	00d5151b          	slliw	a0,a0,0xd
    800060d8:	0c2017b7          	lui	a5,0xc201
    800060dc:	97aa                	add	a5,a5,a0
    800060de:	c3c4                	sw	s1,4(a5)
}
    800060e0:	60e2                	ld	ra,24(sp)
    800060e2:	6442                	ld	s0,16(sp)
    800060e4:	64a2                	ld	s1,8(sp)
    800060e6:	6105                	addi	sp,sp,32
    800060e8:	8082                	ret

00000000800060ea <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060ea:	1141                	addi	sp,sp,-16
    800060ec:	e406                	sd	ra,8(sp)
    800060ee:	e022                	sd	s0,0(sp)
    800060f0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060f2:	479d                	li	a5,7
    800060f4:	04a7cc63          	blt	a5,a0,8000614c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800060f8:	00022797          	auipc	a5,0x22
    800060fc:	99878793          	addi	a5,a5,-1640 # 80027a90 <disk>
    80006100:	97aa                	add	a5,a5,a0
    80006102:	0187c783          	lbu	a5,24(a5)
    80006106:	ebb9                	bnez	a5,8000615c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006108:	00451693          	slli	a3,a0,0x4
    8000610c:	00022797          	auipc	a5,0x22
    80006110:	98478793          	addi	a5,a5,-1660 # 80027a90 <disk>
    80006114:	6398                	ld	a4,0(a5)
    80006116:	9736                	add	a4,a4,a3
    80006118:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000611c:	6398                	ld	a4,0(a5)
    8000611e:	9736                	add	a4,a4,a3
    80006120:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006124:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006128:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000612c:	97aa                	add	a5,a5,a0
    8000612e:	4705                	li	a4,1
    80006130:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006134:	00022517          	auipc	a0,0x22
    80006138:	97450513          	addi	a0,a0,-1676 # 80027aa8 <disk+0x18>
    8000613c:	ffffc097          	auipc	ra,0xffffc
    80006140:	056080e7          	jalr	86(ra) # 80002192 <wakeup>
}
    80006144:	60a2                	ld	ra,8(sp)
    80006146:	6402                	ld	s0,0(sp)
    80006148:	0141                	addi	sp,sp,16
    8000614a:	8082                	ret
    panic("free_desc 1");
    8000614c:	00002517          	auipc	a0,0x2
    80006150:	4dc50513          	addi	a0,a0,1244 # 80008628 <etext+0x628>
    80006154:	ffffa097          	auipc	ra,0xffffa
    80006158:	40c080e7          	jalr	1036(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000615c:	00002517          	auipc	a0,0x2
    80006160:	4dc50513          	addi	a0,a0,1244 # 80008638 <etext+0x638>
    80006164:	ffffa097          	auipc	ra,0xffffa
    80006168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>

000000008000616c <virtio_disk_init>:
{
    8000616c:	1101                	addi	sp,sp,-32
    8000616e:	ec06                	sd	ra,24(sp)
    80006170:	e822                	sd	s0,16(sp)
    80006172:	e426                	sd	s1,8(sp)
    80006174:	e04a                	sd	s2,0(sp)
    80006176:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006178:	00002597          	auipc	a1,0x2
    8000617c:	4d058593          	addi	a1,a1,1232 # 80008648 <etext+0x648>
    80006180:	00022517          	auipc	a0,0x22
    80006184:	a3850513          	addi	a0,a0,-1480 # 80027bb8 <disk+0x128>
    80006188:	ffffb097          	auipc	ra,0xffffb
    8000618c:	a20080e7          	jalr	-1504(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006190:	100017b7          	lui	a5,0x10001
    80006194:	4398                	lw	a4,0(a5)
    80006196:	2701                	sext.w	a4,a4
    80006198:	747277b7          	lui	a5,0x74727
    8000619c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061a0:	18f71c63          	bne	a4,a5,80006338 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061a4:	100017b7          	lui	a5,0x10001
    800061a8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800061aa:	439c                	lw	a5,0(a5)
    800061ac:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061ae:	4709                	li	a4,2
    800061b0:	18e79463          	bne	a5,a4,80006338 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061b4:	100017b7          	lui	a5,0x10001
    800061b8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800061ba:	439c                	lw	a5,0(a5)
    800061bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061be:	16e79d63          	bne	a5,a4,80006338 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061c2:	100017b7          	lui	a5,0x10001
    800061c6:	47d8                	lw	a4,12(a5)
    800061c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061ca:	554d47b7          	lui	a5,0x554d4
    800061ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061d2:	16f71363          	bne	a4,a5,80006338 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d6:	100017b7          	lui	a5,0x10001
    800061da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061de:	4705                	li	a4,1
    800061e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e2:	470d                	li	a4,3
    800061e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061e6:	10001737          	lui	a4,0x10001
    800061ea:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061ec:	c7ffe737          	lui	a4,0xc7ffe
    800061f0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd6b8f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061f4:	8ef9                	and	a3,a3,a4
    800061f6:	10001737          	lui	a4,0x10001
    800061fa:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061fc:	472d                	li	a4,11
    800061fe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006200:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006204:	439c                	lw	a5,0(a5)
    80006206:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000620a:	8ba1                	andi	a5,a5,8
    8000620c:	12078e63          	beqz	a5,80006348 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006210:	100017b7          	lui	a5,0x10001
    80006214:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006218:	100017b7          	lui	a5,0x10001
    8000621c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006220:	439c                	lw	a5,0(a5)
    80006222:	2781                	sext.w	a5,a5
    80006224:	12079a63          	bnez	a5,80006358 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006228:	100017b7          	lui	a5,0x10001
    8000622c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006230:	439c                	lw	a5,0(a5)
    80006232:	2781                	sext.w	a5,a5
  if(max == 0)
    80006234:	12078a63          	beqz	a5,80006368 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006238:	471d                	li	a4,7
    8000623a:	12f77f63          	bgeu	a4,a5,80006378 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000623e:	ffffb097          	auipc	ra,0xffffb
    80006242:	90a080e7          	jalr	-1782(ra) # 80000b48 <kalloc>
    80006246:	00022497          	auipc	s1,0x22
    8000624a:	84a48493          	addi	s1,s1,-1974 # 80027a90 <disk>
    8000624e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006250:	ffffb097          	auipc	ra,0xffffb
    80006254:	8f8080e7          	jalr	-1800(ra) # 80000b48 <kalloc>
    80006258:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000625a:	ffffb097          	auipc	ra,0xffffb
    8000625e:	8ee080e7          	jalr	-1810(ra) # 80000b48 <kalloc>
    80006262:	87aa                	mv	a5,a0
    80006264:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006266:	6088                	ld	a0,0(s1)
    80006268:	12050063          	beqz	a0,80006388 <virtio_disk_init+0x21c>
    8000626c:	00022717          	auipc	a4,0x22
    80006270:	82c73703          	ld	a4,-2004(a4) # 80027a98 <disk+0x8>
    80006274:	10070a63          	beqz	a4,80006388 <virtio_disk_init+0x21c>
    80006278:	10078863          	beqz	a5,80006388 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000627c:	6605                	lui	a2,0x1
    8000627e:	4581                	li	a1,0
    80006280:	ffffb097          	auipc	ra,0xffffb
    80006284:	ab4080e7          	jalr	-1356(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006288:	00022497          	auipc	s1,0x22
    8000628c:	80848493          	addi	s1,s1,-2040 # 80027a90 <disk>
    80006290:	6605                	lui	a2,0x1
    80006292:	4581                	li	a1,0
    80006294:	6488                	ld	a0,8(s1)
    80006296:	ffffb097          	auipc	ra,0xffffb
    8000629a:	a9e080e7          	jalr	-1378(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    8000629e:	6605                	lui	a2,0x1
    800062a0:	4581                	li	a1,0
    800062a2:	6888                	ld	a0,16(s1)
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	a90080e7          	jalr	-1392(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062ac:	100017b7          	lui	a5,0x10001
    800062b0:	4721                	li	a4,8
    800062b2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800062b4:	4098                	lw	a4,0(s1)
    800062b6:	100017b7          	lui	a5,0x10001
    800062ba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800062be:	40d8                	lw	a4,4(s1)
    800062c0:	100017b7          	lui	a5,0x10001
    800062c4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062c8:	649c                	ld	a5,8(s1)
    800062ca:	0007869b          	sext.w	a3,a5
    800062ce:	10001737          	lui	a4,0x10001
    800062d2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800062d6:	9781                	srai	a5,a5,0x20
    800062d8:	10001737          	lui	a4,0x10001
    800062dc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800062e0:	689c                	ld	a5,16(s1)
    800062e2:	0007869b          	sext.w	a3,a5
    800062e6:	10001737          	lui	a4,0x10001
    800062ea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800062ee:	9781                	srai	a5,a5,0x20
    800062f0:	10001737          	lui	a4,0x10001
    800062f4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800062f8:	10001737          	lui	a4,0x10001
    800062fc:	4785                	li	a5,1
    800062fe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006300:	00f48c23          	sb	a5,24(s1)
    80006304:	00f48ca3          	sb	a5,25(s1)
    80006308:	00f48d23          	sb	a5,26(s1)
    8000630c:	00f48da3          	sb	a5,27(s1)
    80006310:	00f48e23          	sb	a5,28(s1)
    80006314:	00f48ea3          	sb	a5,29(s1)
    80006318:	00f48f23          	sb	a5,30(s1)
    8000631c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006320:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006324:	100017b7          	lui	a5,0x10001
    80006328:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000632c:	60e2                	ld	ra,24(sp)
    8000632e:	6442                	ld	s0,16(sp)
    80006330:	64a2                	ld	s1,8(sp)
    80006332:	6902                	ld	s2,0(sp)
    80006334:	6105                	addi	sp,sp,32
    80006336:	8082                	ret
    panic("could not find virtio disk");
    80006338:	00002517          	auipc	a0,0x2
    8000633c:	32050513          	addi	a0,a0,800 # 80008658 <etext+0x658>
    80006340:	ffffa097          	auipc	ra,0xffffa
    80006344:	220080e7          	jalr	544(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006348:	00002517          	auipc	a0,0x2
    8000634c:	33050513          	addi	a0,a0,816 # 80008678 <etext+0x678>
    80006350:	ffffa097          	auipc	ra,0xffffa
    80006354:	210080e7          	jalr	528(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006358:	00002517          	auipc	a0,0x2
    8000635c:	34050513          	addi	a0,a0,832 # 80008698 <etext+0x698>
    80006360:	ffffa097          	auipc	ra,0xffffa
    80006364:	200080e7          	jalr	512(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006368:	00002517          	auipc	a0,0x2
    8000636c:	35050513          	addi	a0,a0,848 # 800086b8 <etext+0x6b8>
    80006370:	ffffa097          	auipc	ra,0xffffa
    80006374:	1f0080e7          	jalr	496(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006378:	00002517          	auipc	a0,0x2
    8000637c:	36050513          	addi	a0,a0,864 # 800086d8 <etext+0x6d8>
    80006380:	ffffa097          	auipc	ra,0xffffa
    80006384:	1e0080e7          	jalr	480(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006388:	00002517          	auipc	a0,0x2
    8000638c:	37050513          	addi	a0,a0,880 # 800086f8 <etext+0x6f8>
    80006390:	ffffa097          	auipc	ra,0xffffa
    80006394:	1d0080e7          	jalr	464(ra) # 80000560 <panic>

0000000080006398 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006398:	7159                	addi	sp,sp,-112
    8000639a:	f486                	sd	ra,104(sp)
    8000639c:	f0a2                	sd	s0,96(sp)
    8000639e:	eca6                	sd	s1,88(sp)
    800063a0:	e8ca                	sd	s2,80(sp)
    800063a2:	e4ce                	sd	s3,72(sp)
    800063a4:	e0d2                	sd	s4,64(sp)
    800063a6:	fc56                	sd	s5,56(sp)
    800063a8:	f85a                	sd	s6,48(sp)
    800063aa:	f45e                	sd	s7,40(sp)
    800063ac:	f062                	sd	s8,32(sp)
    800063ae:	ec66                	sd	s9,24(sp)
    800063b0:	1880                	addi	s0,sp,112
    800063b2:	8a2a                	mv	s4,a0
    800063b4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063b6:	00c52c83          	lw	s9,12(a0)
    800063ba:	001c9c9b          	slliw	s9,s9,0x1
    800063be:	1c82                	slli	s9,s9,0x20
    800063c0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800063c4:	00021517          	auipc	a0,0x21
    800063c8:	7f450513          	addi	a0,a0,2036 # 80027bb8 <disk+0x128>
    800063cc:	ffffb097          	auipc	ra,0xffffb
    800063d0:	86c080e7          	jalr	-1940(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    800063d4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800063d8:	00021b17          	auipc	s6,0x21
    800063dc:	6b8b0b13          	addi	s6,s6,1720 # 80027a90 <disk>
  for(int i = 0; i < 3; i++){
    800063e0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063e2:	00021c17          	auipc	s8,0x21
    800063e6:	7d6c0c13          	addi	s8,s8,2006 # 80027bb8 <disk+0x128>
    800063ea:	a0ad                	j	80006454 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800063ec:	00fb0733          	add	a4,s6,a5
    800063f0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800063f4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800063f6:	0207c563          	bltz	a5,80006420 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800063fa:	2905                	addiw	s2,s2,1
    800063fc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800063fe:	05590f63          	beq	s2,s5,8000645c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006402:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006404:	00021717          	auipc	a4,0x21
    80006408:	68c70713          	addi	a4,a4,1676 # 80027a90 <disk>
    8000640c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000640e:	01874683          	lbu	a3,24(a4)
    80006412:	fee9                	bnez	a3,800063ec <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006414:	2785                	addiw	a5,a5,1
    80006416:	0705                	addi	a4,a4,1
    80006418:	fe979be3          	bne	a5,s1,8000640e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000641c:	57fd                	li	a5,-1
    8000641e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006420:	03205163          	blez	s2,80006442 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006424:	f9042503          	lw	a0,-112(s0)
    80006428:	00000097          	auipc	ra,0x0
    8000642c:	cc2080e7          	jalr	-830(ra) # 800060ea <free_desc>
      for(int j = 0; j < i; j++)
    80006430:	4785                	li	a5,1
    80006432:	0127d863          	bge	a5,s2,80006442 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006436:	f9442503          	lw	a0,-108(s0)
    8000643a:	00000097          	auipc	ra,0x0
    8000643e:	cb0080e7          	jalr	-848(ra) # 800060ea <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006442:	85e2                	mv	a1,s8
    80006444:	00021517          	auipc	a0,0x21
    80006448:	66450513          	addi	a0,a0,1636 # 80027aa8 <disk+0x18>
    8000644c:	ffffc097          	auipc	ra,0xffffc
    80006450:	ce2080e7          	jalr	-798(ra) # 8000212e <sleep>
  for(int i = 0; i < 3; i++){
    80006454:	f9040613          	addi	a2,s0,-112
    80006458:	894e                	mv	s2,s3
    8000645a:	b765                	j	80006402 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000645c:	f9042503          	lw	a0,-112(s0)
    80006460:	00451693          	slli	a3,a0,0x4

  if(write)
    80006464:	00021797          	auipc	a5,0x21
    80006468:	62c78793          	addi	a5,a5,1580 # 80027a90 <disk>
    8000646c:	00a50713          	addi	a4,a0,10
    80006470:	0712                	slli	a4,a4,0x4
    80006472:	973e                	add	a4,a4,a5
    80006474:	01703633          	snez	a2,s7
    80006478:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000647a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000647e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006482:	6398                	ld	a4,0(a5)
    80006484:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006486:	0a868613          	addi	a2,a3,168
    8000648a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000648c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000648e:	6390                	ld	a2,0(a5)
    80006490:	00d605b3          	add	a1,a2,a3
    80006494:	4741                	li	a4,16
    80006496:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006498:	4805                	li	a6,1
    8000649a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000649e:	f9442703          	lw	a4,-108(s0)
    800064a2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800064a6:	0712                	slli	a4,a4,0x4
    800064a8:	963a                	add	a2,a2,a4
    800064aa:	058a0593          	addi	a1,s4,88
    800064ae:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800064b0:	0007b883          	ld	a7,0(a5)
    800064b4:	9746                	add	a4,a4,a7
    800064b6:	40000613          	li	a2,1024
    800064ba:	c710                	sw	a2,8(a4)
  if(write)
    800064bc:	001bb613          	seqz	a2,s7
    800064c0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064c4:	00166613          	ori	a2,a2,1
    800064c8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800064cc:	f9842583          	lw	a1,-104(s0)
    800064d0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064d4:	00250613          	addi	a2,a0,2
    800064d8:	0612                	slli	a2,a2,0x4
    800064da:	963e                	add	a2,a2,a5
    800064dc:	577d                	li	a4,-1
    800064de:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064e2:	0592                	slli	a1,a1,0x4
    800064e4:	98ae                	add	a7,a7,a1
    800064e6:	03068713          	addi	a4,a3,48
    800064ea:	973e                	add	a4,a4,a5
    800064ec:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800064f0:	6398                	ld	a4,0(a5)
    800064f2:	972e                	add	a4,a4,a1
    800064f4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064f8:	4689                	li	a3,2
    800064fa:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800064fe:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006502:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006506:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000650a:	6794                	ld	a3,8(a5)
    8000650c:	0026d703          	lhu	a4,2(a3)
    80006510:	8b1d                	andi	a4,a4,7
    80006512:	0706                	slli	a4,a4,0x1
    80006514:	96ba                	add	a3,a3,a4
    80006516:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000651a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000651e:	6798                	ld	a4,8(a5)
    80006520:	00275783          	lhu	a5,2(a4)
    80006524:	2785                	addiw	a5,a5,1
    80006526:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000652a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000652e:	100017b7          	lui	a5,0x10001
    80006532:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006536:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000653a:	00021917          	auipc	s2,0x21
    8000653e:	67e90913          	addi	s2,s2,1662 # 80027bb8 <disk+0x128>
  while(b->disk == 1) {
    80006542:	4485                	li	s1,1
    80006544:	01079c63          	bne	a5,a6,8000655c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006548:	85ca                	mv	a1,s2
    8000654a:	8552                	mv	a0,s4
    8000654c:	ffffc097          	auipc	ra,0xffffc
    80006550:	be2080e7          	jalr	-1054(ra) # 8000212e <sleep>
  while(b->disk == 1) {
    80006554:	004a2783          	lw	a5,4(s4)
    80006558:	fe9788e3          	beq	a5,s1,80006548 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000655c:	f9042903          	lw	s2,-112(s0)
    80006560:	00290713          	addi	a4,s2,2
    80006564:	0712                	slli	a4,a4,0x4
    80006566:	00021797          	auipc	a5,0x21
    8000656a:	52a78793          	addi	a5,a5,1322 # 80027a90 <disk>
    8000656e:	97ba                	add	a5,a5,a4
    80006570:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006574:	00021997          	auipc	s3,0x21
    80006578:	51c98993          	addi	s3,s3,1308 # 80027a90 <disk>
    8000657c:	00491713          	slli	a4,s2,0x4
    80006580:	0009b783          	ld	a5,0(s3)
    80006584:	97ba                	add	a5,a5,a4
    80006586:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000658a:	854a                	mv	a0,s2
    8000658c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006590:	00000097          	auipc	ra,0x0
    80006594:	b5a080e7          	jalr	-1190(ra) # 800060ea <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006598:	8885                	andi	s1,s1,1
    8000659a:	f0ed                	bnez	s1,8000657c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000659c:	00021517          	auipc	a0,0x21
    800065a0:	61c50513          	addi	a0,a0,1564 # 80027bb8 <disk+0x128>
    800065a4:	ffffa097          	auipc	ra,0xffffa
    800065a8:	748080e7          	jalr	1864(ra) # 80000cec <release>
}
    800065ac:	70a6                	ld	ra,104(sp)
    800065ae:	7406                	ld	s0,96(sp)
    800065b0:	64e6                	ld	s1,88(sp)
    800065b2:	6946                	ld	s2,80(sp)
    800065b4:	69a6                	ld	s3,72(sp)
    800065b6:	6a06                	ld	s4,64(sp)
    800065b8:	7ae2                	ld	s5,56(sp)
    800065ba:	7b42                	ld	s6,48(sp)
    800065bc:	7ba2                	ld	s7,40(sp)
    800065be:	7c02                	ld	s8,32(sp)
    800065c0:	6ce2                	ld	s9,24(sp)
    800065c2:	6165                	addi	sp,sp,112
    800065c4:	8082                	ret

00000000800065c6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065c6:	1101                	addi	sp,sp,-32
    800065c8:	ec06                	sd	ra,24(sp)
    800065ca:	e822                	sd	s0,16(sp)
    800065cc:	e426                	sd	s1,8(sp)
    800065ce:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065d0:	00021497          	auipc	s1,0x21
    800065d4:	4c048493          	addi	s1,s1,1216 # 80027a90 <disk>
    800065d8:	00021517          	auipc	a0,0x21
    800065dc:	5e050513          	addi	a0,a0,1504 # 80027bb8 <disk+0x128>
    800065e0:	ffffa097          	auipc	ra,0xffffa
    800065e4:	658080e7          	jalr	1624(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800065e8:	100017b7          	lui	a5,0x10001
    800065ec:	53b8                	lw	a4,96(a5)
    800065ee:	8b0d                	andi	a4,a4,3
    800065f0:	100017b7          	lui	a5,0x10001
    800065f4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800065f6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800065fa:	689c                	ld	a5,16(s1)
    800065fc:	0204d703          	lhu	a4,32(s1)
    80006600:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006604:	04f70863          	beq	a4,a5,80006654 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006608:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000660c:	6898                	ld	a4,16(s1)
    8000660e:	0204d783          	lhu	a5,32(s1)
    80006612:	8b9d                	andi	a5,a5,7
    80006614:	078e                	slli	a5,a5,0x3
    80006616:	97ba                	add	a5,a5,a4
    80006618:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000661a:	00278713          	addi	a4,a5,2
    8000661e:	0712                	slli	a4,a4,0x4
    80006620:	9726                	add	a4,a4,s1
    80006622:	01074703          	lbu	a4,16(a4)
    80006626:	e721                	bnez	a4,8000666e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006628:	0789                	addi	a5,a5,2
    8000662a:	0792                	slli	a5,a5,0x4
    8000662c:	97a6                	add	a5,a5,s1
    8000662e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006630:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006634:	ffffc097          	auipc	ra,0xffffc
    80006638:	b5e080e7          	jalr	-1186(ra) # 80002192 <wakeup>

    disk.used_idx += 1;
    8000663c:	0204d783          	lhu	a5,32(s1)
    80006640:	2785                	addiw	a5,a5,1
    80006642:	17c2                	slli	a5,a5,0x30
    80006644:	93c1                	srli	a5,a5,0x30
    80006646:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000664a:	6898                	ld	a4,16(s1)
    8000664c:	00275703          	lhu	a4,2(a4)
    80006650:	faf71ce3          	bne	a4,a5,80006608 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006654:	00021517          	auipc	a0,0x21
    80006658:	56450513          	addi	a0,a0,1380 # 80027bb8 <disk+0x128>
    8000665c:	ffffa097          	auipc	ra,0xffffa
    80006660:	690080e7          	jalr	1680(ra) # 80000cec <release>
}
    80006664:	60e2                	ld	ra,24(sp)
    80006666:	6442                	ld	s0,16(sp)
    80006668:	64a2                	ld	s1,8(sp)
    8000666a:	6105                	addi	sp,sp,32
    8000666c:	8082                	ret
      panic("virtio_disk_intr status");
    8000666e:	00002517          	auipc	a0,0x2
    80006672:	0a250513          	addi	a0,a0,162 # 80008710 <etext+0x710>
    80006676:	ffffa097          	auipc	ra,0xffffa
    8000667a:	eea080e7          	jalr	-278(ra) # 80000560 <panic>
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
