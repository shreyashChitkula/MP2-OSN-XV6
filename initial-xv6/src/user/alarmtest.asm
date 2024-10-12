
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
  1e:	c1650513          	addi	a0,a0,-1002 # c30 <malloc+0x10c>
  22:	00001097          	auipc	ra,0x1
  26:	a4a080e7          	jalr	-1462(ra) # a6c <printf>
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
  5c:	bd850513          	addi	a0,a0,-1064 # c30 <malloc+0x10c>
  60:	00001097          	auipc	ra,0x1
  64:	a0c080e7          	jalr	-1524(ra) # a6c <printf>
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
  a2:	b9a50513          	addi	a0,a0,-1126 # c38 <malloc+0x114>
  a6:	00001097          	auipc	ra,0x1
  aa:	9c6080e7          	jalr	-1594(ra) # a6c <printf>
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
  f2:	b8250513          	addi	a0,a0,-1150 # c70 <malloc+0x14c>
  f6:	00001097          	auipc	ra,0x1
  fa:	976080e7          	jalr	-1674(ra) # a6c <printf>
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
 126:	b5ea8a93          	addi	s5,s5,-1186 # c80 <malloc+0x15c>
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
 17e:	b0e50513          	addi	a0,a0,-1266 # c88 <malloc+0x164>
 182:	00001097          	auipc	ra,0x1
 186:	8ea080e7          	jalr	-1814(ra) # a6c <printf>
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
 1a0:	afc50513          	addi	a0,a0,-1284 # c98 <malloc+0x174>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	8c8080e7          	jalr	-1848(ra) # a6c <printf>
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
 1de:	aa658593          	addi	a1,a1,-1370 # c80 <malloc+0x15c>
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
 202:	ada50513          	addi	a0,a0,-1318 # cd8 <malloc+0x1b4>
 206:	00001097          	auipc	ra,0x1
 20a:	866080e7          	jalr	-1946(ra) # a6c <printf>
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
 278:	aa450513          	addi	a0,a0,-1372 # d18 <malloc+0x1f4>
 27c:	00000097          	auipc	ra,0x0
 280:	7f0080e7          	jalr	2032(ra) # a6c <printf>
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
 298:	a5450513          	addi	a0,a0,-1452 # ce8 <malloc+0x1c4>
 29c:	00000097          	auipc	ra,0x0
 2a0:	7d0080e7          	jalr	2000(ra) # a6c <printf>
 2a4:	b7c5                	j	284 <test1+0x96>
        printf("test1 passed\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	ab250513          	addi	a0,a0,-1358 # d58 <malloc+0x234>
 2ae:	00000097          	auipc	ra,0x0
 2b2:	7be080e7          	jalr	1982(ra) # a6c <printf>
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
 2c4:	aa850513          	addi	a0,a0,-1368 # d68 <malloc+0x244>
 2c8:	00000097          	auipc	ra,0x0
 2cc:	7a4080e7          	jalr	1956(ra) # a6c <printf>
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
 310:	974a8a93          	addi	s5,s5,-1676 # c80 <malloc+0x15c>
            if (count > 0)
 314:	00001a17          	auipc	s4,0x1
 318:	26ca0a13          	addi	s4,s4,620 # 1580 <count>
        for (i = 0; i < 1000 * 500000; i++)
 31c:	1dcd69b7          	lui	s3,0x1dcd6
 320:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd4f70>
 324:	a835                	j	360 <test2+0xa8>
        printf("test2: fork failed\n");
 326:	00001517          	auipc	a0,0x1
 32a:	a5250513          	addi	a0,a0,-1454 # d78 <malloc+0x254>
 32e:	00000097          	auipc	ra,0x0
 332:	73e080e7          	jalr	1854(ra) # a6c <printf>
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
 384:	a1050513          	addi	a0,a0,-1520 # d90 <malloc+0x26c>
 388:	00000097          	auipc	ra,0x0
 38c:	6e4080e7          	jalr	1764(ra) # a6c <printf>
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
 3ac:	a1050513          	addi	a0,a0,-1520 # db8 <malloc+0x294>
 3b0:	00000097          	auipc	ra,0x0
 3b4:	6bc080e7          	jalr	1724(ra) # a6c <printf>
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
 3d8:	9f450513          	addi	a0,a0,-1548 # dc8 <malloc+0x2a4>
 3dc:	00000097          	auipc	ra,0x0
 3e0:	690080e7          	jalr	1680(ra) # a6c <printf>

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
 406:	9d650513          	addi	a0,a0,-1578 # dd8 <malloc+0x2b4>
 40a:	00000097          	auipc	ra,0x0
 40e:	662080e7          	jalr	1634(ra) # a6c <printf>
    else
        printf("test3 passed\n");
 412:	60a2                	ld	ra,8(sp)
 414:	6402                	ld	s0,0(sp)
 416:	0141                	addi	sp,sp,16
 418:	8082                	ret
        printf("test3 passed\n");
 41a:	00001517          	auipc	a0,0x1
 41e:	9e650513          	addi	a0,a0,-1562 # e00 <malloc+0x2dc>
 422:	00000097          	auipc	ra,0x0
 426:	64a080e7          	jalr	1610(ra) # a6c <printf>
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

00000000000007a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7a4:	1101                	addi	sp,sp,-32
 7a6:	ec06                	sd	ra,24(sp)
 7a8:	e822                	sd	s0,16(sp)
 7aa:	1000                	addi	s0,sp,32
 7ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7b0:	4605                	li	a2,1
 7b2:	fef40593          	addi	a1,s0,-17
 7b6:	00000097          	auipc	ra,0x0
 7ba:	f4e080e7          	jalr	-178(ra) # 704 <write>
}
 7be:	60e2                	ld	ra,24(sp)
 7c0:	6442                	ld	s0,16(sp)
 7c2:	6105                	addi	sp,sp,32
 7c4:	8082                	ret

