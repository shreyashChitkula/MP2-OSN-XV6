
user/_alarmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:
}

volatile static int count;

void periodic()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    count = count + 1;
   8:	00001797          	auipc	a5,0x1
   c:	5787a783          	lw	a5,1400(a5) # 1580 <count>
  10:	2785                	addiw	a5,a5,1
  12:	00001717          	auipc	a4,0x1
  16:	56f72723          	sw	a5,1390(a4) # 1580 <count>
    printf("alarm!\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	c1650513          	addi	a0,a0,-1002 # c30 <malloc+0x104>
  22:	00001097          	auipc	ra,0x1
  26:	a52080e7          	jalr	-1454(ra) # a74 <printf>
    sigreturn();
  2a:	00000097          	auipc	ra,0x0
  2e:	772080e7          	jalr	1906(ra) # 79c <sigreturn>
}
  32:	60a2                	ld	ra,8(sp)
  34:	6402                	ld	s0,0(sp)
  36:	0141                	addi	sp,sp,16
  38:	8082                	ret

000000000000003a <slow_handler>:
        printf("test2 passed\n");
    }
}

void slow_handler()
{
  3a:	1101                	addi	sp,sp,-32
  3c:	ec06                	sd	ra,24(sp)
  3e:	e822                	sd	s0,16(sp)
  40:	e426                	sd	s1,8(sp)
  42:	1000                	addi	s0,sp,32
    count++;
  44:	00001497          	auipc	s1,0x1
  48:	53c48493          	addi	s1,s1,1340 # 1580 <count>
  4c:	00001797          	auipc	a5,0x1
  50:	5347a783          	lw	a5,1332(a5) # 1580 <count>
  54:	2785                	addiw	a5,a5,1
  56:	c09c                	sw	a5,0(s1)
    printf("alarm!\n");
  58:	00001517          	auipc	a0,0x1
  5c:	bd850513          	addi	a0,a0,-1064 # c30 <malloc+0x104>
  60:	00001097          	auipc	ra,0x1
  64:	a14080e7          	jalr	-1516(ra) # a74 <printf>
    if (count > 1)
  68:	4098                	lw	a4,0(s1)
  6a:	2701                	sext.w	a4,a4
  6c:	4685                	li	a3,1
  6e:	1dcd67b7          	lui	a5,0x1dcd6
  72:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd4f70>
  76:	02e6c463          	blt	a3,a4,9e <slow_handler+0x64>
        printf("test2 failed: alarm handler called more than once\n");
        exit(1);
    }
    for (int i = 0; i < 1000 * 500000; i++)
    {
        asm volatile("nop"); // avoid compiler optimizing away loop
  7a:	0001                	nop
    for (int i = 0; i < 1000 * 500000; i++)
  7c:	37fd                	addiw	a5,a5,-1
  7e:	fff5                	bnez	a5,7a <slow_handler+0x40>
    }
    sigalarm(0, 0);
  80:	4581                	li	a1,0
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	710080e7          	jalr	1808(ra) # 794 <sigalarm>
    sigreturn();
  8c:	00000097          	auipc	ra,0x0
  90:	710080e7          	jalr	1808(ra) # 79c <sigreturn>
}
  94:	60e2                	ld	ra,24(sp)
  96:	6442                	ld	s0,16(sp)
  98:	64a2                	ld	s1,8(sp)
  9a:	6105                	addi	sp,sp,32
  9c:	8082                	ret
        printf("test2 failed: alarm handler called more than once\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	b9a50513          	addi	a0,a0,-1126 # c38 <malloc+0x10c>
  a6:	00001097          	auipc	ra,0x1
  aa:	9ce080e7          	jalr	-1586(ra) # a74 <printf>
        exit(1);
  ae:	4505                	li	a0,1
  b0:	00000097          	auipc	ra,0x0
  b4:	634080e7          	jalr	1588(ra) # 6e4 <exit>

00000000000000b8 <dummy_handler>:

//
// dummy alarm handler; after running immediately uninstall
// itself and finish signal handling
void dummy_handler()
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	addi	s0,sp,16
    sigalarm(0, 0);
  c0:	4581                	li	a1,0
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	6d0080e7          	jalr	1744(ra) # 794 <sigalarm>
    sigreturn();
  cc:	00000097          	auipc	ra,0x0
  d0:	6d0080e7          	jalr	1744(ra) # 79c <sigreturn>
}
  d4:	60a2                	ld	ra,8(sp)
  d6:	6402                	ld	s0,0(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <test0>:
{
  dc:	7139                	addi	sp,sp,-64
  de:	fc06                	sd	ra,56(sp)
  e0:	f822                	sd	s0,48(sp)
  e2:	f426                	sd	s1,40(sp)
  e4:	f04a                	sd	s2,32(sp)
  e6:	ec4e                	sd	s3,24(sp)
  e8:	e852                	sd	s4,16(sp)
  ea:	e456                	sd	s5,8(sp)
  ec:	0080                	addi	s0,sp,64
    printf("test0 start\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	b8250513          	addi	a0,a0,-1150 # c70 <malloc+0x144>
  f6:	00001097          	auipc	ra,0x1
  fa:	97e080e7          	jalr	-1666(ra) # a74 <printf>
    count = 0;
  fe:	00001797          	auipc	a5,0x1
 102:	4807a123          	sw	zero,1154(a5) # 1580 <count>
    sigalarm(2, periodic);
 106:	00000597          	auipc	a1,0x0
 10a:	efa58593          	addi	a1,a1,-262 # 0 <periodic>
 10e:	4509                	li	a0,2
 110:	00000097          	auipc	ra,0x0
 114:	684080e7          	jalr	1668(ra) # 794 <sigalarm>
    for (i = 0; i < 1000 * 500000; i++)
 118:	4481                	li	s1,0
        if ((i % 1000000) == 0)
 11a:	000f4937          	lui	s2,0xf4
 11e:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2cb0>
            write(2, ".", 1);
 122:	00001a97          	auipc	s5,0x1
 126:	b5ea8a93          	addi	s5,s5,-1186 # c80 <malloc+0x154>
        if (count > 0)
 12a:	00001a17          	auipc	s4,0x1
 12e:	456a0a13          	addi	s4,s4,1110 # 1580 <count>
    for (i = 0; i < 1000 * 500000; i++)
 132:	1dcd69b7          	lui	s3,0x1dcd6
 136:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd4f70>
 13a:	a809                	j	14c <test0+0x70>
        if (count > 0)
 13c:	000a2783          	lw	a5,0(s4)
 140:	2781                	sext.w	a5,a5
 142:	02f04063          	bgtz	a5,162 <test0+0x86>
    for (i = 0; i < 1000 * 500000; i++)
 146:	2485                	addiw	s1,s1,1
 148:	01348d63          	beq	s1,s3,162 <test0+0x86>
        if ((i % 1000000) == 0)
 14c:	0324e7bb          	remw	a5,s1,s2
 150:	f7f5                	bnez	a5,13c <test0+0x60>
            write(2, ".", 1);
 152:	4605                	li	a2,1
 154:	85d6                	mv	a1,s5
 156:	4509                	li	a0,2
 158:	00000097          	auipc	ra,0x0
 15c:	5ac080e7          	jalr	1452(ra) # 704 <write>
 160:	bff1                	j	13c <test0+0x60>
    sigalarm(0, 0);
 162:	4581                	li	a1,0
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	62e080e7          	jalr	1582(ra) # 794 <sigalarm>
    if (count > 0)
 16e:	00001797          	auipc	a5,0x1
 172:	4127a783          	lw	a5,1042(a5) # 1580 <count>
 176:	02f05363          	blez	a5,19c <test0+0xc0>
        printf("test0 passed\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	b0e50513          	addi	a0,a0,-1266 # c88 <malloc+0x15c>
 182:	00001097          	auipc	ra,0x1
 186:	8f2080e7          	jalr	-1806(ra) # a74 <printf>
}
 18a:	70e2                	ld	ra,56(sp)
 18c:	7442                	ld	s0,48(sp)
 18e:	74a2                	ld	s1,40(sp)
 190:	7902                	ld	s2,32(sp)
 192:	69e2                	ld	s3,24(sp)
 194:	6a42                	ld	s4,16(sp)
 196:	6aa2                	ld	s5,8(sp)
 198:	6121                	addi	sp,sp,64
 19a:	8082                	ret
        printf("\ntest0 failed: the kernel never called the alarm handler\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	afc50513          	addi	a0,a0,-1284 # c98 <malloc+0x16c>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	8d0080e7          	jalr	-1840(ra) # a74 <printf>
}
 1ac:	bff9                	j	18a <test0+0xae>

00000000000001ae <foo>:
{
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	1000                	addi	s0,sp,32
 1b8:	84ae                	mv	s1,a1
    if ((i % 2500000) == 0)
 1ba:	002627b7          	lui	a5,0x262
 1be:	5a07879b          	addiw	a5,a5,1440 # 2625a0 <base+0x261010>
 1c2:	02f5653b          	remw	a0,a0,a5
 1c6:	c909                	beqz	a0,1d8 <foo+0x2a>
    *j += 1;
 1c8:	409c                	lw	a5,0(s1)
 1ca:	2785                	addiw	a5,a5,1
 1cc:	c09c                	sw	a5,0(s1)
}
 1ce:	60e2                	ld	ra,24(sp)
 1d0:	6442                	ld	s0,16(sp)
 1d2:	64a2                	ld	s1,8(sp)
 1d4:	6105                	addi	sp,sp,32
 1d6:	8082                	ret
        write(2, ".", 1);
 1d8:	4605                	li	a2,1
 1da:	00001597          	auipc	a1,0x1
 1de:	aa658593          	addi	a1,a1,-1370 # c80 <malloc+0x154>
 1e2:	4509                	li	a0,2
 1e4:	00000097          	auipc	ra,0x0
 1e8:	520080e7          	jalr	1312(ra) # 704 <write>
 1ec:	bff1                	j	1c8 <foo+0x1a>

00000000000001ee <test1>:
{
 1ee:	7139                	addi	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	0080                	addi	s0,sp,64
    printf("test1 start\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	ada50513          	addi	a0,a0,-1318 # cd8 <malloc+0x1ac>
 206:	00001097          	auipc	ra,0x1
 20a:	86e080e7          	jalr	-1938(ra) # a74 <printf>
    count = 0;
 20e:	00001797          	auipc	a5,0x1
 212:	3607a923          	sw	zero,882(a5) # 1580 <count>
    j = 0;
 216:	fc042623          	sw	zero,-52(s0)
    sigalarm(2, periodic);
 21a:	00000597          	auipc	a1,0x0
 21e:	de658593          	addi	a1,a1,-538 # 0 <periodic>
 222:	4509                	li	a0,2
 224:	00000097          	auipc	ra,0x0
 228:	570080e7          	jalr	1392(ra) # 794 <sigalarm>
    for (i = 0; i < 500000000; i++)
 22c:	4481                	li	s1,0
        if (count >= 10)
 22e:	00001a17          	auipc	s4,0x1
 232:	352a0a13          	addi	s4,s4,850 # 1580 <count>
 236:	49a5                	li	s3,9
    for (i = 0; i < 500000000; i++)
 238:	1dcd6937          	lui	s2,0x1dcd6
 23c:	50090913          	addi	s2,s2,1280 # 1dcd6500 <base+0x1dcd4f70>
        if (count >= 10)
 240:	000a2783          	lw	a5,0(s4)
 244:	2781                	sext.w	a5,a5
 246:	00f9cc63          	blt	s3,a5,25e <test1+0x70>
        foo(i, &j);
 24a:	fcc40593          	addi	a1,s0,-52
 24e:	8526                	mv	a0,s1
 250:	00000097          	auipc	ra,0x0
 254:	f5e080e7          	jalr	-162(ra) # 1ae <foo>
    for (i = 0; i < 500000000; i++)
 258:	2485                	addiw	s1,s1,1
 25a:	ff2493e3          	bne	s1,s2,240 <test1+0x52>
    if (count < 10)
 25e:	00001717          	auipc	a4,0x1
 262:	32272703          	lw	a4,802(a4) # 1580 <count>
 266:	47a5                	li	a5,9
 268:	02e7d663          	bge	a5,a4,294 <test1+0xa6>
    else if (i != j)
 26c:	fcc42783          	lw	a5,-52(s0)
 270:	02978b63          	beq	a5,s1,2a6 <test1+0xb8>
        printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 274:	00001517          	auipc	a0,0x1
 278:	aa450513          	addi	a0,a0,-1372 # d18 <malloc+0x1ec>
 27c:	00000097          	auipc	ra,0x0
 280:	7f8080e7          	jalr	2040(ra) # a74 <printf>
}
 284:	70e2                	ld	ra,56(sp)
 286:	7442                	ld	s0,48(sp)
 288:	74a2                	ld	s1,40(sp)
 28a:	7902                	ld	s2,32(sp)
 28c:	69e2                	ld	s3,24(sp)
 28e:	6a42                	ld	s4,16(sp)
 290:	6121                	addi	sp,sp,64
 292:	8082                	ret
        printf("\ntest1 failed: too few calls to the handler\n");
 294:	00001517          	auipc	a0,0x1
 298:	a5450513          	addi	a0,a0,-1452 # ce8 <malloc+0x1bc>
 29c:	00000097          	auipc	ra,0x0
 2a0:	7d8080e7          	jalr	2008(ra) # a74 <printf>
 2a4:	b7c5                	j	284 <test1+0x96>
        printf("test1 passed\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	ab250513          	addi	a0,a0,-1358 # d58 <malloc+0x22c>
 2ae:	00000097          	auipc	ra,0x0
 2b2:	7c6080e7          	jalr	1990(ra) # a74 <printf>
}
 2b6:	b7f9                	j	284 <test1+0x96>

00000000000002b8 <test2>:
{
 2b8:	715d                	addi	sp,sp,-80
 2ba:	e486                	sd	ra,72(sp)
 2bc:	e0a2                	sd	s0,64(sp)
 2be:	0880                	addi	s0,sp,80
    printf("test2 start\n");
 2c0:	00001517          	auipc	a0,0x1
 2c4:	aa850513          	addi	a0,a0,-1368 # d68 <malloc+0x23c>
 2c8:	00000097          	auipc	ra,0x0
 2cc:	7ac080e7          	jalr	1964(ra) # a74 <printf>
    if ((pid = fork()) < 0)
 2d0:	00000097          	auipc	ra,0x0
 2d4:	40c080e7          	jalr	1036(ra) # 6dc <fork>
 2d8:	04054763          	bltz	a0,326 <test2+0x6e>
 2dc:	fc26                	sd	s1,56(sp)
 2de:	84aa                	mv	s1,a0
    if (pid == 0)
 2e0:	e171                	bnez	a0,3a4 <test2+0xec>
 2e2:	f84a                	sd	s2,48(sp)
 2e4:	f44e                	sd	s3,40(sp)
 2e6:	f052                	sd	s4,32(sp)
 2e8:	ec56                	sd	s5,24(sp)
        count = 0;
 2ea:	00001797          	auipc	a5,0x1
 2ee:	2807ab23          	sw	zero,662(a5) # 1580 <count>
        sigalarm(2, slow_handler);
 2f2:	00000597          	auipc	a1,0x0
 2f6:	d4858593          	addi	a1,a1,-696 # 3a <slow_handler>
 2fa:	4509                	li	a0,2
 2fc:	00000097          	auipc	ra,0x0
 300:	498080e7          	jalr	1176(ra) # 794 <sigalarm>
            if ((i % 1000000) == 0)
 304:	000f4937          	lui	s2,0xf4
 308:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2cb0>
                write(2, ".", 1);
 30c:	00001a97          	auipc	s5,0x1
 310:	974a8a93          	addi	s5,s5,-1676 # c80 <malloc+0x154>
            if (count > 0)
 314:	00001a17          	auipc	s4,0x1
 318:	26ca0a13          	addi	s4,s4,620 # 1580 <count>
        for (i = 0; i < 1000 * 500000; i++)
 31c:	1dcd69b7          	lui	s3,0x1dcd6
 320:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd4f70>
 324:	a835                	j	360 <test2+0xa8>
        printf("test2: fork failed\n");
 326:	00001517          	auipc	a0,0x1
 32a:	a5250513          	addi	a0,a0,-1454 # d78 <malloc+0x24c>
 32e:	00000097          	auipc	ra,0x0
 332:	746080e7          	jalr	1862(ra) # a74 <printf>
    wait(&status);
 336:	fbc40513          	addi	a0,s0,-68
 33a:	00000097          	auipc	ra,0x0
 33e:	3b2080e7          	jalr	946(ra) # 6ec <wait>
    if (status == 0)
 342:	fbc42783          	lw	a5,-68(s0)
 346:	c3ad                	beqz	a5,3a8 <test2+0xf0>
}
 348:	60a6                	ld	ra,72(sp)
 34a:	6406                	ld	s0,64(sp)
 34c:	6161                	addi	sp,sp,80
 34e:	8082                	ret
            if (count > 0)
 350:	000a2783          	lw	a5,0(s4)
 354:	2781                	sext.w	a5,a5
 356:	02f04063          	bgtz	a5,376 <test2+0xbe>
        for (i = 0; i < 1000 * 500000; i++)
 35a:	2485                	addiw	s1,s1,1
 35c:	01348d63          	beq	s1,s3,376 <test2+0xbe>
            if ((i % 1000000) == 0)
 360:	0324e7bb          	remw	a5,s1,s2
 364:	f7f5                	bnez	a5,350 <test2+0x98>
                write(2, ".", 1);
 366:	4605                	li	a2,1
 368:	85d6                	mv	a1,s5
 36a:	4509                	li	a0,2
 36c:	00000097          	auipc	ra,0x0
 370:	398080e7          	jalr	920(ra) # 704 <write>
 374:	bff1                	j	350 <test2+0x98>
        if (count == 0)
 376:	00001797          	auipc	a5,0x1
 37a:	20a7a783          	lw	a5,522(a5) # 1580 <count>
 37e:	ef91                	bnez	a5,39a <test2+0xe2>
            printf("\ntest2 failed: alarm not called\n");
 380:	00001517          	auipc	a0,0x1
 384:	a1050513          	addi	a0,a0,-1520 # d90 <malloc+0x264>
 388:	00000097          	auipc	ra,0x0
 38c:	6ec080e7          	jalr	1772(ra) # a74 <printf>
            exit(1);
 390:	4505                	li	a0,1
 392:	00000097          	auipc	ra,0x0
 396:	352080e7          	jalr	850(ra) # 6e4 <exit>
        exit(0);
 39a:	4501                	li	a0,0
 39c:	00000097          	auipc	ra,0x0
 3a0:	348080e7          	jalr	840(ra) # 6e4 <exit>
 3a4:	74e2                	ld	s1,56(sp)
 3a6:	bf41                	j	336 <test2+0x7e>
        printf("test2 passed\n");
 3a8:	00001517          	auipc	a0,0x1
 3ac:	a1050513          	addi	a0,a0,-1520 # db8 <malloc+0x28c>
 3b0:	00000097          	auipc	ra,0x0
 3b4:	6c4080e7          	jalr	1732(ra) # a74 <printf>
}
 3b8:	bf41                	j	348 <test2+0x90>

00000000000003ba <test3>:

//
// tests that the return from sys_sigreturn() does not
// modify the a0 register
void test3()
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
    uint64 a0;

    sigalarm(1, dummy_handler);
 3c2:	00000597          	auipc	a1,0x0
 3c6:	cf658593          	addi	a1,a1,-778 # b8 <dummy_handler>
 3ca:	4505                	li	a0,1
 3cc:	00000097          	auipc	ra,0x0
 3d0:	3c8080e7          	jalr	968(ra) # 794 <sigalarm>
    printf("test3 start\n");
 3d4:	00001517          	auipc	a0,0x1
 3d8:	9f450513          	addi	a0,a0,-1548 # dc8 <malloc+0x29c>
 3dc:	00000097          	auipc	ra,0x0
 3e0:	698080e7          	jalr	1688(ra) # a74 <printf>

    asm volatile("lui a5, 0");
 3e4:	000007b7          	lui	a5,0x0
    asm volatile("addi a0, a5, 0xac" : : : "a0");
 3e8:	0ac78513          	addi	a0,a5,172 # ac <slow_handler+0x72>
 3ec:	1dcd67b7          	lui	a5,0x1dcd6
 3f0:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd4f70>
    for (int i = 0; i < 500000000; i++)
 3f4:	37fd                	addiw	a5,a5,-1
 3f6:	fffd                	bnez	a5,3f4 <test3+0x3a>
        ;
    asm volatile("mv %0, a0" : "=r"(a0));
 3f8:	872a                	mv	a4,a0

    if (a0 != 0xac)
 3fa:	0ac00793          	li	a5,172
 3fe:	00f70e63          	beq	a4,a5,41a <test3+0x60>
        printf("test3 failed: register a0 changed\n");
 402:	00001517          	auipc	a0,0x1
 406:	9d650513          	addi	a0,a0,-1578 # dd8 <malloc+0x2ac>
 40a:	00000097          	auipc	ra,0x0
 40e:	66a080e7          	jalr	1642(ra) # a74 <printf>
    else
        printf("test3 passed\n");
 412:	60a2                	ld	ra,8(sp)
 414:	6402                	ld	s0,0(sp)
 416:	0141                	addi	sp,sp,16
 418:	8082                	ret
        printf("test3 passed\n");
 41a:	00001517          	auipc	a0,0x1
 41e:	9e650513          	addi	a0,a0,-1562 # e00 <malloc+0x2d4>
 422:	00000097          	auipc	ra,0x0
 426:	652080e7          	jalr	1618(ra) # a74 <printf>
 42a:	b7e5                	j	412 <test3+0x58>

000000000000042c <main>:
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e406                	sd	ra,8(sp)
 430:	e022                	sd	s0,0(sp)
 432:	0800                	addi	s0,sp,16
    test0();
 434:	00000097          	auipc	ra,0x0
 438:	ca8080e7          	jalr	-856(ra) # dc <test0>
    test1();
 43c:	00000097          	auipc	ra,0x0
 440:	db2080e7          	jalr	-590(ra) # 1ee <test1>
    test2();
 444:	00000097          	auipc	ra,0x0
 448:	e74080e7          	jalr	-396(ra) # 2b8 <test2>
    test3();
 44c:	00000097          	auipc	ra,0x0
 450:	f6e080e7          	jalr	-146(ra) # 3ba <test3>
    exit(0);
 454:	4501                	li	a0,0
 456:	00000097          	auipc	ra,0x0
 45a:	28e080e7          	jalr	654(ra) # 6e4 <exit>

000000000000045e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 45e:	1141                	addi	sp,sp,-16
 460:	e406                	sd	ra,8(sp)
 462:	e022                	sd	s0,0(sp)
 464:	0800                	addi	s0,sp,16
  extern int main();
  main();
 466:	00000097          	auipc	ra,0x0
 46a:	fc6080e7          	jalr	-58(ra) # 42c <main>
  exit(0);
 46e:	4501                	li	a0,0
 470:	00000097          	auipc	ra,0x0
 474:	274080e7          	jalr	628(ra) # 6e4 <exit>

0000000000000478 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 478:	1141                	addi	sp,sp,-16
 47a:	e422                	sd	s0,8(sp)
 47c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 47e:	87aa                	mv	a5,a0
 480:	0585                	addi	a1,a1,1
 482:	0785                	addi	a5,a5,1
 484:	fff5c703          	lbu	a4,-1(a1)
 488:	fee78fa3          	sb	a4,-1(a5)
 48c:	fb75                	bnez	a4,480 <strcpy+0x8>
    ;
  return os;
}
 48e:	6422                	ld	s0,8(sp)
 490:	0141                	addi	sp,sp,16
 492:	8082                	ret

0000000000000494 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 494:	1141                	addi	sp,sp,-16
 496:	e422                	sd	s0,8(sp)
 498:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 49a:	00054783          	lbu	a5,0(a0)
 49e:	cb91                	beqz	a5,4b2 <strcmp+0x1e>
 4a0:	0005c703          	lbu	a4,0(a1)
 4a4:	00f71763          	bne	a4,a5,4b2 <strcmp+0x1e>
    p++, q++;
 4a8:	0505                	addi	a0,a0,1
 4aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4ac:	00054783          	lbu	a5,0(a0)
 4b0:	fbe5                	bnez	a5,4a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4b2:	0005c503          	lbu	a0,0(a1)
}
 4b6:	40a7853b          	subw	a0,a5,a0
 4ba:	6422                	ld	s0,8(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret

00000000000004c0 <strlen>:

uint
strlen(const char *s)
{
 4c0:	1141                	addi	sp,sp,-16
 4c2:	e422                	sd	s0,8(sp)
 4c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4c6:	00054783          	lbu	a5,0(a0)
 4ca:	cf91                	beqz	a5,4e6 <strlen+0x26>
 4cc:	0505                	addi	a0,a0,1
 4ce:	87aa                	mv	a5,a0
 4d0:	86be                	mv	a3,a5
 4d2:	0785                	addi	a5,a5,1
 4d4:	fff7c703          	lbu	a4,-1(a5)
 4d8:	ff65                	bnez	a4,4d0 <strlen+0x10>
 4da:	40a6853b          	subw	a0,a3,a0
 4de:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 4e0:	6422                	ld	s0,8(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret
  for(n = 0; s[n]; n++)
 4e6:	4501                	li	a0,0
 4e8:	bfe5                	j	4e0 <strlen+0x20>

00000000000004ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 4ea:	1141                	addi	sp,sp,-16
 4ec:	e422                	sd	s0,8(sp)
 4ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4f0:	ca19                	beqz	a2,506 <memset+0x1c>
 4f2:	87aa                	mv	a5,a0
 4f4:	1602                	slli	a2,a2,0x20
 4f6:	9201                	srli	a2,a2,0x20
 4f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 4fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 500:	0785                	addi	a5,a5,1
 502:	fee79de3          	bne	a5,a4,4fc <memset+0x12>
  }
  return dst;
}
 506:	6422                	ld	s0,8(sp)
 508:	0141                	addi	sp,sp,16
 50a:	8082                	ret

000000000000050c <strchr>:

char*
strchr(const char *s, char c)
{
 50c:	1141                	addi	sp,sp,-16
 50e:	e422                	sd	s0,8(sp)
 510:	0800                	addi	s0,sp,16
  for(; *s; s++)
 512:	00054783          	lbu	a5,0(a0)
 516:	cb99                	beqz	a5,52c <strchr+0x20>
    if(*s == c)
 518:	00f58763          	beq	a1,a5,526 <strchr+0x1a>
  for(; *s; s++)
 51c:	0505                	addi	a0,a0,1
 51e:	00054783          	lbu	a5,0(a0)
 522:	fbfd                	bnez	a5,518 <strchr+0xc>
      return (char*)s;
  return 0;
 524:	4501                	li	a0,0
}
 526:	6422                	ld	s0,8(sp)
 528:	0141                	addi	sp,sp,16
 52a:	8082                	ret
  return 0;
 52c:	4501                	li	a0,0
 52e:	bfe5                	j	526 <strchr+0x1a>

0000000000000530 <gets>:

char*
gets(char *buf, int max)
{
 530:	711d                	addi	sp,sp,-96
 532:	ec86                	sd	ra,88(sp)
 534:	e8a2                	sd	s0,80(sp)
 536:	e4a6                	sd	s1,72(sp)
 538:	e0ca                	sd	s2,64(sp)
 53a:	fc4e                	sd	s3,56(sp)
 53c:	f852                	sd	s4,48(sp)
 53e:	f456                	sd	s5,40(sp)
 540:	f05a                	sd	s6,32(sp)
 542:	ec5e                	sd	s7,24(sp)
 544:	1080                	addi	s0,sp,96
 546:	8baa                	mv	s7,a0
 548:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 54a:	892a                	mv	s2,a0
 54c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 54e:	4aa9                	li	s5,10
 550:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 552:	89a6                	mv	s3,s1
 554:	2485                	addiw	s1,s1,1
 556:	0344d863          	bge	s1,s4,586 <gets+0x56>
    cc = read(0, &c, 1);
 55a:	4605                	li	a2,1
 55c:	faf40593          	addi	a1,s0,-81
 560:	4501                	li	a0,0
 562:	00000097          	auipc	ra,0x0
 566:	19a080e7          	jalr	410(ra) # 6fc <read>
    if(cc < 1)
 56a:	00a05e63          	blez	a0,586 <gets+0x56>
    buf[i++] = c;
 56e:	faf44783          	lbu	a5,-81(s0)
 572:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 576:	01578763          	beq	a5,s5,584 <gets+0x54>
 57a:	0905                	addi	s2,s2,1
 57c:	fd679be3          	bne	a5,s6,552 <gets+0x22>
    buf[i++] = c;
 580:	89a6                	mv	s3,s1
 582:	a011                	j	586 <gets+0x56>
 584:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 586:	99de                	add	s3,s3,s7
 588:	00098023          	sb	zero,0(s3)
  return buf;
}
 58c:	855e                	mv	a0,s7
 58e:	60e6                	ld	ra,88(sp)
 590:	6446                	ld	s0,80(sp)
 592:	64a6                	ld	s1,72(sp)
 594:	6906                	ld	s2,64(sp)
 596:	79e2                	ld	s3,56(sp)
 598:	7a42                	ld	s4,48(sp)
 59a:	7aa2                	ld	s5,40(sp)
 59c:	7b02                	ld	s6,32(sp)
 59e:	6be2                	ld	s7,24(sp)
 5a0:	6125                	addi	sp,sp,96
 5a2:	8082                	ret

00000000000005a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 5a4:	1101                	addi	sp,sp,-32
 5a6:	ec06                	sd	ra,24(sp)
 5a8:	e822                	sd	s0,16(sp)
 5aa:	e04a                	sd	s2,0(sp)
 5ac:	1000                	addi	s0,sp,32
 5ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5b0:	4581                	li	a1,0
 5b2:	00000097          	auipc	ra,0x0
 5b6:	172080e7          	jalr	370(ra) # 724 <open>
  if(fd < 0)
 5ba:	02054663          	bltz	a0,5e6 <stat+0x42>
 5be:	e426                	sd	s1,8(sp)
 5c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5c2:	85ca                	mv	a1,s2
 5c4:	00000097          	auipc	ra,0x0
 5c8:	178080e7          	jalr	376(ra) # 73c <fstat>
 5cc:	892a                	mv	s2,a0
  close(fd);
 5ce:	8526                	mv	a0,s1
 5d0:	00000097          	auipc	ra,0x0
 5d4:	13c080e7          	jalr	316(ra) # 70c <close>
  return r;
 5d8:	64a2                	ld	s1,8(sp)
}
 5da:	854a                	mv	a0,s2
 5dc:	60e2                	ld	ra,24(sp)
 5de:	6442                	ld	s0,16(sp)
 5e0:	6902                	ld	s2,0(sp)
 5e2:	6105                	addi	sp,sp,32
 5e4:	8082                	ret
    return -1;
 5e6:	597d                	li	s2,-1
 5e8:	bfcd                	j	5da <stat+0x36>

00000000000005ea <atoi>:

int
atoi(const char *s)
{
 5ea:	1141                	addi	sp,sp,-16
 5ec:	e422                	sd	s0,8(sp)
 5ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5f0:	00054683          	lbu	a3,0(a0)
 5f4:	fd06879b          	addiw	a5,a3,-48
 5f8:	0ff7f793          	zext.b	a5,a5
 5fc:	4625                	li	a2,9
 5fe:	02f66863          	bltu	a2,a5,62e <atoi+0x44>
 602:	872a                	mv	a4,a0
  n = 0;
 604:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 606:	0705                	addi	a4,a4,1
 608:	0025179b          	slliw	a5,a0,0x2
 60c:	9fa9                	addw	a5,a5,a0
 60e:	0017979b          	slliw	a5,a5,0x1
 612:	9fb5                	addw	a5,a5,a3
 614:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 618:	00074683          	lbu	a3,0(a4)
 61c:	fd06879b          	addiw	a5,a3,-48
 620:	0ff7f793          	zext.b	a5,a5
 624:	fef671e3          	bgeu	a2,a5,606 <atoi+0x1c>
  return n;
}
 628:	6422                	ld	s0,8(sp)
 62a:	0141                	addi	sp,sp,16
 62c:	8082                	ret
  n = 0;
 62e:	4501                	li	a0,0
 630:	bfe5                	j	628 <atoi+0x3e>

0000000000000632 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 632:	1141                	addi	sp,sp,-16
 634:	e422                	sd	s0,8(sp)
 636:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 638:	02b57463          	bgeu	a0,a1,660 <memmove+0x2e>
    while(n-- > 0)
 63c:	00c05f63          	blez	a2,65a <memmove+0x28>
 640:	1602                	slli	a2,a2,0x20
 642:	9201                	srli	a2,a2,0x20
 644:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 648:	872a                	mv	a4,a0
      *dst++ = *src++;
 64a:	0585                	addi	a1,a1,1
 64c:	0705                	addi	a4,a4,1
 64e:	fff5c683          	lbu	a3,-1(a1)
 652:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 656:	fef71ae3          	bne	a4,a5,64a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 65a:	6422                	ld	s0,8(sp)
 65c:	0141                	addi	sp,sp,16
 65e:	8082                	ret
    dst += n;
 660:	00c50733          	add	a4,a0,a2
    src += n;
 664:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 666:	fec05ae3          	blez	a2,65a <memmove+0x28>
 66a:	fff6079b          	addiw	a5,a2,-1
 66e:	1782                	slli	a5,a5,0x20
 670:	9381                	srli	a5,a5,0x20
 672:	fff7c793          	not	a5,a5
 676:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 678:	15fd                	addi	a1,a1,-1
 67a:	177d                	addi	a4,a4,-1
 67c:	0005c683          	lbu	a3,0(a1)
 680:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 684:	fee79ae3          	bne	a5,a4,678 <memmove+0x46>
 688:	bfc9                	j	65a <memmove+0x28>

000000000000068a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 68a:	1141                	addi	sp,sp,-16
 68c:	e422                	sd	s0,8(sp)
 68e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 690:	ca05                	beqz	a2,6c0 <memcmp+0x36>
 692:	fff6069b          	addiw	a3,a2,-1
 696:	1682                	slli	a3,a3,0x20
 698:	9281                	srli	a3,a3,0x20
 69a:	0685                	addi	a3,a3,1
 69c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 69e:	00054783          	lbu	a5,0(a0)
 6a2:	0005c703          	lbu	a4,0(a1)
 6a6:	00e79863          	bne	a5,a4,6b6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6aa:	0505                	addi	a0,a0,1
    p2++;
 6ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6ae:	fed518e3          	bne	a0,a3,69e <memcmp+0x14>
  }
  return 0;
 6b2:	4501                	li	a0,0
 6b4:	a019                	j	6ba <memcmp+0x30>
      return *p1 - *p2;
 6b6:	40e7853b          	subw	a0,a5,a4
}
 6ba:	6422                	ld	s0,8(sp)
 6bc:	0141                	addi	sp,sp,16
 6be:	8082                	ret
  return 0;
 6c0:	4501                	li	a0,0
 6c2:	bfe5                	j	6ba <memcmp+0x30>

