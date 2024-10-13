
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d863          	bge	a5,a0,84 <main+0x84>
  18:	00858493          	addi	s1,a1,8
  1c:	3579                	addiw	a0,a0,-2
  1e:	02051793          	slli	a5,a0,0x20
  22:	01d7d513          	srli	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	addi	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	830a8a93          	addi	s5,s5,-2000 # 860 <malloc+0x104>
  38:	a819                	j	4e <main+0x4e>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	00000097          	auipc	ra,0x0
  44:	2f4080e7          	jalr	756(ra) # 334 <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	addi	s1,s1,8
  4a:	03348d63          	beq	s1,s3,84 <main+0x84>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	00000097          	auipc	ra,0x0
  58:	09c080e7          	jalr	156(ra) # f0 <strlen>
  5c:	0005061b          	sext.w	a2,a0
  60:	85ca                	mv	a1,s2
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	2d0080e7          	jalr	720(ra) # 334 <write>
    if(i + 1 < argc){
  6c:	fd4497e3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  70:	4605                	li	a2,1
  72:	00000597          	auipc	a1,0x0
  76:	7f658593          	addi	a1,a1,2038 # 868 <malloc+0x10c>
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	2b8080e7          	jalr	696(ra) # 334 <write>
    }
  }
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	28e080e7          	jalr	654(ra) # 314 <exit>

000000000000008e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  extern int main();
  main();
  96:	00000097          	auipc	ra,0x0
  9a:	f6a080e7          	jalr	-150(ra) # 0 <main>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	274080e7          	jalr	628(ra) # 314 <exit>