00000000000007c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7c6:	7139                	addi	sp,sp,-64
 7c8:	fc06                	sd	ra,56(sp)
 7ca:	f822                	sd	s0,48(sp)
 7cc:	f426                	sd	s1,40(sp)
 7ce:	0080                	addi	s0,sp,64
 7d0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7d2:	c299                	beqz	a3,7d8 <printint+0x12>
 7d4:	0805cb63          	bltz	a1,86a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7d8:	2581                	sext.w	a1,a1
  neg = 0;
 7da:	4881                	li	a7,0
 7dc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7e0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7e2:	2601                	sext.w	a2,a2
 7e4:	00000517          	auipc	a0,0x0
 7e8:	68c50513          	addi	a0,a0,1676 # e70 <digits>
 7ec:	883a                	mv	a6,a4
 7ee:	2705                	addiw	a4,a4,1
 7f0:	02c5f7bb          	remuw	a5,a1,a2
 7f4:	1782                	slli	a5,a5,0x20
 7f6:	9381                	srli	a5,a5,0x20
 7f8:	97aa                	add	a5,a5,a0
 7fa:	0007c783          	lbu	a5,0(a5)
 7fe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 802:	0005879b          	sext.w	a5,a1
 806:	02c5d5bb          	divuw	a1,a1,a2
 80a:	0685                	addi	a3,a3,1
 80c:	fec7f0e3          	bgeu	a5,a2,7ec <printint+0x26>
  if(neg)
 810:	00088c63          	beqz	a7,828 <printint+0x62>
    buf[i++] = '-';
 814:	fd070793          	addi	a5,a4,-48
 818:	00878733          	add	a4,a5,s0
 81c:	02d00793          	li	a5,45
 820:	fef70823          	sb	a5,-16(a4)
 824:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 828:	02e05c63          	blez	a4,860 <printint+0x9a>
 82c:	f04a                	sd	s2,32(sp)
 82e:	ec4e                	sd	s3,24(sp)
 830:	fc040793          	addi	a5,s0,-64
 834:	00e78933          	add	s2,a5,a4
 838:	fff78993          	addi	s3,a5,-1
 83c:	99ba                	add	s3,s3,a4
 83e:	377d                	addiw	a4,a4,-1
 840:	1702                	slli	a4,a4,0x20
 842:	9301                	srli	a4,a4,0x20
 844:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 848:	fff94583          	lbu	a1,-1(s2)
 84c:	8526                	mv	a0,s1
 84e:	00000097          	auipc	ra,0x0
 852:	f56080e7          	jalr	-170(ra) # 7a4 <putc>
  while(--i >= 0)
 856:	197d                	addi	s2,s2,-1
 858:	ff3918e3          	bne	s2,s3,848 <printint+0x82>
 85c:	7902                	ld	s2,32(sp)
 85e:	69e2                	ld	s3,24(sp)
}
 860:	70e2                	ld	ra,56(sp)
 862:	7442                	ld	s0,48(sp)
 864:	74a2                	ld	s1,40(sp)
 866:	6121                	addi	sp,sp,64
 868:	8082                	ret
    x = -xx;
 86a:	40b005bb          	negw	a1,a1
    neg = 1;
 86e:	4885                	li	a7,1
    x = -xx;
 870:	b7b5                	j	7dc <printint+0x16>