00000000000006c4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6c4:	1141                	addi	sp,sp,-16
 6c6:	e406                	sd	ra,8(sp)
 6c8:	e022                	sd	s0,0(sp)
 6ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6cc:	00000097          	auipc	ra,0x0
 6d0:	f66080e7          	jalr	-154(ra) # 632 <memmove>
}
 6d4:	60a2                	ld	ra,8(sp)
 6d6:	6402                	ld	s0,0(sp)
 6d8:	0141                	addi	sp,sp,16
 6da:	8082                	ret

00000000000006dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6dc:	4885                	li	a7,1
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6e4:	4889                	li	a7,2
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 6ec:	488d                	li	a7,3
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6f4:	4891                	li	a7,4
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <read>:
.global read
read:
 li a7, SYS_read
 6fc:	4895                	li	a7,5
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <write>:
.global write
write:
 li a7, SYS_write
 704:	48c1                	li	a7,16
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <close>:
.global close
close:
 li a7, SYS_close
 70c:	48d5                	li	a7,21
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <kill>:
.global kill
kill:
 li a7, SYS_kill
 714:	4899                	li	a7,6
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <exec>:
.global exec
exec:
 li a7, SYS_exec
 71c:	489d                	li	a7,7
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <open>:
.global open
open:
 li a7, SYS_open
 724:	48bd                	li	a7,15
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 72c:	48c5                	li	a7,17
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 734:	48c9                	li	a7,18
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 73c:	48a1                	li	a7,8
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <link>:
.global link
link:
 li a7, SYS_link
 744:	48cd                	li	a7,19
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 74c:	48d1                	li	a7,20
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 754:	48a5                	li	a7,9
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <dup>:
.global dup
dup:
 li a7, SYS_dup
 75c:	48a9                	li	a7,10
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 764:	48ad                	li	a7,11
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 76c:	48b1                	li	a7,12
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 774:	48b5                	li	a7,13
 ecall
 776:	00000073          	ecall
 ret
 77a:	8082                	ret