00000000000000a8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ae:	87aa                	mv	a5,a0
  b0:	0585                	addi	a1,a1,1
  b2:	0785                	addi	a5,a5,1
  b4:	fff5c703          	lbu	a4,-1(a1)
  b8:	fee78fa3          	sb	a4,-1(a5)
  bc:	fb75                	bnez	a4,b0 <strcpy+0x8>
    ;
  return os;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x1e>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x1e>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x26>
  fc:	0505                	addi	a0,a0,1
  fe:	87aa                	mv	a5,a0
 100:	86be                	mv	a3,a5
 102:	0785                	addi	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x10>
 10a:	40a6853b          	subw	a0,a3,a0
 10e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 120:	ca19                	beqz	a2,136 <memset+0x1c>
 122:	87aa                	mv	a5,a0
 124:	1602                	slli	a2,a2,0x20
 126:	9201                	srli	a2,a2,0x20
 128:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	addi	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x12>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	addi	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addiw	s1,s1,1
 186:	0344d863          	bge	s1,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	addi	a1,s0,-81
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	19a080e7          	jalr	410(ra) # 32c <read>
    if(cc < 1)
 19a:	00a05e63          	blez	a0,1b6 <gets+0x56>
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	01578763          	beq	a5,s5,1b4 <gets+0x54>
 1aa:	0905                	addi	s2,s2,1
 1ac:	fd679be3          	bne	a5,s6,182 <gets+0x22>
    buf[i++] = c;
 1b0:	89a6                	mv	s3,s1
 1b2:	a011                	j	1b6 <gets+0x56>
 1b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b6:	99de                	add	s3,s3,s7
 1b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e04a                	sd	s2,0(sp)
 1dc:	1000                	addi	s0,sp,32
 1de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e0:	4581                	li	a1,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	172080e7          	jalr	370(ra) # 354 <open>
  if(fd < 0)
 1ea:	02054663          	bltz	a0,216 <stat+0x42>
 1ee:	e426                	sd	s1,8(sp)
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	00000097          	auipc	ra,0x0
 1f8:	178080e7          	jalr	376(ra) # 36c <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	00000097          	auipc	ra,0x0
 204:	13c080e7          	jalr	316(ra) # 33c <close>
  return r;
 208:	64a2                	ld	s1,8(sp)
}
 20a:	854a                	mv	a0,s2
 20c:	60e2                	ld	ra,24(sp)
 20e:	6442                	ld	s0,16(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	597d                	li	s2,-1
 218:	bfcd                	j	20a <stat+0x36>

000000000000021a <atoi>:

int
atoi(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 220:	00054683          	lbu	a3,0(a0)
 224:	fd06879b          	addiw	a5,a3,-48
 228:	0ff7f793          	zext.b	a5,a5
 22c:	4625                	li	a2,9
 22e:	02f66863          	bltu	a2,a5,25e <atoi+0x44>
 232:	872a                	mv	a4,a0
  n = 0;
 234:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 236:	0705                	addi	a4,a4,1
 238:	0025179b          	slliw	a5,a0,0x2
 23c:	9fa9                	addw	a5,a5,a0
 23e:	0017979b          	slliw	a5,a5,0x1
 242:	9fb5                	addw	a5,a5,a3
 244:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 248:	00074683          	lbu	a3,0(a4)
 24c:	fd06879b          	addiw	a5,a3,-48
 250:	0ff7f793          	zext.b	a5,a5
 254:	fef671e3          	bgeu	a2,a5,236 <atoi+0x1c>
  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  n = 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <atoi+0x3e>

0000000000000262 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 268:	02b57463          	bgeu	a0,a1,290 <memmove+0x2e>
    while(n-- > 0)
 26c:	00c05f63          	blez	a2,28a <memmove+0x28>
 270:	1602                	slli	a2,a2,0x20
 272:	9201                	srli	a2,a2,0x20
 274:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 278:	872a                	mv	a4,a0
      *dst++ = *src++;
 27a:	0585                	addi	a1,a1,1
 27c:	0705                	addi	a4,a4,1
 27e:	fff5c683          	lbu	a3,-1(a1)
 282:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 286:	fef71ae3          	bne	a4,a5,27a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
    dst += n;
 290:	00c50733          	add	a4,a0,a2
    src += n;
 294:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 296:	fec05ae3          	blez	a2,28a <memmove+0x28>
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	fff7c793          	not	a5,a5
 2a6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a8:	15fd                	addi	a1,a1,-1
 2aa:	177d                	addi	a4,a4,-1
 2ac:	0005c683          	lbu	a3,0(a1)
 2b0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x46>
 2b8:	bfc9                	j	28a <memmove+0x28>

00000000000002ba <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	ca05                	beqz	a2,2f0 <memcmp+0x36>
 2c2:	fff6069b          	addiw	a3,a2,-1
 2c6:	1682                	slli	a3,a3,0x20
 2c8:	9281                	srli	a3,a3,0x20
 2ca:	0685                	addi	a3,a3,1
 2cc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	0005c703          	lbu	a4,0(a1)
 2d6:	00e79863          	bne	a5,a4,2e6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2da:	0505                	addi	a0,a0,1
    p2++;
 2dc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2de:	fed518e3          	bne	a0,a3,2ce <memcmp+0x14>
  }
  return 0;
 2e2:	4501                	li	a0,0
 2e4:	a019                	j	2ea <memcmp+0x30>
      return *p1 - *p2;
 2e6:	40e7853b          	subw	a0,a5,a4
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  return 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <memcmp+0x30>

00000000000002f4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fc:	00000097          	auipc	ra,0x0
 300:	f66080e7          	jalr	-154(ra) # 262 <memmove>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 30c:	4885                	li	a7,1
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <exit>:
.global exit
exit:
 li a7, SYS_exit
 314:	4889                	li	a7,2
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <wait>:
.global wait
wait:
 li a7, SYS_wait
 31c:	488d                	li	a7,3
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 324:	4891                	li	a7,4
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <read>:
.global read
read:
 li a7, SYS_read
 32c:	4895                	li	a7,5
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <write>:
.global write
write:
 li a7, SYS_write
 334:	48c1                	li	a7,16
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <close>:
.global close
close:
 li a7, SYS_close
 33c:	48d5                	li	a7,21
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <kill>:
.global kill
kill:
 li a7, SYS_kill
 344:	4899                	li	a7,6
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <exec>:
.global exec
exec:
 li a7, SYS_exec
 34c:	489d                	li	a7,7
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <open>:
.global open
open:
 li a7, SYS_open
 354:	48bd                	li	a7,15
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 35c:	48c5                	li	a7,17
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 364:	48c9                	li	a7,18
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 36c:	48a1                	li	a7,8
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <link>:
.global link
link:
 li a7, SYS_link
 374:	48cd                	li	a7,19
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37c:	48d1                	li	a7,20
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 384:	48a5                	li	a7,9
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <dup>:
.global dup
dup:
 li a7, SYS_dup
 38c:	48a9                	li	a7,10
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 394:	48ad                	li	a7,11
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39c:	48b1                	li	a7,12
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a4:	48b5                	li	a7,13
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ac:	48b9                	li	a7,14
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3b4:	48d9                	li	a7,22
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 3bc:	48dd                	li	a7,23
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 3c4:	48e1                	li	a7,24
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3cc:	48e5                	li	a7,25
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3d4:	48e9                	li	a7,26
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3dc:	1101                	addi	sp,sp,-32
 3de:	ec06                	sd	ra,24(sp)
 3e0:	e822                	sd	s0,16(sp)
 3e2:	1000                	addi	s0,sp,32
 3e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e8:	4605                	li	a2,1
 3ea:	fef40593          	addi	a1,s0,-17
 3ee:	00000097          	auipc	ra,0x0
 3f2:	f46080e7          	jalr	-186(ra) # 334 <write>
}
 3f6:	60e2                	ld	ra,24(sp)
 3f8:	6442                	ld	s0,16(sp)
 3fa:	6105                	addi	sp,sp,32
 3fc:	8082                	ret

