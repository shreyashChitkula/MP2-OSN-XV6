
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7df63          	bge	a5,a0,48 <main+0x48>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1cc080e7          	jalr	460(ra) # 1f4 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2ee080e7          	jalr	750(ra) # 31e <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2ae080e7          	jalr	686(ra) # 2ee <exit>
  48:	e426                	sd	s1,8(sp)
  4a:	e04a                	sd	s2,0(sp)
    fprintf(2, "usage: kill pid...\n");
  4c:	00000597          	auipc	a1,0x0
  50:	7f458593          	addi	a1,a1,2036 # 840 <malloc+0x10a>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5fa080e7          	jalr	1530(ra) # 650 <fprintf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	28e080e7          	jalr	654(ra) # 2ee <exit>

0000000000000068 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  68:	1141                	addi	sp,sp,-16
  6a:	e406                	sd	ra,8(sp)
  6c:	e022                	sd	s0,0(sp)
  6e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  70:	00000097          	auipc	ra,0x0
  74:	f90080e7          	jalr	-112(ra) # 0 <main>
  exit(0);
  78:	4501                	li	a0,0
  7a:	00000097          	auipc	ra,0x0
  7e:	274080e7          	jalr	628(ra) # 2ee <exit>

0000000000000082 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  82:	1141                	addi	sp,sp,-16
  84:	e422                	sd	s0,8(sp)
  86:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  88:	87aa                	mv	a5,a0
  8a:	0585                	addi	a1,a1,1
  8c:	0785                	addi	a5,a5,1
  8e:	fff5c703          	lbu	a4,-1(a1)
  92:	fee78fa3          	sb	a4,-1(a5)
  96:	fb75                	bnez	a4,8a <strcpy+0x8>
    ;
  return os;
}
  98:	6422                	ld	s0,8(sp)
  9a:	0141                	addi	sp,sp,16
  9c:	8082                	ret

000000000000009e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a4:	00054783          	lbu	a5,0(a0)
  a8:	cb91                	beqz	a5,bc <strcmp+0x1e>
  aa:	0005c703          	lbu	a4,0(a1)
  ae:	00f71763          	bne	a4,a5,bc <strcmp+0x1e>
    p++, q++;
  b2:	0505                	addi	a0,a0,1
  b4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b6:	00054783          	lbu	a5,0(a0)
  ba:	fbe5                	bnez	a5,aa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  bc:	0005c503          	lbu	a0,0(a1)
}
  c0:	40a7853b          	subw	a0,a5,a0
  c4:	6422                	ld	s0,8(sp)
  c6:	0141                	addi	sp,sp,16
  c8:	8082                	ret

00000000000000ca <strlen>:

uint
strlen(const char *s)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d0:	00054783          	lbu	a5,0(a0)
  d4:	cf91                	beqz	a5,f0 <strlen+0x26>
  d6:	0505                	addi	a0,a0,1
  d8:	87aa                	mv	a5,a0
  da:	86be                	mv	a3,a5
  dc:	0785                	addi	a5,a5,1
  de:	fff7c703          	lbu	a4,-1(a5)
  e2:	ff65                	bnez	a4,da <strlen+0x10>
  e4:	40a6853b          	subw	a0,a3,a0
  e8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret
  for(n = 0; s[n]; n++)
  f0:	4501                	li	a0,0
  f2:	bfe5                	j	ea <strlen+0x20>

00000000000000f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fa:	ca19                	beqz	a2,110 <memset+0x1c>
  fc:	87aa                	mv	a5,a0
  fe:	1602                	slli	a2,a2,0x20
 100:	9201                	srli	a2,a2,0x20
 102:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 106:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10a:	0785                	addi	a5,a5,1
 10c:	fee79de3          	bne	a5,a4,106 <memset+0x12>
  }
  return dst;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strchr>:

char*
strchr(const char *s, char c)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11c:	00054783          	lbu	a5,0(a0)
 120:	cb99                	beqz	a5,136 <strchr+0x20>
    if(*s == c)
 122:	00f58763          	beq	a1,a5,130 <strchr+0x1a>
  for(; *s; s++)
 126:	0505                	addi	a0,a0,1
 128:	00054783          	lbu	a5,0(a0)
 12c:	fbfd                	bnez	a5,122 <strchr+0xc>
      return (char*)s;
  return 0;
 12e:	4501                	li	a0,0
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
  return 0;
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strchr+0x1a>