000000000000077c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 77c:	48b9                	li	a7,14
 ecall
 77e:	00000073          	ecall
 ret
 782:	8082                	ret

0000000000000784 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 784:	48d9                	li	a7,22
 ecall
 786:	00000073          	ecall
 ret
 78a:	8082                	ret

000000000000078c <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 78c:	48dd                	li	a7,23
 ecall
 78e:	00000073          	ecall
 ret
 792:	8082                	ret

0000000000000794 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 794:	48e1                	li	a7,24
 ecall
 796:	00000073          	ecall
 ret
 79a:	8082                	ret

000000000000079c <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 79c:	48e5                	li	a7,25
 ecall
 79e:	00000073          	ecall
 ret
 7a2:	8082                	ret

00000000000007a4 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 7a4:	48e9                	li	a7,26
 ecall
 7a6:	00000073          	ecall
 ret
 7aa:	8082                	ret

00000000000007ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7ac:	1101                	addi	sp,sp,-32
 7ae:	ec06                	sd	ra,24(sp)
 7b0:	e822                	sd	s0,16(sp)
 7b2:	1000                	addi	s0,sp,32
 7b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7b8:	4605                	li	a2,1
 7ba:	fef40593          	addi	a1,s0,-17
 7be:	00000097          	auipc	ra,0x0
 7c2:	f46080e7          	jalr	-186(ra) # 704 <write>
}
 7c6:	60e2                	ld	ra,24(sp)
 7c8:	6442                	ld	s0,16(sp)
 7ca:	6105                	addi	sp,sp,32
 7cc:	8082                	ret