00000000000003fe <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3fe:	7139                	addi	sp,sp,-64
 400:	fc06                	sd	ra,56(sp)
 402:	f822                	sd	s0,48(sp)
 404:	f426                	sd	s1,40(sp)
 406:	0080                	addi	s0,sp,64
 408:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 40a:	c299                	beqz	a3,410 <printint+0x12>
 40c:	0805cb63          	bltz	a1,4a2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 410:	2581                	sext.w	a1,a1
  neg = 0;
 412:	4881                	li	a7,0
 414:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 418:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 41a:	2601                	sext.w	a2,a2
 41c:	00000517          	auipc	a0,0x0
 420:	4b450513          	addi	a0,a0,1204 # 8d0 <digits>
 424:	883a                	mv	a6,a4
 426:	2705                	addiw	a4,a4,1
 428:	02c5f7bb          	remuw	a5,a1,a2
 42c:	1782                	slli	a5,a5,0x20
 42e:	9381                	srli	a5,a5,0x20
 430:	97aa                	add	a5,a5,a0
 432:	0007c783          	lbu	a5,0(a5)
 436:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 43a:	0005879b          	sext.w	a5,a1
 43e:	02c5d5bb          	divuw	a1,a1,a2
 442:	0685                	addi	a3,a3,1
 444:	fec7f0e3          	bgeu	a5,a2,424 <printint+0x26>
  if(neg)
 448:	00088c63          	beqz	a7,460 <printint+0x62>
    buf[i++] = '-';
 44c:	fd070793          	addi	a5,a4,-48
 450:	00878733          	add	a4,a5,s0
 454:	02d00793          	li	a5,45
 458:	fef70823          	sb	a5,-16(a4)
 45c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 460:	02e05c63          	blez	a4,498 <printint+0x9a>
 464:	f04a                	sd	s2,32(sp)
 466:	ec4e                	sd	s3,24(sp)
 468:	fc040793          	addi	a5,s0,-64
 46c:	00e78933          	add	s2,a5,a4
 470:	fff78993          	addi	s3,a5,-1
 474:	99ba                	add	s3,s3,a4
 476:	377d                	addiw	a4,a4,-1
 478:	1702                	slli	a4,a4,0x20
 47a:	9301                	srli	a4,a4,0x20
 47c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 480:	fff94583          	lbu	a1,-1(s2)
 484:	8526                	mv	a0,s1
 486:	00000097          	auipc	ra,0x0
 48a:	f56080e7          	jalr	-170(ra) # 3dc <putc>
  while(--i >= 0)
 48e:	197d                	addi	s2,s2,-1
 490:	ff3918e3          	bne	s2,s3,480 <printint+0x82>
 494:	7902                	ld	s2,32(sp)
 496:	69e2                	ld	s3,24(sp)
}
 498:	70e2                	ld	ra,56(sp)
 49a:	7442                	ld	s0,48(sp)
 49c:	74a2                	ld	s1,40(sp)
 49e:	6121                	addi	sp,sp,64
 4a0:	8082                	ret
    x = -xx;
 4a2:	40b005bb          	negw	a1,a1
    neg = 1;
 4a6:	4885                	li	a7,1
    x = -xx;
 4a8:	b7b5                	j	414 <printint+0x16>