000000000000013a <gets>:

char*
gets(char *buf, int max)
{
 13a:	711d                	addi	sp,sp,-96
 13c:	ec86                	sd	ra,88(sp)
 13e:	e8a2                	sd	s0,80(sp)
 140:	e4a6                	sd	s1,72(sp)
 142:	e0ca                	sd	s2,64(sp)
 144:	fc4e                	sd	s3,56(sp)
 146:	f852                	sd	s4,48(sp)
 148:	f456                	sd	s5,40(sp)
 14a:	f05a                	sd	s6,32(sp)
 14c:	ec5e                	sd	s7,24(sp)
 14e:	1080                	addi	s0,sp,96
 150:	8baa                	mv	s7,a0
 152:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 154:	892a                	mv	s2,a0
 156:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 158:	4aa9                	li	s5,10
 15a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15c:	89a6                	mv	s3,s1
 15e:	2485                	addiw	s1,s1,1
 160:	0344d863          	bge	s1,s4,190 <gets+0x56>
    cc = read(0, &c, 1);
 164:	4605                	li	a2,1
 166:	faf40593          	addi	a1,s0,-81
 16a:	4501                	li	a0,0
 16c:	00000097          	auipc	ra,0x0
 170:	19a080e7          	jalr	410(ra) # 306 <read>
    if(cc < 1)
 174:	00a05e63          	blez	a0,190 <gets+0x56>
    buf[i++] = c;
 178:	faf44783          	lbu	a5,-81(s0)
 17c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 180:	01578763          	beq	a5,s5,18e <gets+0x54>
 184:	0905                	addi	s2,s2,1
 186:	fd679be3          	bne	a5,s6,15c <gets+0x22>
    buf[i++] = c;
 18a:	89a6                	mv	s3,s1
 18c:	a011                	j	190 <gets+0x56>
 18e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 190:	99de                	add	s3,s3,s7
 192:	00098023          	sb	zero,0(s3)
  return buf;
}
 196:	855e                	mv	a0,s7
 198:	60e6                	ld	ra,88(sp)
 19a:	6446                	ld	s0,80(sp)
 19c:	64a6                	ld	s1,72(sp)
 19e:	6906                	ld	s2,64(sp)
 1a0:	79e2                	ld	s3,56(sp)
 1a2:	7a42                	ld	s4,48(sp)
 1a4:	7aa2                	ld	s5,40(sp)
 1a6:	7b02                	ld	s6,32(sp)
 1a8:	6be2                	ld	s7,24(sp)
 1aa:	6125                	addi	sp,sp,96
 1ac:	8082                	ret

00000000000001ae <stat>:

int
stat(const char *n, struct stat *st)
{
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e04a                	sd	s2,0(sp)
 1b6:	1000                	addi	s0,sp,32
 1b8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ba:	4581                	li	a1,0
 1bc:	00000097          	auipc	ra,0x0
 1c0:	172080e7          	jalr	370(ra) # 32e <open>
  if(fd < 0)
 1c4:	02054663          	bltz	a0,1f0 <stat+0x42>
 1c8:	e426                	sd	s1,8(sp)
 1ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1cc:	85ca                	mv	a1,s2
 1ce:	00000097          	auipc	ra,0x0
 1d2:	178080e7          	jalr	376(ra) # 346 <fstat>
 1d6:	892a                	mv	s2,a0
  close(fd);
 1d8:	8526                	mv	a0,s1
 1da:	00000097          	auipc	ra,0x0
 1de:	13c080e7          	jalr	316(ra) # 316 <close>
  return r;
 1e2:	64a2                	ld	s1,8(sp)
}
 1e4:	854a                	mv	a0,s2
 1e6:	60e2                	ld	ra,24(sp)
 1e8:	6442                	ld	s0,16(sp)
 1ea:	6902                	ld	s2,0(sp)
 1ec:	6105                	addi	sp,sp,32
 1ee:	8082                	ret
    return -1;
 1f0:	597d                	li	s2,-1
 1f2:	bfcd                	j	1e4 <stat+0x36>

00000000000001f4 <atoi>:

int
atoi(const char *s)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fa:	00054683          	lbu	a3,0(a0)
 1fe:	fd06879b          	addiw	a5,a3,-48
 202:	0ff7f793          	zext.b	a5,a5
 206:	4625                	li	a2,9
 208:	02f66863          	bltu	a2,a5,238 <atoi+0x44>
 20c:	872a                	mv	a4,a0
  n = 0;
 20e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 210:	0705                	addi	a4,a4,1
 212:	0025179b          	slliw	a5,a0,0x2
 216:	9fa9                	addw	a5,a5,a0
 218:	0017979b          	slliw	a5,a5,0x1
 21c:	9fb5                	addw	a5,a5,a3
 21e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 222:	00074683          	lbu	a3,0(a4)
 226:	fd06879b          	addiw	a5,a3,-48
 22a:	0ff7f793          	zext.b	a5,a5
 22e:	fef671e3          	bgeu	a2,a5,210 <atoi+0x1c>
  return n;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
  n = 0;
 238:	4501                	li	a0,0
 23a:	bfe5                	j	232 <atoi+0x3e>

000000000000023c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 242:	02b57463          	bgeu	a0,a1,26a <memmove+0x2e>
    while(n-- > 0)
 246:	00c05f63          	blez	a2,264 <memmove+0x28>
 24a:	1602                	slli	a2,a2,0x20
 24c:	9201                	srli	a2,a2,0x20
 24e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 252:	872a                	mv	a4,a0
      *dst++ = *src++;
 254:	0585                	addi	a1,a1,1
 256:	0705                	addi	a4,a4,1
 258:	fff5c683          	lbu	a3,-1(a1)
 25c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 260:	fef71ae3          	bne	a4,a5,254 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret
    dst += n;
 26a:	00c50733          	add	a4,a0,a2
    src += n;
 26e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 270:	fec05ae3          	blez	a2,264 <memmove+0x28>
 274:	fff6079b          	addiw	a5,a2,-1
 278:	1782                	slli	a5,a5,0x20
 27a:	9381                	srli	a5,a5,0x20
 27c:	fff7c793          	not	a5,a5
 280:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 282:	15fd                	addi	a1,a1,-1
 284:	177d                	addi	a4,a4,-1
 286:	0005c683          	lbu	a3,0(a1)
 28a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28e:	fee79ae3          	bne	a5,a4,282 <memmove+0x46>
 292:	bfc9                	j	264 <memmove+0x28>

0000000000000294 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 29a:	ca05                	beqz	a2,2ca <memcmp+0x36>
 29c:	fff6069b          	addiw	a3,a2,-1
 2a0:	1682                	slli	a3,a3,0x20
 2a2:	9281                	srli	a3,a3,0x20
 2a4:	0685                	addi	a3,a3,1
 2a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a8:	00054783          	lbu	a5,0(a0)
 2ac:	0005c703          	lbu	a4,0(a1)
 2b0:	00e79863          	bne	a5,a4,2c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b4:	0505                	addi	a0,a0,1
    p2++;
 2b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b8:	fed518e3          	bne	a0,a3,2a8 <memcmp+0x14>
  }
  return 0;
 2bc:	4501                	li	a0,0
 2be:	a019                	j	2c4 <memcmp+0x30>
      return *p1 - *p2;
 2c0:	40e7853b          	subw	a0,a5,a4
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	bfe5                	j	2c4 <memcmp+0x30>

00000000000002ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e406                	sd	ra,8(sp)
 2d2:	e022                	sd	s0,0(sp)
 2d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d6:	00000097          	auipc	ra,0x0
 2da:	f66080e7          	jalr	-154(ra) # 23c <memmove>
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret

00000000000002e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e6:	4885                	li	a7,1
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ee:	4889                	li	a7,2
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f6:	488d                	li	a7,3
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fe:	4891                	li	a7,4
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <read>:
.global read
read:
 li a7, SYS_read
 306:	4895                	li	a7,5
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <write>:
.global write
write:
 li a7, SYS_write
 30e:	48c1                	li	a7,16
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <close>:
.global close
close:
 li a7, SYS_close
 316:	48d5                	li	a7,21
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <kill>:
.global kill
kill:
 li a7, SYS_kill
 31e:	4899                	li	a7,6
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <exec>:
.global exec
exec:
 li a7, SYS_exec
 326:	489d                	li	a7,7
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <open>:
.global open
open:
 li a7, SYS_open
 32e:	48bd                	li	a7,15
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 336:	48c5                	li	a7,17
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33e:	48c9                	li	a7,18
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 346:	48a1                	li	a7,8
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <link>:
.global link
link:
 li a7, SYS_link
 34e:	48cd                	li	a7,19
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 356:	48d1                	li	a7,20
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35e:	48a5                	li	a7,9
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <dup>:
.global dup
dup:
 li a7, SYS_dup
 366:	48a9                	li	a7,10
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36e:	48ad                	li	a7,11
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 376:	48b1                	li	a7,12
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37e:	48b5                	li	a7,13
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 386:	48b9                	li	a7,14
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 38e:	48d9                	li	a7,22
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 396:	48dd                	li	a7,23
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 39e:	48e1                	li	a7,24
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3a6:	48e5                	li	a7,25
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3ae:	48e9                	li	a7,26
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b6:	1101                	addi	sp,sp,-32
 3b8:	ec06                	sd	ra,24(sp)
 3ba:	e822                	sd	s0,16(sp)
 3bc:	1000                	addi	s0,sp,32
 3be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c2:	4605                	li	a2,1
 3c4:	fef40593          	addi	a1,s0,-17
 3c8:	00000097          	auipc	ra,0x0
 3cc:	f46080e7          	jalr	-186(ra) # 30e <write>
}
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6105                	addi	sp,sp,32
 3d6:	8082                	ret

00000000000003d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d8:	7139                	addi	sp,sp,-64
 3da:	fc06                	sd	ra,56(sp)
 3dc:	f822                	sd	s0,48(sp)
 3de:	f426                	sd	s1,40(sp)
 3e0:	0080                	addi	s0,sp,64
 3e2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3e4:	c299                	beqz	a3,3ea <printint+0x12>
 3e6:	0805cb63          	bltz	a1,47c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ea:	2581                	sext.w	a1,a1
  neg = 0;
 3ec:	4881                	li	a7,0
 3ee:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3f2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3f4:	2601                	sext.w	a2,a2
 3f6:	00000517          	auipc	a0,0x0
 3fa:	4c250513          	addi	a0,a0,1218 # 8b8 <digits>
 3fe:	883a                	mv	a6,a4
 400:	2705                	addiw	a4,a4,1
 402:	02c5f7bb          	remuw	a5,a1,a2
 406:	1782                	slli	a5,a5,0x20
 408:	9381                	srli	a5,a5,0x20
 40a:	97aa                	add	a5,a5,a0
 40c:	0007c783          	lbu	a5,0(a5)
 410:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 414:	0005879b          	sext.w	a5,a1
 418:	02c5d5bb          	divuw	a1,a1,a2
 41c:	0685                	addi	a3,a3,1
 41e:	fec7f0e3          	bgeu	a5,a2,3fe <printint+0x26>
  if(neg)
 422:	00088c63          	beqz	a7,43a <printint+0x62>
    buf[i++] = '-';
 426:	fd070793          	addi	a5,a4,-48
 42a:	00878733          	add	a4,a5,s0
 42e:	02d00793          	li	a5,45
 432:	fef70823          	sb	a5,-16(a4)
 436:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 43a:	02e05c63          	blez	a4,472 <printint+0x9a>
 43e:	f04a                	sd	s2,32(sp)
 440:	ec4e                	sd	s3,24(sp)
 442:	fc040793          	addi	a5,s0,-64
 446:	00e78933          	add	s2,a5,a4
 44a:	fff78993          	addi	s3,a5,-1
 44e:	99ba                	add	s3,s3,a4
 450:	377d                	addiw	a4,a4,-1
 452:	1702                	slli	a4,a4,0x20
 454:	9301                	srli	a4,a4,0x20
 456:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45a:	fff94583          	lbu	a1,-1(s2)
 45e:	8526                	mv	a0,s1
 460:	00000097          	auipc	ra,0x0
 464:	f56080e7          	jalr	-170(ra) # 3b6 <putc>
  while(--i >= 0)
 468:	197d                	addi	s2,s2,-1
 46a:	ff3918e3          	bne	s2,s3,45a <printint+0x82>
 46e:	7902                	ld	s2,32(sp)
 470:	69e2                	ld	s3,24(sp)
}
 472:	70e2                	ld	ra,56(sp)
 474:	7442                	ld	s0,48(sp)
 476:	74a2                	ld	s1,40(sp)
 478:	6121                	addi	sp,sp,64
 47a:	8082                	ret
    x = -xx;
 47c:	40b005bb          	negw	a1,a1
    neg = 1;
 480:	4885                	li	a7,1
    x = -xx;
 482:	b7b5                	j	3ee <printint+0x16>