00000000000007ce <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7ce:	7139                	addi	sp,sp,-64
 7d0:	fc06                	sd	ra,56(sp)
 7d2:	f822                	sd	s0,48(sp)
 7d4:	f426                	sd	s1,40(sp)
 7d6:	0080                	addi	s0,sp,64
 7d8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7da:	c299                	beqz	a3,7e0 <printint+0x12>
 7dc:	0805cb63          	bltz	a1,872 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7e0:	2581                	sext.w	a1,a1
  neg = 0;
 7e2:	4881                	li	a7,0
 7e4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7e8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7ea:	2601                	sext.w	a2,a2
 7ec:	00000517          	auipc	a0,0x0
 7f0:	68450513          	addi	a0,a0,1668 # e70 <digits>
 7f4:	883a                	mv	a6,a4
 7f6:	2705                	addiw	a4,a4,1
 7f8:	02c5f7bb          	remuw	a5,a1,a2
 7fc:	1782                	slli	a5,a5,0x20
 7fe:	9381                	srli	a5,a5,0x20
 800:	97aa                	add	a5,a5,a0
 802:	0007c783          	lbu	a5,0(a5)
 806:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 80a:	0005879b          	sext.w	a5,a1
 80e:	02c5d5bb          	divuw	a1,a1,a2
 812:	0685                	addi	a3,a3,1
 814:	fec7f0e3          	bgeu	a5,a2,7f4 <printint+0x26>
  if(neg)
 818:	00088c63          	beqz	a7,830 <printint+0x62>
    buf[i++] = '-';
 81c:	fd070793          	addi	a5,a4,-48
 820:	00878733          	add	a4,a5,s0
 824:	02d00793          	li	a5,45
 828:	fef70823          	sb	a5,-16(a4)
 82c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 830:	02e05c63          	blez	a4,868 <printint+0x9a>
 834:	f04a                	sd	s2,32(sp)
 836:	ec4e                	sd	s3,24(sp)
 838:	fc040793          	addi	a5,s0,-64
 83c:	00e78933          	add	s2,a5,a4
 840:	fff78993          	addi	s3,a5,-1
 844:	99ba                	add	s3,s3,a4
 846:	377d                	addiw	a4,a4,-1
 848:	1702                	slli	a4,a4,0x20
 84a:	9301                	srli	a4,a4,0x20
 84c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 850:	fff94583          	lbu	a1,-1(s2)
 854:	8526                	mv	a0,s1
 856:	00000097          	auipc	ra,0x0
 85a:	f56080e7          	jalr	-170(ra) # 7ac <putc>
  while(--i >= 0)
 85e:	197d                	addi	s2,s2,-1
 860:	ff3918e3          	bne	s2,s3,850 <printint+0x82>
 864:	7902                	ld	s2,32(sp)
 866:	69e2                	ld	s3,24(sp)
}
 868:	70e2                	ld	ra,56(sp)
 86a:	7442                	ld	s0,48(sp)
 86c:	74a2                	ld	s1,40(sp)
 86e:	6121                	addi	sp,sp,64
 870:	8082                	ret
    x = -xx;
 872:	40b005bb          	negw	a1,a1
    neg = 1;
 876:	4885                	li	a7,1
    x = -xx;
 878:	b7b5                	j	7e4 <printint+0x16>