0000000000000872 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 872:	715d                	addi	sp,sp,-80
 874:	e486                	sd	ra,72(sp)
 876:	e0a2                	sd	s0,64(sp)
 878:	f84a                	sd	s2,48(sp)
 87a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 87c:	0005c903          	lbu	s2,0(a1)
 880:	1a090a63          	beqz	s2,a34 <vprintf+0x1c2>
 884:	fc26                	sd	s1,56(sp)
 886:	f44e                	sd	s3,40(sp)
 888:	f052                	sd	s4,32(sp)
 88a:	ec56                	sd	s5,24(sp)
 88c:	e85a                	sd	s6,16(sp)
 88e:	e45e                	sd	s7,8(sp)
 890:	8aaa                	mv	s5,a0
 892:	8bb2                	mv	s7,a2
 894:	00158493          	addi	s1,a1,1
  state = 0;
 898:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 89a:	02500a13          	li	s4,37
 89e:	4b55                	li	s6,21
 8a0:	a839                	j	8be <vprintf+0x4c>
        putc(fd, c);
 8a2:	85ca                	mv	a1,s2
 8a4:	8556                	mv	a0,s5
 8a6:	00000097          	auipc	ra,0x0
 8aa:	efe080e7          	jalr	-258(ra) # 7a4 <putc>
 8ae:	a019                	j	8b4 <vprintf+0x42>
    } else if(state == '%'){
 8b0:	01498d63          	beq	s3,s4,8ca <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 8b4:	0485                	addi	s1,s1,1
 8b6:	fff4c903          	lbu	s2,-1(s1)
 8ba:	16090763          	beqz	s2,a28 <vprintf+0x1b6>
    if(state == 0){
 8be:	fe0999e3          	bnez	s3,8b0 <vprintf+0x3e>
      if(c == '%'){
 8c2:	ff4910e3          	bne	s2,s4,8a2 <vprintf+0x30>
        state = '%';
 8c6:	89d2                	mv	s3,s4
 8c8:	b7f5                	j	8b4 <vprintf+0x42>
      if(c == 'd'){
 8ca:	13490463          	beq	s2,s4,9f2 <vprintf+0x180>
 8ce:	f9d9079b          	addiw	a5,s2,-99
 8d2:	0ff7f793          	zext.b	a5,a5
 8d6:	12fb6763          	bltu	s6,a5,a04 <vprintf+0x192>
 8da:	f9d9079b          	addiw	a5,s2,-99
 8de:	0ff7f713          	zext.b	a4,a5
 8e2:	12eb6163          	bltu	s6,a4,a04 <vprintf+0x192>
 8e6:	00271793          	slli	a5,a4,0x2
 8ea:	00000717          	auipc	a4,0x0
 8ee:	52e70713          	addi	a4,a4,1326 # e18 <malloc+0x2f4>
 8f2:	97ba                	add	a5,a5,a4
 8f4:	439c                	lw	a5,0(a5)
 8f6:	97ba                	add	a5,a5,a4
 8f8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 8fa:	008b8913          	addi	s2,s7,8
 8fe:	4685                	li	a3,1
 900:	4629                	li	a2,10
 902:	000ba583          	lw	a1,0(s7)
 906:	8556                	mv	a0,s5
 908:	00000097          	auipc	ra,0x0
 90c:	ebe080e7          	jalr	-322(ra) # 7c6 <printint>
 910:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 912:	4981                	li	s3,0
 914:	b745                	j	8b4 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 916:	008b8913          	addi	s2,s7,8
 91a:	4681                	li	a3,0
 91c:	4629                	li	a2,10
 91e:	000ba583          	lw	a1,0(s7)
 922:	8556                	mv	a0,s5
 924:	00000097          	auipc	ra,0x0
 928:	ea2080e7          	jalr	-350(ra) # 7c6 <printint>
 92c:	8bca                	mv	s7,s2
      state = 0;
 92e:	4981                	li	s3,0
 930:	b751                	j	8b4 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 932:	008b8913          	addi	s2,s7,8
 936:	4681                	li	a3,0
 938:	4641                	li	a2,16
 93a:	000ba583          	lw	a1,0(s7)
 93e:	8556                	mv	a0,s5
 940:	00000097          	auipc	ra,0x0
 944:	e86080e7          	jalr	-378(ra) # 7c6 <printint>
 948:	8bca                	mv	s7,s2
      state = 0;
 94a:	4981                	li	s3,0
 94c:	b7a5                	j	8b4 <vprintf+0x42>
 94e:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 950:	008b8c13          	addi	s8,s7,8
 954:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 958:	03000593          	li	a1,48
 95c:	8556                	mv	a0,s5
 95e:	00000097          	auipc	ra,0x0
 962:	e46080e7          	jalr	-442(ra) # 7a4 <putc>
  putc(fd, 'x');
 966:	07800593          	li	a1,120
 96a:	8556                	mv	a0,s5
 96c:	00000097          	auipc	ra,0x0
 970:	e38080e7          	jalr	-456(ra) # 7a4 <putc>
 974:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 976:	00000b97          	auipc	s7,0x0
 97a:	4fab8b93          	addi	s7,s7,1274 # e70 <digits>
 97e:	03c9d793          	srli	a5,s3,0x3c
 982:	97de                	add	a5,a5,s7
 984:	0007c583          	lbu	a1,0(a5)
 988:	8556                	mv	a0,s5
 98a:	00000097          	auipc	ra,0x0
 98e:	e1a080e7          	jalr	-486(ra) # 7a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 992:	0992                	slli	s3,s3,0x4
 994:	397d                	addiw	s2,s2,-1
 996:	fe0914e3          	bnez	s2,97e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 99a:	8be2                	mv	s7,s8
      state = 0;
 99c:	4981                	li	s3,0
 99e:	6c02                	ld	s8,0(sp)
 9a0:	bf11                	j	8b4 <vprintf+0x42>
        s = va_arg(ap, char*);
 9a2:	008b8993          	addi	s3,s7,8
 9a6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 9aa:	02090163          	beqz	s2,9cc <vprintf+0x15a>
        while(*s != 0){
 9ae:	00094583          	lbu	a1,0(s2)
 9b2:	c9a5                	beqz	a1,a22 <vprintf+0x1b0>
          putc(fd, *s);
 9b4:	8556                	mv	a0,s5
 9b6:	00000097          	auipc	ra,0x0
 9ba:	dee080e7          	jalr	-530(ra) # 7a4 <putc>
          s++;
 9be:	0905                	addi	s2,s2,1
        while(*s != 0){
 9c0:	00094583          	lbu	a1,0(s2)
 9c4:	f9e5                	bnez	a1,9b4 <vprintf+0x142>
        s = va_arg(ap, char*);
 9c6:	8bce                	mv	s7,s3
      state = 0;
 9c8:	4981                	li	s3,0
 9ca:	b5ed                	j	8b4 <vprintf+0x42>
          s = "(null)";
 9cc:	00000917          	auipc	s2,0x0
 9d0:	44490913          	addi	s2,s2,1092 # e10 <malloc+0x2ec>
        while(*s != 0){
 9d4:	02800593          	li	a1,40
 9d8:	bff1                	j	9b4 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 9da:	008b8913          	addi	s2,s7,8
 9de:	000bc583          	lbu	a1,0(s7)
 9e2:	8556                	mv	a0,s5
 9e4:	00000097          	auipc	ra,0x0
 9e8:	dc0080e7          	jalr	-576(ra) # 7a4 <putc>
 9ec:	8bca                	mv	s7,s2
      state = 0;
 9ee:	4981                	li	s3,0
 9f0:	b5d1                	j	8b4 <vprintf+0x42>
        putc(fd, c);
 9f2:	02500593          	li	a1,37
 9f6:	8556                	mv	a0,s5
 9f8:	00000097          	auipc	ra,0x0
 9fc:	dac080e7          	jalr	-596(ra) # 7a4 <putc>
      state = 0;
 a00:	4981                	li	s3,0
 a02:	bd4d                	j	8b4 <vprintf+0x42>
        putc(fd, '%');
 a04:	02500593          	li	a1,37
 a08:	8556                	mv	a0,s5
 a0a:	00000097          	auipc	ra,0x0
 a0e:	d9a080e7          	jalr	-614(ra) # 7a4 <putc>
        putc(fd, c);
 a12:	85ca                	mv	a1,s2
 a14:	8556                	mv	a0,s5
 a16:	00000097          	auipc	ra,0x0
 a1a:	d8e080e7          	jalr	-626(ra) # 7a4 <putc>
      state = 0;
 a1e:	4981                	li	s3,0
 a20:	bd51                	j	8b4 <vprintf+0x42>
        s = va_arg(ap, char*);
 a22:	8bce                	mv	s7,s3
      state = 0;
 a24:	4981                	li	s3,0
 a26:	b579                	j	8b4 <vprintf+0x42>
 a28:	74e2                	ld	s1,56(sp)
 a2a:	79a2                	ld	s3,40(sp)
 a2c:	7a02                	ld	s4,32(sp)
 a2e:	6ae2                	ld	s5,24(sp)
 a30:	6b42                	ld	s6,16(sp)
 a32:	6ba2                	ld	s7,8(sp)
    }
  }
}
 a34:	60a6                	ld	ra,72(sp)
 a36:	6406                	ld	s0,64(sp)
 a38:	7942                	ld	s2,48(sp)
 a3a:	6161                	addi	sp,sp,80
 a3c:	8082                	ret

0000000000000a3e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a3e:	715d                	addi	sp,sp,-80
 a40:	ec06                	sd	ra,24(sp)
 a42:	e822                	sd	s0,16(sp)
 a44:	1000                	addi	s0,sp,32
 a46:	e010                	sd	a2,0(s0)
 a48:	e414                	sd	a3,8(s0)
 a4a:	e818                	sd	a4,16(s0)
 a4c:	ec1c                	sd	a5,24(s0)
 a4e:	03043023          	sd	a6,32(s0)
 a52:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a56:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a5a:	8622                	mv	a2,s0
 a5c:	00000097          	auipc	ra,0x0
 a60:	e16080e7          	jalr	-490(ra) # 872 <vprintf>
}
 a64:	60e2                	ld	ra,24(sp)
 a66:	6442                	ld	s0,16(sp)
 a68:	6161                	addi	sp,sp,80
 a6a:	8082                	ret

0000000000000a6c <printf>:

void
printf(const char *fmt, ...)
{
 a6c:	711d                	addi	sp,sp,-96
 a6e:	ec06                	sd	ra,24(sp)
 a70:	e822                	sd	s0,16(sp)
 a72:	1000                	addi	s0,sp,32
 a74:	e40c                	sd	a1,8(s0)
 a76:	e810                	sd	a2,16(s0)
 a78:	ec14                	sd	a3,24(s0)
 a7a:	f018                	sd	a4,32(s0)
 a7c:	f41c                	sd	a5,40(s0)
 a7e:	03043823          	sd	a6,48(s0)
 a82:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a86:	00840613          	addi	a2,s0,8
 a8a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a8e:	85aa                	mv	a1,a0
 a90:	4505                	li	a0,1
 a92:	00000097          	auipc	ra,0x0
 a96:	de0080e7          	jalr	-544(ra) # 872 <vprintf>
}
 a9a:	60e2                	ld	ra,24(sp)
 a9c:	6442                	ld	s0,16(sp)
 a9e:	6125                	addi	sp,sp,96
 aa0:	8082                	ret

0000000000000aa2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aa2:	1141                	addi	sp,sp,-16
 aa4:	e422                	sd	s0,8(sp)
 aa6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aa8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aac:	00001797          	auipc	a5,0x1
 ab0:	adc7b783          	ld	a5,-1316(a5) # 1588 <freep>
 ab4:	a02d                	j	ade <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 ab6:	4618                	lw	a4,8(a2)
 ab8:	9f2d                	addw	a4,a4,a1
 aba:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 abe:	6398                	ld	a4,0(a5)
 ac0:	6310                	ld	a2,0(a4)
 ac2:	a83d                	j	b00 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 ac4:	ff852703          	lw	a4,-8(a0)
 ac8:	9f31                	addw	a4,a4,a2
 aca:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 acc:	ff053683          	ld	a3,-16(a0)
 ad0:	a091                	j	b14 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ad2:	6398                	ld	a4,0(a5)
 ad4:	00e7e463          	bltu	a5,a4,adc <free+0x3a>
 ad8:	00e6ea63          	bltu	a3,a4,aec <free+0x4a>
{
 adc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ade:	fed7fae3          	bgeu	a5,a3,ad2 <free+0x30>
 ae2:	6398                	ld	a4,0(a5)
 ae4:	00e6e463          	bltu	a3,a4,aec <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ae8:	fee7eae3          	bltu	a5,a4,adc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 aec:	ff852583          	lw	a1,-8(a0)
 af0:	6390                	ld	a2,0(a5)
 af2:	02059813          	slli	a6,a1,0x20
 af6:	01c85713          	srli	a4,a6,0x1c
 afa:	9736                	add	a4,a4,a3
 afc:	fae60de3          	beq	a2,a4,ab6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b00:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b04:	4790                	lw	a2,8(a5)
 b06:	02061593          	slli	a1,a2,0x20
 b0a:	01c5d713          	srli	a4,a1,0x1c
 b0e:	973e                	add	a4,a4,a5
 b10:	fae68ae3          	beq	a3,a4,ac4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 b14:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b16:	00001717          	auipc	a4,0x1
 b1a:	a6f73923          	sd	a5,-1422(a4) # 1588 <freep>
}
 b1e:	6422                	ld	s0,8(sp)
 b20:	0141                	addi	sp,sp,16
 b22:	8082                	ret

0000000000000b24 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b24:	7139                	addi	sp,sp,-64
 b26:	fc06                	sd	ra,56(sp)
 b28:	f822                	sd	s0,48(sp)
 b2a:	f426                	sd	s1,40(sp)
 b2c:	ec4e                	sd	s3,24(sp)
 b2e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b30:	02051493          	slli	s1,a0,0x20
 b34:	9081                	srli	s1,s1,0x20
 b36:	04bd                	addi	s1,s1,15
 b38:	8091                	srli	s1,s1,0x4
 b3a:	0014899b          	addiw	s3,s1,1
 b3e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b40:	00001517          	auipc	a0,0x1
 b44:	a4853503          	ld	a0,-1464(a0) # 1588 <freep>
 b48:	c915                	beqz	a0,b7c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b4a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b4c:	4798                	lw	a4,8(a5)
 b4e:	08977e63          	bgeu	a4,s1,bea <malloc+0xc6>
 b52:	f04a                	sd	s2,32(sp)
 b54:	e852                	sd	s4,16(sp)
 b56:	e456                	sd	s5,8(sp)
 b58:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 b5a:	8a4e                	mv	s4,s3
 b5c:	0009871b          	sext.w	a4,s3
 b60:	6685                	lui	a3,0x1
 b62:	00d77363          	bgeu	a4,a3,b68 <malloc+0x44>
 b66:	6a05                	lui	s4,0x1
 b68:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b6c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b70:	00001917          	auipc	s2,0x1
 b74:	a1890913          	addi	s2,s2,-1512 # 1588 <freep>
  if(p == (char*)-1)
 b78:	5afd                	li	s5,-1
 b7a:	a091                	j	bbe <malloc+0x9a>
 b7c:	f04a                	sd	s2,32(sp)
 b7e:	e852                	sd	s4,16(sp)
 b80:	e456                	sd	s5,8(sp)
 b82:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b84:	00001797          	auipc	a5,0x1
 b88:	a0c78793          	addi	a5,a5,-1524 # 1590 <base>
 b8c:	00001717          	auipc	a4,0x1
 b90:	9ef73e23          	sd	a5,-1540(a4) # 1588 <freep>
 b94:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b96:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b9a:	b7c1                	j	b5a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b9c:	6398                	ld	a4,0(a5)
 b9e:	e118                	sd	a4,0(a0)
 ba0:	a08d                	j	c02 <malloc+0xde>
  hp->s.size = nu;
 ba2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ba6:	0541                	addi	a0,a0,16
 ba8:	00000097          	auipc	ra,0x0
 bac:	efa080e7          	jalr	-262(ra) # aa2 <free>
  return freep;
 bb0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 bb4:	c13d                	beqz	a0,c1a <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bb6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bb8:	4798                	lw	a4,8(a5)
 bba:	02977463          	bgeu	a4,s1,be2 <malloc+0xbe>
    if(p == freep)
 bbe:	00093703          	ld	a4,0(s2)
 bc2:	853e                	mv	a0,a5
 bc4:	fef719e3          	bne	a4,a5,bb6 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 bc8:	8552                	mv	a0,s4
 bca:	00000097          	auipc	ra,0x0
 bce:	ba2080e7          	jalr	-1118(ra) # 76c <sbrk>
  if(p == (char*)-1)
 bd2:	fd5518e3          	bne	a0,s5,ba2 <malloc+0x7e>
        return 0;
 bd6:	4501                	li	a0,0
 bd8:	7902                	ld	s2,32(sp)
 bda:	6a42                	ld	s4,16(sp)
 bdc:	6aa2                	ld	s5,8(sp)
 bde:	6b02                	ld	s6,0(sp)
 be0:	a03d                	j	c0e <malloc+0xea>
 be2:	7902                	ld	s2,32(sp)
 be4:	6a42                	ld	s4,16(sp)
 be6:	6aa2                	ld	s5,8(sp)
 be8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 bea:	fae489e3          	beq	s1,a4,b9c <malloc+0x78>
        p->s.size -= nunits;
 bee:	4137073b          	subw	a4,a4,s3
 bf2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bf4:	02071693          	slli	a3,a4,0x20
 bf8:	01c6d713          	srli	a4,a3,0x1c
 bfc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bfe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c02:	00001717          	auipc	a4,0x1
 c06:	98a73323          	sd	a0,-1658(a4) # 1588 <freep>
      return (void*)(p + 1);
 c0a:	01078513          	addi	a0,a5,16
  }
}
 c0e:	70e2                	ld	ra,56(sp)
 c10:	7442                	ld	s0,48(sp)
 c12:	74a2                	ld	s1,40(sp)
 c14:	69e2                	ld	s3,24(sp)
 c16:	6121                	addi	sp,sp,64
 c18:	8082                	ret
 c1a:	7902                	ld	s2,32(sp)
 c1c:	6a42                	ld	s4,16(sp)
 c1e:	6aa2                	ld	s5,8(sp)
 c20:	6b02                	ld	s6,0(sp)
 c22:	b7f5                	j	c0e <malloc+0xea>