0000000000000484 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 484:	715d                	addi	sp,sp,-80
 486:	e486                	sd	ra,72(sp)
 488:	e0a2                	sd	s0,64(sp)
 48a:	f84a                	sd	s2,48(sp)
 48c:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48e:	0005c903          	lbu	s2,0(a1)
 492:	1a090a63          	beqz	s2,646 <vprintf+0x1c2>
 496:	fc26                	sd	s1,56(sp)
 498:	f44e                	sd	s3,40(sp)
 49a:	f052                	sd	s4,32(sp)
 49c:	ec56                	sd	s5,24(sp)
 49e:	e85a                	sd	s6,16(sp)
 4a0:	e45e                	sd	s7,8(sp)
 4a2:	8aaa                	mv	s5,a0
 4a4:	8bb2                	mv	s7,a2
 4a6:	00158493          	addi	s1,a1,1
  state = 0;
 4aa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ac:	02500a13          	li	s4,37
 4b0:	4b55                	li	s6,21
 4b2:	a839                	j	4d0 <vprintf+0x4c>
        putc(fd, c);
 4b4:	85ca                	mv	a1,s2
 4b6:	8556                	mv	a0,s5
 4b8:	00000097          	auipc	ra,0x0
 4bc:	efe080e7          	jalr	-258(ra) # 3b6 <putc>
 4c0:	a019                	j	4c6 <vprintf+0x42>
    } else if(state == '%'){
 4c2:	01498d63          	beq	s3,s4,4dc <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4c6:	0485                	addi	s1,s1,1
 4c8:	fff4c903          	lbu	s2,-1(s1)
 4cc:	16090763          	beqz	s2,63a <vprintf+0x1b6>
    if(state == 0){
 4d0:	fe0999e3          	bnez	s3,4c2 <vprintf+0x3e>
      if(c == '%'){
 4d4:	ff4910e3          	bne	s2,s4,4b4 <vprintf+0x30>
        state = '%';
 4d8:	89d2                	mv	s3,s4
 4da:	b7f5                	j	4c6 <vprintf+0x42>
      if(c == 'd'){
 4dc:	13490463          	beq	s2,s4,604 <vprintf+0x180>
 4e0:	f9d9079b          	addiw	a5,s2,-99
 4e4:	0ff7f793          	zext.b	a5,a5
 4e8:	12fb6763          	bltu	s6,a5,616 <vprintf+0x192>
 4ec:	f9d9079b          	addiw	a5,s2,-99
 4f0:	0ff7f713          	zext.b	a4,a5
 4f4:	12eb6163          	bltu	s6,a4,616 <vprintf+0x192>
 4f8:	00271793          	slli	a5,a4,0x2
 4fc:	00000717          	auipc	a4,0x0
 500:	36470713          	addi	a4,a4,868 # 860 <malloc+0x12a>
 504:	97ba                	add	a5,a5,a4
 506:	439c                	lw	a5,0(a5)
 508:	97ba                	add	a5,a5,a4
 50a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 50c:	008b8913          	addi	s2,s7,8
 510:	4685                	li	a3,1
 512:	4629                	li	a2,10
 514:	000ba583          	lw	a1,0(s7)
 518:	8556                	mv	a0,s5
 51a:	00000097          	auipc	ra,0x0
 51e:	ebe080e7          	jalr	-322(ra) # 3d8 <printint>
 522:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 524:	4981                	li	s3,0
 526:	b745                	j	4c6 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 528:	008b8913          	addi	s2,s7,8
 52c:	4681                	li	a3,0
 52e:	4629                	li	a2,10
 530:	000ba583          	lw	a1,0(s7)
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	ea2080e7          	jalr	-350(ra) # 3d8 <printint>
 53e:	8bca                	mv	s7,s2
      state = 0;
 540:	4981                	li	s3,0
 542:	b751                	j	4c6 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 544:	008b8913          	addi	s2,s7,8
 548:	4681                	li	a3,0
 54a:	4641                	li	a2,16
 54c:	000ba583          	lw	a1,0(s7)
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	e86080e7          	jalr	-378(ra) # 3d8 <printint>
 55a:	8bca                	mv	s7,s2
      state = 0;
 55c:	4981                	li	s3,0
 55e:	b7a5                	j	4c6 <vprintf+0x42>
 560:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 562:	008b8c13          	addi	s8,s7,8
 566:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 56a:	03000593          	li	a1,48
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	e46080e7          	jalr	-442(ra) # 3b6 <putc>
  putc(fd, 'x');
 578:	07800593          	li	a1,120
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e38080e7          	jalr	-456(ra) # 3b6 <putc>
 586:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 588:	00000b97          	auipc	s7,0x0
 58c:	330b8b93          	addi	s7,s7,816 # 8b8 <digits>
 590:	03c9d793          	srli	a5,s3,0x3c
 594:	97de                	add	a5,a5,s7
 596:	0007c583          	lbu	a1,0(a5)
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e1a080e7          	jalr	-486(ra) # 3b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5a4:	0992                	slli	s3,s3,0x4
 5a6:	397d                	addiw	s2,s2,-1
 5a8:	fe0914e3          	bnez	s2,590 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5ac:	8be2                	mv	s7,s8
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	6c02                	ld	s8,0(sp)
 5b2:	bf11                	j	4c6 <vprintf+0x42>
        s = va_arg(ap, char*);
 5b4:	008b8993          	addi	s3,s7,8
 5b8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5bc:	02090163          	beqz	s2,5de <vprintf+0x15a>
        while(*s != 0){
 5c0:	00094583          	lbu	a1,0(s2)
 5c4:	c9a5                	beqz	a1,634 <vprintf+0x1b0>
          putc(fd, *s);
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	dee080e7          	jalr	-530(ra) # 3b6 <putc>
          s++;
 5d0:	0905                	addi	s2,s2,1
        while(*s != 0){
 5d2:	00094583          	lbu	a1,0(s2)
 5d6:	f9e5                	bnez	a1,5c6 <vprintf+0x142>
        s = va_arg(ap, char*);
 5d8:	8bce                	mv	s7,s3
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b5ed                	j	4c6 <vprintf+0x42>
          s = "(null)";
 5de:	00000917          	auipc	s2,0x0
 5e2:	27a90913          	addi	s2,s2,634 # 858 <malloc+0x122>
        while(*s != 0){
 5e6:	02800593          	li	a1,40
 5ea:	bff1                	j	5c6 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	000bc583          	lbu	a1,0(s7)
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	dc0080e7          	jalr	-576(ra) # 3b6 <putc>
 5fe:	8bca                	mv	s7,s2
      state = 0;
 600:	4981                	li	s3,0
 602:	b5d1                	j	4c6 <vprintf+0x42>
        putc(fd, c);
 604:	02500593          	li	a1,37
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	dac080e7          	jalr	-596(ra) # 3b6 <putc>
      state = 0;
 612:	4981                	li	s3,0
 614:	bd4d                	j	4c6 <vprintf+0x42>
        putc(fd, '%');
 616:	02500593          	li	a1,37
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	d9a080e7          	jalr	-614(ra) # 3b6 <putc>
        putc(fd, c);
 624:	85ca                	mv	a1,s2
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	d8e080e7          	jalr	-626(ra) # 3b6 <putc>
      state = 0;
 630:	4981                	li	s3,0
 632:	bd51                	j	4c6 <vprintf+0x42>
        s = va_arg(ap, char*);
 634:	8bce                	mv	s7,s3
      state = 0;
 636:	4981                	li	s3,0
 638:	b579                	j	4c6 <vprintf+0x42>
 63a:	74e2                	ld	s1,56(sp)
 63c:	79a2                	ld	s3,40(sp)
 63e:	7a02                	ld	s4,32(sp)
 640:	6ae2                	ld	s5,24(sp)
 642:	6b42                	ld	s6,16(sp)
 644:	6ba2                	ld	s7,8(sp)
    }
  }
}
 646:	60a6                	ld	ra,72(sp)
 648:	6406                	ld	s0,64(sp)
 64a:	7942                	ld	s2,48(sp)
 64c:	6161                	addi	sp,sp,80
 64e:	8082                	ret

0000000000000650 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 650:	715d                	addi	sp,sp,-80
 652:	ec06                	sd	ra,24(sp)
 654:	e822                	sd	s0,16(sp)
 656:	1000                	addi	s0,sp,32
 658:	e010                	sd	a2,0(s0)
 65a:	e414                	sd	a3,8(s0)
 65c:	e818                	sd	a4,16(s0)
 65e:	ec1c                	sd	a5,24(s0)
 660:	03043023          	sd	a6,32(s0)
 664:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 668:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 66c:	8622                	mv	a2,s0
 66e:	00000097          	auipc	ra,0x0
 672:	e16080e7          	jalr	-490(ra) # 484 <vprintf>
}
 676:	60e2                	ld	ra,24(sp)
 678:	6442                	ld	s0,16(sp)
 67a:	6161                	addi	sp,sp,80
 67c:	8082                	ret

000000000000067e <printf>:

void
printf(const char *fmt, ...)
{
 67e:	711d                	addi	sp,sp,-96
 680:	ec06                	sd	ra,24(sp)
 682:	e822                	sd	s0,16(sp)
 684:	1000                	addi	s0,sp,32
 686:	e40c                	sd	a1,8(s0)
 688:	e810                	sd	a2,16(s0)
 68a:	ec14                	sd	a3,24(s0)
 68c:	f018                	sd	a4,32(s0)
 68e:	f41c                	sd	a5,40(s0)
 690:	03043823          	sd	a6,48(s0)
 694:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 698:	00840613          	addi	a2,s0,8
 69c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a0:	85aa                	mv	a1,a0
 6a2:	4505                	li	a0,1
 6a4:	00000097          	auipc	ra,0x0
 6a8:	de0080e7          	jalr	-544(ra) # 484 <vprintf>
}
 6ac:	60e2                	ld	ra,24(sp)
 6ae:	6442                	ld	s0,16(sp)
 6b0:	6125                	addi	sp,sp,96
 6b2:	8082                	ret

00000000000006b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b4:	1141                	addi	sp,sp,-16
 6b6:	e422                	sd	s0,8(sp)
 6b8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ba:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6be:	00001797          	auipc	a5,0x1
 6c2:	d227b783          	ld	a5,-734(a5) # 13e0 <freep>
 6c6:	a02d                	j	6f0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c8:	4618                	lw	a4,8(a2)
 6ca:	9f2d                	addw	a4,a4,a1
 6cc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d0:	6398                	ld	a4,0(a5)
 6d2:	6310                	ld	a2,0(a4)
 6d4:	a83d                	j	712 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d6:	ff852703          	lw	a4,-8(a0)
 6da:	9f31                	addw	a4,a4,a2
 6dc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6de:	ff053683          	ld	a3,-16(a0)
 6e2:	a091                	j	726 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e4:	6398                	ld	a4,0(a5)
 6e6:	00e7e463          	bltu	a5,a4,6ee <free+0x3a>
 6ea:	00e6ea63          	bltu	a3,a4,6fe <free+0x4a>
{
 6ee:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f0:	fed7fae3          	bgeu	a5,a3,6e4 <free+0x30>
 6f4:	6398                	ld	a4,0(a5)
 6f6:	00e6e463          	bltu	a3,a4,6fe <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fa:	fee7eae3          	bltu	a5,a4,6ee <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6fe:	ff852583          	lw	a1,-8(a0)
 702:	6390                	ld	a2,0(a5)
 704:	02059813          	slli	a6,a1,0x20
 708:	01c85713          	srli	a4,a6,0x1c
 70c:	9736                	add	a4,a4,a3
 70e:	fae60de3          	beq	a2,a4,6c8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 712:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 716:	4790                	lw	a2,8(a5)
 718:	02061593          	slli	a1,a2,0x20
 71c:	01c5d713          	srli	a4,a1,0x1c
 720:	973e                	add	a4,a4,a5
 722:	fae68ae3          	beq	a3,a4,6d6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 726:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 728:	00001717          	auipc	a4,0x1
 72c:	caf73c23          	sd	a5,-840(a4) # 13e0 <freep>
}
 730:	6422                	ld	s0,8(sp)
 732:	0141                	addi	sp,sp,16
 734:	8082                	ret

0000000000000736 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 736:	7139                	addi	sp,sp,-64
 738:	fc06                	sd	ra,56(sp)
 73a:	f822                	sd	s0,48(sp)
 73c:	f426                	sd	s1,40(sp)
 73e:	ec4e                	sd	s3,24(sp)
 740:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 742:	02051493          	slli	s1,a0,0x20
 746:	9081                	srli	s1,s1,0x20
 748:	04bd                	addi	s1,s1,15
 74a:	8091                	srli	s1,s1,0x4
 74c:	0014899b          	addiw	s3,s1,1
 750:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 752:	00001517          	auipc	a0,0x1
 756:	c8e53503          	ld	a0,-882(a0) # 13e0 <freep>
 75a:	c915                	beqz	a0,78e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 75e:	4798                	lw	a4,8(a5)
 760:	08977e63          	bgeu	a4,s1,7fc <malloc+0xc6>
 764:	f04a                	sd	s2,32(sp)
 766:	e852                	sd	s4,16(sp)
 768:	e456                	sd	s5,8(sp)
 76a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 76c:	8a4e                	mv	s4,s3
 76e:	0009871b          	sext.w	a4,s3
 772:	6685                	lui	a3,0x1
 774:	00d77363          	bgeu	a4,a3,77a <malloc+0x44>
 778:	6a05                	lui	s4,0x1
 77a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 77e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 782:	00001917          	auipc	s2,0x1
 786:	c5e90913          	addi	s2,s2,-930 # 13e0 <freep>
  if(p == (char*)-1)
 78a:	5afd                	li	s5,-1
 78c:	a091                	j	7d0 <malloc+0x9a>
 78e:	f04a                	sd	s2,32(sp)
 790:	e852                	sd	s4,16(sp)
 792:	e456                	sd	s5,8(sp)
 794:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 796:	00001797          	auipc	a5,0x1
 79a:	c5a78793          	addi	a5,a5,-934 # 13f0 <base>
 79e:	00001717          	auipc	a4,0x1
 7a2:	c4f73123          	sd	a5,-958(a4) # 13e0 <freep>
 7a6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ac:	b7c1                	j	76c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7ae:	6398                	ld	a4,0(a5)
 7b0:	e118                	sd	a4,0(a0)
 7b2:	a08d                	j	814 <malloc+0xde>
  hp->s.size = nu;
 7b4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b8:	0541                	addi	a0,a0,16
 7ba:	00000097          	auipc	ra,0x0
 7be:	efa080e7          	jalr	-262(ra) # 6b4 <free>
  return freep;
 7c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c6:	c13d                	beqz	a0,82c <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ca:	4798                	lw	a4,8(a5)
 7cc:	02977463          	bgeu	a4,s1,7f4 <malloc+0xbe>
    if(p == freep)
 7d0:	00093703          	ld	a4,0(s2)
 7d4:	853e                	mv	a0,a5
 7d6:	fef719e3          	bne	a4,a5,7c8 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7da:	8552                	mv	a0,s4
 7dc:	00000097          	auipc	ra,0x0
 7e0:	b9a080e7          	jalr	-1126(ra) # 376 <sbrk>
  if(p == (char*)-1)
 7e4:	fd5518e3          	bne	a0,s5,7b4 <malloc+0x7e>
        return 0;
 7e8:	4501                	li	a0,0
 7ea:	7902                	ld	s2,32(sp)
 7ec:	6a42                	ld	s4,16(sp)
 7ee:	6aa2                	ld	s5,8(sp)
 7f0:	6b02                	ld	s6,0(sp)
 7f2:	a03d                	j	820 <malloc+0xea>
 7f4:	7902                	ld	s2,32(sp)
 7f6:	6a42                	ld	s4,16(sp)
 7f8:	6aa2                	ld	s5,8(sp)
 7fa:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7fc:	fae489e3          	beq	s1,a4,7ae <malloc+0x78>
        p->s.size -= nunits;
 800:	4137073b          	subw	a4,a4,s3
 804:	c798                	sw	a4,8(a5)
        p += p->s.size;
 806:	02071693          	slli	a3,a4,0x20
 80a:	01c6d713          	srli	a4,a3,0x1c
 80e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 810:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 814:	00001717          	auipc	a4,0x1
 818:	bca73623          	sd	a0,-1076(a4) # 13e0 <freep>
      return (void*)(p + 1);
 81c:	01078513          	addi	a0,a5,16
  }
}
 820:	70e2                	ld	ra,56(sp)
 822:	7442                	ld	s0,48(sp)
 824:	74a2                	ld	s1,40(sp)
 826:	69e2                	ld	s3,24(sp)
 828:	6121                	addi	sp,sp,64
 82a:	8082                	ret
 82c:	7902                	ld	s2,32(sp)
 82e:	6a42                	ld	s4,16(sp)
 830:	6aa2                	ld	s5,8(sp)
 832:	6b02                	ld	s6,0(sp)
 834:	b7f5                	j	820 <malloc+0xea>