000000000000087a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 87a:	715d                	addi	sp,sp,-80
 87c:	e486                	sd	ra,72(sp)
 87e:	e0a2                	sd	s0,64(sp)
 880:	f84a                	sd	s2,48(sp)
 882:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 884:	0005c903          	lbu	s2,0(a1)
 888:	1a090a63          	beqz	s2,a3c <vprintf+0x1c2>
 88c:	fc26                	sd	s1,56(sp)
 88e:	f44e                	sd	s3,40(sp)
 890:	f052                	sd	s4,32(sp)
 892:	ec56                	sd	s5,24(sp)
 894:	e85a                	sd	s6,16(sp)
 896:	e45e                	sd	s7,8(sp)
 898:	8aaa                	mv	s5,a0
 89a:	8bb2                	mv	s7,a2
 89c:	00158493          	addi	s1,a1,1
  state = 0;
 8a0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8a2:	02500a13          	li	s4,37
 8a6:	4b55                	li	s6,21
 8a8:	a839                	j	8c6 <vprintf+0x4c>
        putc(fd, c);
 8aa:	85ca                	mv	a1,s2
 8ac:	8556                	mv	a0,s5
 8ae:	00000097          	auipc	ra,0x0
 8b2:	efe080e7          	jalr	-258(ra) # 7ac <putc>
 8b6:	a019                	j	8bc <vprintf+0x42>
    } else if(state == '%'){
 8b8:	01498d63          	beq	s3,s4,8d2 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 8bc:	0485                	addi	s1,s1,1
 8be:	fff4c903          	lbu	s2,-1(s1)
 8c2:	16090763          	beqz	s2,a30 <vprintf+0x1b6>
    if(state == 0){
 8c6:	fe0999e3          	bnez	s3,8b8 <vprintf+0x3e>
      if(c == '%'){
 8ca:	ff4910e3          	bne	s2,s4,8aa <vprintf+0x30>
        state = '%';
 8ce:	89d2                	mv	s3,s4
 8d0:	b7f5                	j	8bc <vprintf+0x42>
      if(c == 'd'){
 8d2:	13490463          	beq	s2,s4,9fa <vprintf+0x180>
 8d6:	f9d9079b          	addiw	a5,s2,-99
 8da:	0ff7f793          	zext.b	a5,a5
 8de:	12fb6763          	bltu	s6,a5,a0c <vprintf+0x192>
 8e2:	f9d9079b          	addiw	a5,s2,-99
 8e6:	0ff7f713          	zext.b	a4,a5
 8ea:	12eb6163          	bltu	s6,a4,a0c <vprintf+0x192>
 8ee:	00271793          	slli	a5,a4,0x2
 8f2:	00000717          	auipc	a4,0x0
 8f6:	52670713          	addi	a4,a4,1318 # e18 <malloc+0x2ec>
 8fa:	97ba                	add	a5,a5,a4
 8fc:	439c                	lw	a5,0(a5)
 8fe:	97ba                	add	a5,a5,a4
 900:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 902:	008b8913          	addi	s2,s7,8
 906:	4685                	li	a3,1
 908:	4629                	li	a2,10
 90a:	000ba583          	lw	a1,0(s7)
 90e:	8556                	mv	a0,s5
 910:	00000097          	auipc	ra,0x0
 914:	ebe080e7          	jalr	-322(ra) # 7ce <printint>
 918:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 91a:	4981                	li	s3,0
 91c:	b745                	j	8bc <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 91e:	008b8913          	addi	s2,s7,8
 922:	4681                	li	a3,0
 924:	4629                	li	a2,10
 926:	000ba583          	lw	a1,0(s7)
 92a:	8556                	mv	a0,s5
 92c:	00000097          	auipc	ra,0x0
 930:	ea2080e7          	jalr	-350(ra) # 7ce <printint>
 934:	8bca                	mv	s7,s2
      state = 0;
 936:	4981                	li	s3,0
 938:	b751                	j	8bc <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 93a:	008b8913          	addi	s2,s7,8
 93e:	4681                	li	a3,0
 940:	4641                	li	a2,16
 942:	000ba583          	lw	a1,0(s7)
 946:	8556                	mv	a0,s5
 948:	00000097          	auipc	ra,0x0
 94c:	e86080e7          	jalr	-378(ra) # 7ce <printint>
 950:	8bca                	mv	s7,s2
      state = 0;
 952:	4981                	li	s3,0
 954:	b7a5                	j	8bc <vprintf+0x42>
 956:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 958:	008b8c13          	addi	s8,s7,8
 95c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 960:	03000593          	li	a1,48
 964:	8556                	mv	a0,s5
 966:	00000097          	auipc	ra,0x0
 96a:	e46080e7          	jalr	-442(ra) # 7ac <putc>
  putc(fd, 'x');
 96e:	07800593          	li	a1,120
 972:	8556                	mv	a0,s5
 974:	00000097          	auipc	ra,0x0
 978:	e38080e7          	jalr	-456(ra) # 7ac <putc>
 97c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 97e:	00000b97          	auipc	s7,0x0
 982:	4f2b8b93          	addi	s7,s7,1266 # e70 <digits>
 986:	03c9d793          	srli	a5,s3,0x3c
 98a:	97de                	add	a5,a5,s7
 98c:	0007c583          	lbu	a1,0(a5)
 990:	8556                	mv	a0,s5
 992:	00000097          	auipc	ra,0x0
 996:	e1a080e7          	jalr	-486(ra) # 7ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 99a:	0992                	slli	s3,s3,0x4
 99c:	397d                	addiw	s2,s2,-1
 99e:	fe0914e3          	bnez	s2,986 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 9a2:	8be2                	mv	s7,s8
      state = 0;
 9a4:	4981                	li	s3,0
 9a6:	6c02                	ld	s8,0(sp)
 9a8:	bf11                	j	8bc <vprintf+0x42>
        s = va_arg(ap, char*);
 9aa:	008b8993          	addi	s3,s7,8
 9ae:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 9b2:	02090163          	beqz	s2,9d4 <vprintf+0x15a>
        while(*s != 0){
 9b6:	00094583          	lbu	a1,0(s2)
 9ba:	c9a5                	beqz	a1,a2a <vprintf+0x1b0>
          putc(fd, *s);
 9bc:	8556                	mv	a0,s5
 9be:	00000097          	auipc	ra,0x0
 9c2:	dee080e7          	jalr	-530(ra) # 7ac <putc>
          s++;
 9c6:	0905                	addi	s2,s2,1
        while(*s != 0){
 9c8:	00094583          	lbu	a1,0(s2)
 9cc:	f9e5                	bnez	a1,9bc <vprintf+0x142>
        s = va_arg(ap, char*);
 9ce:	8bce                	mv	s7,s3
      state = 0;
 9d0:	4981                	li	s3,0
 9d2:	b5ed                	j	8bc <vprintf+0x42>
          s = "(null)";
 9d4:	00000917          	auipc	s2,0x0
 9d8:	43c90913          	addi	s2,s2,1084 # e10 <malloc+0x2e4>
        while(*s != 0){
 9dc:	02800593          	li	a1,40
 9e0:	bff1                	j	9bc <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 9e2:	008b8913          	addi	s2,s7,8
 9e6:	000bc583          	lbu	a1,0(s7)
 9ea:	8556                	mv	a0,s5
 9ec:	00000097          	auipc	ra,0x0
 9f0:	dc0080e7          	jalr	-576(ra) # 7ac <putc>
 9f4:	8bca                	mv	s7,s2
      state = 0;
 9f6:	4981                	li	s3,0
 9f8:	b5d1                	j	8bc <vprintf+0x42>
        putc(fd, c);
 9fa:	02500593          	li	a1,37
 9fe:	8556                	mv	a0,s5
 a00:	00000097          	auipc	ra,0x0
 a04:	dac080e7          	jalr	-596(ra) # 7ac <putc>
      state = 0;
 a08:	4981                	li	s3,0
 a0a:	bd4d                	j	8bc <vprintf+0x42>
        putc(fd, '%');
 a0c:	02500593          	li	a1,37
 a10:	8556                	mv	a0,s5
 a12:	00000097          	auipc	ra,0x0
 a16:	d9a080e7          	jalr	-614(ra) # 7ac <putc>
        putc(fd, c);
 a1a:	85ca                	mv	a1,s2
 a1c:	8556                	mv	a0,s5
 a1e:	00000097          	auipc	ra,0x0
 a22:	d8e080e7          	jalr	-626(ra) # 7ac <putc>
      state = 0;
 a26:	4981                	li	s3,0
 a28:	bd51                	j	8bc <vprintf+0x42>
        s = va_arg(ap, char*);
 a2a:	8bce                	mv	s7,s3
      state = 0;
 a2c:	4981                	li	s3,0
 a2e:	b579                	j	8bc <vprintf+0x42>
 a30:	74e2                	ld	s1,56(sp)
 a32:	79a2                	ld	s3,40(sp)
 a34:	7a02                	ld	s4,32(sp)
 a36:	6ae2                	ld	s5,24(sp)
 a38:	6b42                	ld	s6,16(sp)
 a3a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 a3c:	60a6                	ld	ra,72(sp)
 a3e:	6406                	ld	s0,64(sp)
 a40:	7942                	ld	s2,48(sp)
 a42:	6161                	addi	sp,sp,80
 a44:	8082                	ret

0000000000000a46 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a46:	715d                	addi	sp,sp,-80
 a48:	ec06                	sd	ra,24(sp)
 a4a:	e822                	sd	s0,16(sp)
 a4c:	1000                	addi	s0,sp,32
 a4e:	e010                	sd	a2,0(s0)
 a50:	e414                	sd	a3,8(s0)
 a52:	e818                	sd	a4,16(s0)
 a54:	ec1c                	sd	a5,24(s0)
 a56:	03043023          	sd	a6,32(s0)
 a5a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a5e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a62:	8622                	mv	a2,s0
 a64:	00000097          	auipc	ra,0x0
 a68:	e16080e7          	jalr	-490(ra) # 87a <vprintf>
}
 a6c:	60e2                	ld	ra,24(sp)
 a6e:	6442                	ld	s0,16(sp)
 a70:	6161                	addi	sp,sp,80
 a72:	8082                	ret

0000000000000a74 <printf>:

void
printf(const char *fmt, ...)
{
 a74:	711d                	addi	sp,sp,-96
 a76:	ec06                	sd	ra,24(sp)
 a78:	e822                	sd	s0,16(sp)
 a7a:	1000                	addi	s0,sp,32
 a7c:	e40c                	sd	a1,8(s0)
 a7e:	e810                	sd	a2,16(s0)
 a80:	ec14                	sd	a3,24(s0)
 a82:	f018                	sd	a4,32(s0)
 a84:	f41c                	sd	a5,40(s0)
 a86:	03043823          	sd	a6,48(s0)
 a8a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a8e:	00840613          	addi	a2,s0,8
 a92:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a96:	85aa                	mv	a1,a0
 a98:	4505                	li	a0,1
 a9a:	00000097          	auipc	ra,0x0
 a9e:	de0080e7          	jalr	-544(ra) # 87a <vprintf>
}
 aa2:	60e2                	ld	ra,24(sp)
 aa4:	6442                	ld	s0,16(sp)
 aa6:	6125                	addi	sp,sp,96
 aa8:	8082                	ret

0000000000000aaa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aaa:	1141                	addi	sp,sp,-16
 aac:	e422                	sd	s0,8(sp)
 aae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ab0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab4:	00001797          	auipc	a5,0x1
 ab8:	ad47b783          	ld	a5,-1324(a5) # 1588 <freep>
 abc:	a02d                	j	ae6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 abe:	4618                	lw	a4,8(a2)
 ac0:	9f2d                	addw	a4,a4,a1
 ac2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ac6:	6398                	ld	a4,0(a5)
 ac8:	6310                	ld	a2,0(a4)
 aca:	a83d                	j	b08 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 acc:	ff852703          	lw	a4,-8(a0)
 ad0:	9f31                	addw	a4,a4,a2
 ad2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 ad4:	ff053683          	ld	a3,-16(a0)
 ad8:	a091                	j	b1c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ada:	6398                	ld	a4,0(a5)
 adc:	00e7e463          	bltu	a5,a4,ae4 <free+0x3a>
 ae0:	00e6ea63          	bltu	a3,a4,af4 <free+0x4a>
{
 ae4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae6:	fed7fae3          	bgeu	a5,a3,ada <free+0x30>
 aea:	6398                	ld	a4,0(a5)
 aec:	00e6e463          	bltu	a3,a4,af4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 af0:	fee7eae3          	bltu	a5,a4,ae4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 af4:	ff852583          	lw	a1,-8(a0)
 af8:	6390                	ld	a2,0(a5)
 afa:	02059813          	slli	a6,a1,0x20
 afe:	01c85713          	srli	a4,a6,0x1c
 b02:	9736                	add	a4,a4,a3
 b04:	fae60de3          	beq	a2,a4,abe <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b08:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b0c:	4790                	lw	a2,8(a5)
 b0e:	02061593          	slli	a1,a2,0x20
 b12:	01c5d713          	srli	a4,a1,0x1c
 b16:	973e                	add	a4,a4,a5
 b18:	fae68ae3          	beq	a3,a4,acc <free+0x22>
    p->s.ptr = bp->s.ptr;
 b1c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b1e:	00001717          	auipc	a4,0x1
 b22:	a6f73523          	sd	a5,-1430(a4) # 1588 <freep>
}
 b26:	6422                	ld	s0,8(sp)
 b28:	0141                	addi	sp,sp,16
 b2a:	8082                	ret

0000000000000b2c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b2c:	7139                	addi	sp,sp,-64
 b2e:	fc06                	sd	ra,56(sp)
 b30:	f822                	sd	s0,48(sp)
 b32:	f426                	sd	s1,40(sp)
 b34:	ec4e                	sd	s3,24(sp)
 b36:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b38:	02051493          	slli	s1,a0,0x20
 b3c:	9081                	srli	s1,s1,0x20
 b3e:	04bd                	addi	s1,s1,15
 b40:	8091                	srli	s1,s1,0x4
 b42:	0014899b          	addiw	s3,s1,1
 b46:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b48:	00001517          	auipc	a0,0x1
 b4c:	a4053503          	ld	a0,-1472(a0) # 1588 <freep>
 b50:	c915                	beqz	a0,b84 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b52:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b54:	4798                	lw	a4,8(a5)
 b56:	08977e63          	bgeu	a4,s1,bf2 <malloc+0xc6>
 b5a:	f04a                	sd	s2,32(sp)
 b5c:	e852                	sd	s4,16(sp)
 b5e:	e456                	sd	s5,8(sp)
 b60:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 b62:	8a4e                	mv	s4,s3
 b64:	0009871b          	sext.w	a4,s3
 b68:	6685                	lui	a3,0x1
 b6a:	00d77363          	bgeu	a4,a3,b70 <malloc+0x44>
 b6e:	6a05                	lui	s4,0x1
 b70:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b74:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b78:	00001917          	auipc	s2,0x1
 b7c:	a1090913          	addi	s2,s2,-1520 # 1588 <freep>
  if(p == (char*)-1)
 b80:	5afd                	li	s5,-1
 b82:	a091                	j	bc6 <malloc+0x9a>
 b84:	f04a                	sd	s2,32(sp)
 b86:	e852                	sd	s4,16(sp)
 b88:	e456                	sd	s5,8(sp)
 b8a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b8c:	00001797          	auipc	a5,0x1
 b90:	a0478793          	addi	a5,a5,-1532 # 1590 <base>
 b94:	00001717          	auipc	a4,0x1
 b98:	9ef73a23          	sd	a5,-1548(a4) # 1588 <freep>
 b9c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b9e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ba2:	b7c1                	j	b62 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 ba4:	6398                	ld	a4,0(a5)
 ba6:	e118                	sd	a4,0(a0)
 ba8:	a08d                	j	c0a <malloc+0xde>
  hp->s.size = nu;
 baa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bae:	0541                	addi	a0,a0,16
 bb0:	00000097          	auipc	ra,0x0
 bb4:	efa080e7          	jalr	-262(ra) # aaa <free>
  return freep;
 bb8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 bbc:	c13d                	beqz	a0,c22 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bbe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bc0:	4798                	lw	a4,8(a5)
 bc2:	02977463          	bgeu	a4,s1,bea <malloc+0xbe>
    if(p == freep)
 bc6:	00093703          	ld	a4,0(s2)
 bca:	853e                	mv	a0,a5
 bcc:	fef719e3          	bne	a4,a5,bbe <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 bd0:	8552                	mv	a0,s4
 bd2:	00000097          	auipc	ra,0x0
 bd6:	b9a080e7          	jalr	-1126(ra) # 76c <sbrk>
  if(p == (char*)-1)
 bda:	fd5518e3          	bne	a0,s5,baa <malloc+0x7e>
        return 0;
 bde:	4501                	li	a0,0
 be0:	7902                	ld	s2,32(sp)
 be2:	6a42                	ld	s4,16(sp)
 be4:	6aa2                	ld	s5,8(sp)
 be6:	6b02                	ld	s6,0(sp)
 be8:	a03d                	j	c16 <malloc+0xea>
 bea:	7902                	ld	s2,32(sp)
 bec:	6a42                	ld	s4,16(sp)
 bee:	6aa2                	ld	s5,8(sp)
 bf0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 bf2:	fae489e3          	beq	s1,a4,ba4 <malloc+0x78>
        p->s.size -= nunits;
 bf6:	4137073b          	subw	a4,a4,s3
 bfa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bfc:	02071693          	slli	a3,a4,0x20
 c00:	01c6d713          	srli	a4,a3,0x1c
 c04:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c06:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c0a:	00001717          	auipc	a4,0x1
 c0e:	96a73f23          	sd	a0,-1666(a4) # 1588 <freep>
      return (void*)(p + 1);
 c12:	01078513          	addi	a0,a5,16
  }
}
 c16:	70e2                	ld	ra,56(sp)
 c18:	7442                	ld	s0,48(sp)
 c1a:	74a2                	ld	s1,40(sp)
 c1c:	69e2                	ld	s3,24(sp)
 c1e:	6121                	addi	sp,sp,64
 c20:	8082                	ret
 c22:	7902                	ld	s2,32(sp)
 c24:	6a42                	ld	s4,16(sp)
 c26:	6aa2                	ld	s5,8(sp)
 c28:	6b02                	ld	s6,0(sp)
 c2a:	b7f5                	j	c16 <malloc+0xea>