00000000000004aa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4aa:	715d                	addi	sp,sp,-80
 4ac:	e486                	sd	ra,72(sp)
 4ae:	e0a2                	sd	s0,64(sp)
 4b0:	f84a                	sd	s2,48(sp)
 4b2:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b4:	0005c903          	lbu	s2,0(a1)
 4b8:	1a090a63          	beqz	s2,66c <vprintf+0x1c2>
 4bc:	fc26                	sd	s1,56(sp)
 4be:	f44e                	sd	s3,40(sp)
 4c0:	f052                	sd	s4,32(sp)
 4c2:	ec56                	sd	s5,24(sp)
 4c4:	e85a                	sd	s6,16(sp)
 4c6:	e45e                	sd	s7,8(sp)
 4c8:	8aaa                	mv	s5,a0
 4ca:	8bb2                	mv	s7,a2
 4cc:	00158493          	addi	s1,a1,1
  state = 0;
 4d0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4d2:	02500a13          	li	s4,37
 4d6:	4b55                	li	s6,21
 4d8:	a839                	j	4f6 <vprintf+0x4c>
        putc(fd, c);
 4da:	85ca                	mv	a1,s2
 4dc:	8556                	mv	a0,s5
 4de:	00000097          	auipc	ra,0x0
 4e2:	efe080e7          	jalr	-258(ra) # 3dc <putc>
 4e6:	a019                	j	4ec <vprintf+0x42>
    } else if(state == '%'){
 4e8:	01498d63          	beq	s3,s4,502 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4ec:	0485                	addi	s1,s1,1
 4ee:	fff4c903          	lbu	s2,-1(s1)
 4f2:	16090763          	beqz	s2,660 <vprintf+0x1b6>
    if(state == 0){
 4f6:	fe0999e3          	bnez	s3,4e8 <vprintf+0x3e>
      if(c == '%'){
 4fa:	ff4910e3          	bne	s2,s4,4da <vprintf+0x30>
        state = '%';
 4fe:	89d2                	mv	s3,s4
 500:	b7f5                	j	4ec <vprintf+0x42>
      if(c == 'd'){
 502:	13490463          	beq	s2,s4,62a <vprintf+0x180>
 506:	f9d9079b          	addiw	a5,s2,-99
 50a:	0ff7f793          	zext.b	a5,a5
 50e:	12fb6763          	bltu	s6,a5,63c <vprintf+0x192>
 512:	f9d9079b          	addiw	a5,s2,-99
 516:	0ff7f713          	zext.b	a4,a5
 51a:	12eb6163          	bltu	s6,a4,63c <vprintf+0x192>
 51e:	00271793          	slli	a5,a4,0x2
 522:	00000717          	auipc	a4,0x0
 526:	35670713          	addi	a4,a4,854 # 878 <malloc+0x11c>
 52a:	97ba                	add	a5,a5,a4
 52c:	439c                	lw	a5,0(a5)
 52e:	97ba                	add	a5,a5,a4
 530:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 532:	008b8913          	addi	s2,s7,8
 536:	4685                	li	a3,1
 538:	4629                	li	a2,10
 53a:	000ba583          	lw	a1,0(s7)
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	ebe080e7          	jalr	-322(ra) # 3fe <printint>
 548:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 54a:	4981                	li	s3,0
 54c:	b745                	j	4ec <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54e:	008b8913          	addi	s2,s7,8
 552:	4681                	li	a3,0
 554:	4629                	li	a2,10
 556:	000ba583          	lw	a1,0(s7)
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	ea2080e7          	jalr	-350(ra) # 3fe <printint>
 564:	8bca                	mv	s7,s2
      state = 0;
 566:	4981                	li	s3,0
 568:	b751                	j	4ec <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 56a:	008b8913          	addi	s2,s7,8
 56e:	4681                	li	a3,0
 570:	4641                	li	a2,16
 572:	000ba583          	lw	a1,0(s7)
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e86080e7          	jalr	-378(ra) # 3fe <printint>
 580:	8bca                	mv	s7,s2
      state = 0;
 582:	4981                	li	s3,0
 584:	b7a5                	j	4ec <vprintf+0x42>
 586:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 588:	008b8c13          	addi	s8,s7,8
 58c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 590:	03000593          	li	a1,48
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e46080e7          	jalr	-442(ra) # 3dc <putc>
  putc(fd, 'x');
 59e:	07800593          	li	a1,120
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e38080e7          	jalr	-456(ra) # 3dc <putc>
 5ac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ae:	00000b97          	auipc	s7,0x0
 5b2:	322b8b93          	addi	s7,s7,802 # 8d0 <digits>
 5b6:	03c9d793          	srli	a5,s3,0x3c
 5ba:	97de                	add	a5,a5,s7
 5bc:	0007c583          	lbu	a1,0(a5)
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	e1a080e7          	jalr	-486(ra) # 3dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ca:	0992                	slli	s3,s3,0x4
 5cc:	397d                	addiw	s2,s2,-1
 5ce:	fe0914e3          	bnez	s2,5b6 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5d2:	8be2                	mv	s7,s8
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	6c02                	ld	s8,0(sp)
 5d8:	bf11                	j	4ec <vprintf+0x42>
        s = va_arg(ap, char*);
 5da:	008b8993          	addi	s3,s7,8
 5de:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5e2:	02090163          	beqz	s2,604 <vprintf+0x15a>
        while(*s != 0){
 5e6:	00094583          	lbu	a1,0(s2)
 5ea:	c9a5                	beqz	a1,65a <vprintf+0x1b0>
          putc(fd, *s);
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	dee080e7          	jalr	-530(ra) # 3dc <putc>
          s++;
 5f6:	0905                	addi	s2,s2,1
        while(*s != 0){
 5f8:	00094583          	lbu	a1,0(s2)
 5fc:	f9e5                	bnez	a1,5ec <vprintf+0x142>
        s = va_arg(ap, char*);
 5fe:	8bce                	mv	s7,s3
      state = 0;
 600:	4981                	li	s3,0
 602:	b5ed                	j	4ec <vprintf+0x42>
          s = "(null)";
 604:	00000917          	auipc	s2,0x0
 608:	26c90913          	addi	s2,s2,620 # 870 <malloc+0x114>
        while(*s != 0){
 60c:	02800593          	li	a1,40
 610:	bff1                	j	5ec <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 612:	008b8913          	addi	s2,s7,8
 616:	000bc583          	lbu	a1,0(s7)
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	dc0080e7          	jalr	-576(ra) # 3dc <putc>
 624:	8bca                	mv	s7,s2
      state = 0;
 626:	4981                	li	s3,0
 628:	b5d1                	j	4ec <vprintf+0x42>
        putc(fd, c);
 62a:	02500593          	li	a1,37
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	dac080e7          	jalr	-596(ra) # 3dc <putc>
      state = 0;
 638:	4981                	li	s3,0
 63a:	bd4d                	j	4ec <vprintf+0x42>
        putc(fd, '%');
 63c:	02500593          	li	a1,37
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	d9a080e7          	jalr	-614(ra) # 3dc <putc>
        putc(fd, c);
 64a:	85ca                	mv	a1,s2
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	d8e080e7          	jalr	-626(ra) # 3dc <putc>
      state = 0;
 656:	4981                	li	s3,0
 658:	bd51                	j	4ec <vprintf+0x42>
        s = va_arg(ap, char*);
 65a:	8bce                	mv	s7,s3
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b579                	j	4ec <vprintf+0x42>
 660:	74e2                	ld	s1,56(sp)
 662:	79a2                	ld	s3,40(sp)
 664:	7a02                	ld	s4,32(sp)
 666:	6ae2                	ld	s5,24(sp)
 668:	6b42                	ld	s6,16(sp)
 66a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 66c:	60a6                	ld	ra,72(sp)
 66e:	6406                	ld	s0,64(sp)
 670:	7942                	ld	s2,48(sp)
 672:	6161                	addi	sp,sp,80
 674:	8082                	ret

0000000000000676 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 676:	715d                	addi	sp,sp,-80
 678:	ec06                	sd	ra,24(sp)
 67a:	e822                	sd	s0,16(sp)
 67c:	1000                	addi	s0,sp,32
 67e:	e010                	sd	a2,0(s0)
 680:	e414                	sd	a3,8(s0)
 682:	e818                	sd	a4,16(s0)
 684:	ec1c                	sd	a5,24(s0)
 686:	03043023          	sd	a6,32(s0)
 68a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 68e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 692:	8622                	mv	a2,s0
 694:	00000097          	auipc	ra,0x0
 698:	e16080e7          	jalr	-490(ra) # 4aa <vprintf>
}
 69c:	60e2                	ld	ra,24(sp)
 69e:	6442                	ld	s0,16(sp)
 6a0:	6161                	addi	sp,sp,80
 6a2:	8082                	ret

00000000000006a4 <printf>:

void
printf(const char *fmt, ...)
{
 6a4:	711d                	addi	sp,sp,-96
 6a6:	ec06                	sd	ra,24(sp)
 6a8:	e822                	sd	s0,16(sp)
 6aa:	1000                	addi	s0,sp,32
 6ac:	e40c                	sd	a1,8(s0)
 6ae:	e810                	sd	a2,16(s0)
 6b0:	ec14                	sd	a3,24(s0)
 6b2:	f018                	sd	a4,32(s0)
 6b4:	f41c                	sd	a5,40(s0)
 6b6:	03043823          	sd	a6,48(s0)
 6ba:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6be:	00840613          	addi	a2,s0,8
 6c2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c6:	85aa                	mv	a1,a0
 6c8:	4505                	li	a0,1
 6ca:	00000097          	auipc	ra,0x0
 6ce:	de0080e7          	jalr	-544(ra) # 4aa <vprintf>
}
 6d2:	60e2                	ld	ra,24(sp)
 6d4:	6442                	ld	s0,16(sp)
 6d6:	6125                	addi	sp,sp,96
 6d8:	8082                	ret

00000000000006da <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6da:	1141                	addi	sp,sp,-16
 6dc:	e422                	sd	s0,8(sp)
 6de:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e4:	00001797          	auipc	a5,0x1
 6e8:	cfc7b783          	ld	a5,-772(a5) # 13e0 <freep>
 6ec:	a02d                	j	716 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ee:	4618                	lw	a4,8(a2)
 6f0:	9f2d                	addw	a4,a4,a1
 6f2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f6:	6398                	ld	a4,0(a5)
 6f8:	6310                	ld	a2,0(a4)
 6fa:	a83d                	j	738 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6fc:	ff852703          	lw	a4,-8(a0)
 700:	9f31                	addw	a4,a4,a2
 702:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 704:	ff053683          	ld	a3,-16(a0)
 708:	a091                	j	74c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70a:	6398                	ld	a4,0(a5)
 70c:	00e7e463          	bltu	a5,a4,714 <free+0x3a>
 710:	00e6ea63          	bltu	a3,a4,724 <free+0x4a>
{
 714:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 716:	fed7fae3          	bgeu	a5,a3,70a <free+0x30>
 71a:	6398                	ld	a4,0(a5)
 71c:	00e6e463          	bltu	a3,a4,724 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 720:	fee7eae3          	bltu	a5,a4,714 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 724:	ff852583          	lw	a1,-8(a0)
 728:	6390                	ld	a2,0(a5)
 72a:	02059813          	slli	a6,a1,0x20
 72e:	01c85713          	srli	a4,a6,0x1c
 732:	9736                	add	a4,a4,a3
 734:	fae60de3          	beq	a2,a4,6ee <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 738:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 73c:	4790                	lw	a2,8(a5)
 73e:	02061593          	slli	a1,a2,0x20
 742:	01c5d713          	srli	a4,a1,0x1c
 746:	973e                	add	a4,a4,a5
 748:	fae68ae3          	beq	a3,a4,6fc <free+0x22>
    p->s.ptr = bp->s.ptr;
 74c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 74e:	00001717          	auipc	a4,0x1
 752:	c8f73923          	sd	a5,-878(a4) # 13e0 <freep>
}
 756:	6422                	ld	s0,8(sp)
 758:	0141                	addi	sp,sp,16
 75a:	8082                	ret

000000000000075c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 75c:	7139                	addi	sp,sp,-64
 75e:	fc06                	sd	ra,56(sp)
 760:	f822                	sd	s0,48(sp)
 762:	f426                	sd	s1,40(sp)
 764:	ec4e                	sd	s3,24(sp)
 766:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 768:	02051493          	slli	s1,a0,0x20
 76c:	9081                	srli	s1,s1,0x20
 76e:	04bd                	addi	s1,s1,15
 770:	8091                	srli	s1,s1,0x4
 772:	0014899b          	addiw	s3,s1,1
 776:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 778:	00001517          	auipc	a0,0x1
 77c:	c6853503          	ld	a0,-920(a0) # 13e0 <freep>
 780:	c915                	beqz	a0,7b4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 782:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 784:	4798                	lw	a4,8(a5)
 786:	08977e63          	bgeu	a4,s1,822 <malloc+0xc6>
 78a:	f04a                	sd	s2,32(sp)
 78c:	e852                	sd	s4,16(sp)
 78e:	e456                	sd	s5,8(sp)
 790:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 792:	8a4e                	mv	s4,s3
 794:	0009871b          	sext.w	a4,s3
 798:	6685                	lui	a3,0x1
 79a:	00d77363          	bgeu	a4,a3,7a0 <malloc+0x44>
 79e:	6a05                	lui	s4,0x1
 7a0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7a4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a8:	00001917          	auipc	s2,0x1
 7ac:	c3890913          	addi	s2,s2,-968 # 13e0 <freep>
  if(p == (char*)-1)
 7b0:	5afd                	li	s5,-1
 7b2:	a091                	j	7f6 <malloc+0x9a>
 7b4:	f04a                	sd	s2,32(sp)
 7b6:	e852                	sd	s4,16(sp)
 7b8:	e456                	sd	s5,8(sp)
 7ba:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7bc:	00001797          	auipc	a5,0x1
 7c0:	c3478793          	addi	a5,a5,-972 # 13f0 <base>
 7c4:	00001717          	auipc	a4,0x1
 7c8:	c0f73e23          	sd	a5,-996(a4) # 13e0 <freep>
 7cc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7d2:	b7c1                	j	792 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7d4:	6398                	ld	a4,0(a5)
 7d6:	e118                	sd	a4,0(a0)
 7d8:	a08d                	j	83a <malloc+0xde>
  hp->s.size = nu;
 7da:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7de:	0541                	addi	a0,a0,16
 7e0:	00000097          	auipc	ra,0x0
 7e4:	efa080e7          	jalr	-262(ra) # 6da <free>
  return freep;
 7e8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ec:	c13d                	beqz	a0,852 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f0:	4798                	lw	a4,8(a5)
 7f2:	02977463          	bgeu	a4,s1,81a <malloc+0xbe>
    if(p == freep)
 7f6:	00093703          	ld	a4,0(s2)
 7fa:	853e                	mv	a0,a5
 7fc:	fef719e3          	bne	a4,a5,7ee <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 800:	8552                	mv	a0,s4
 802:	00000097          	auipc	ra,0x0
 806:	b9a080e7          	jalr	-1126(ra) # 39c <sbrk>
  if(p == (char*)-1)
 80a:	fd5518e3          	bne	a0,s5,7da <malloc+0x7e>
        return 0;
 80e:	4501                	li	a0,0
 810:	7902                	ld	s2,32(sp)
 812:	6a42                	ld	s4,16(sp)
 814:	6aa2                	ld	s5,8(sp)
 816:	6b02                	ld	s6,0(sp)
 818:	a03d                	j	846 <malloc+0xea>
 81a:	7902                	ld	s2,32(sp)
 81c:	6a42                	ld	s4,16(sp)
 81e:	6aa2                	ld	s5,8(sp)
 820:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 822:	fae489e3          	beq	s1,a4,7d4 <malloc+0x78>
        p->s.size -= nunits;
 826:	4137073b          	subw	a4,a4,s3
 82a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 82c:	02071693          	slli	a3,a4,0x20
 830:	01c6d713          	srli	a4,a3,0x1c
 834:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 836:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 83a:	00001717          	auipc	a4,0x1
 83e:	baa73323          	sd	a0,-1114(a4) # 13e0 <freep>
      return (void*)(p + 1);
 842:	01078513          	addi	a0,a5,16
  }
}
 846:	70e2                	ld	ra,56(sp)
 848:	7442                	ld	s0,48(sp)
 84a:	74a2                	ld	s1,40(sp)
 84c:	69e2                	ld	s3,24(sp)
 84e:	6121                	addi	sp,sp,64
 850:	8082                	ret
 852:	7902                	ld	s2,32(sp)
 854:	6a42                	ld	s4,16(sp)
 856:	6aa2                	ld	s5,8(sp)
 858:	6b02                	ld	s6,0(sp)
 85a:	b7f5                	j	846 <malloc+0xea>
