
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	422d8d93          	addi	s11,s11,1058 # 1450 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	928a0a13          	addi	s4,s4,-1752 # 960 <malloc+0x102>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1f8080e7          	jalr	504(ra) # 23e <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01348d63          	beq	s1,s3,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2c05                	addiw	s8,s8,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0917e3          	bnez	s2,52 <wc+0x52>
        w++;
  68:	2c85                	addiw	s9,s9,1
        inword = 1;
  6a:	4905                	li	s2,1
  6c:	b7dd                	j	52 <wc+0x52>
  6e:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	85ee                	mv	a1,s11
  78:	f8843503          	ld	a0,-120(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	3b2080e7          	jalr	946(ra) # 42e <read>
  84:	8b2a                	mv	s6,a0
  86:	00a05963          	blez	a0,98 <wc+0x98>
    for(i=0; i<n; i++){
  8a:	00001497          	auipc	s1,0x1
  8e:	3c648493          	addi	s1,s1,966 # 1450 <buf>
  92:	009509b3          	add	s3,a0,s1
  96:	b7c9                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  98:	02054e63          	bltz	a0,d4 <wc+0xd4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  9c:	f8043703          	ld	a4,-128(s0)
  a0:	86ea                	mv	a3,s10
  a2:	8666                	mv	a2,s9
  a4:	85e2                	mv	a1,s8
  a6:	00001517          	auipc	a0,0x1
  aa:	8da50513          	addi	a0,a0,-1830 # 980 <malloc+0x122>
  ae:	00000097          	auipc	ra,0x0
  b2:	6f8080e7          	jalr	1784(ra) # 7a6 <printf>
}
  b6:	70e6                	ld	ra,120(sp)
  b8:	7446                	ld	s0,112(sp)
  ba:	74a6                	ld	s1,104(sp)
  bc:	7906                	ld	s2,96(sp)
  be:	69e6                	ld	s3,88(sp)
  c0:	6a46                	ld	s4,80(sp)
  c2:	6aa6                	ld	s5,72(sp)
  c4:	6b06                	ld	s6,64(sp)
  c6:	7be2                	ld	s7,56(sp)
  c8:	7c42                	ld	s8,48(sp)
  ca:	7ca2                	ld	s9,40(sp)
  cc:	7d02                	ld	s10,32(sp)
  ce:	6de2                	ld	s11,24(sp)
  d0:	6109                	addi	sp,sp,128
  d2:	8082                	ret
    printf("wc: read error\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	89c50513          	addi	a0,a0,-1892 # 970 <malloc+0x112>
  dc:	00000097          	auipc	ra,0x0
  e0:	6ca080e7          	jalr	1738(ra) # 7a6 <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	330080e7          	jalr	816(ra) # 416 <exit>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	addi	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  f6:	4785                	li	a5,1
  f8:	04a7dc63          	bge	a5,a0,150 <main+0x62>
  fc:	ec26                	sd	s1,24(sp)
  fe:	e84a                	sd	s2,16(sp)
 100:	e44e                	sd	s3,8(sp)
 102:	00858913          	addi	s2,a1,8
 106:	ffe5099b          	addiw	s3,a0,-2
 10a:	02099793          	slli	a5,s3,0x20
 10e:	01d7d993          	srli	s3,a5,0x1d
 112:	05c1                	addi	a1,a1,16
 114:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 116:	4581                	li	a1,0
 118:	00093503          	ld	a0,0(s2)
 11c:	00000097          	auipc	ra,0x0
 120:	33a080e7          	jalr	826(ra) # 456 <open>
 124:	84aa                	mv	s1,a0
 126:	04054663          	bltz	a0,172 <main+0x84>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 12a:	00093583          	ld	a1,0(s2)
 12e:	00000097          	auipc	ra,0x0
 132:	ed2080e7          	jalr	-302(ra) # 0 <wc>
    close(fd);
 136:	8526                	mv	a0,s1
 138:	00000097          	auipc	ra,0x0
 13c:	306080e7          	jalr	774(ra) # 43e <close>
  for(i = 1; i < argc; i++){
 140:	0921                	addi	s2,s2,8
 142:	fd391ae3          	bne	s2,s3,116 <main+0x28>
  }
  exit(0);
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	2ce080e7          	jalr	718(ra) # 416 <exit>
 150:	ec26                	sd	s1,24(sp)
 152:	e84a                	sd	s2,16(sp)
 154:	e44e                	sd	s3,8(sp)
    wc(0, "");
 156:	00001597          	auipc	a1,0x1
 15a:	81258593          	addi	a1,a1,-2030 # 968 <malloc+0x10a>
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	ea0080e7          	jalr	-352(ra) # 0 <wc>
    exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	2ac080e7          	jalr	684(ra) # 416 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 172:	00093583          	ld	a1,0(s2)
 176:	00001517          	auipc	a0,0x1
 17a:	81a50513          	addi	a0,a0,-2022 # 990 <malloc+0x132>
 17e:	00000097          	auipc	ra,0x0
 182:	628080e7          	jalr	1576(ra) # 7a6 <printf>
      exit(1);
 186:	4505                	li	a0,1
 188:	00000097          	auipc	ra,0x0
 18c:	28e080e7          	jalr	654(ra) # 416 <exit>

0000000000000190 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 190:	1141                	addi	sp,sp,-16
 192:	e406                	sd	ra,8(sp)
 194:	e022                	sd	s0,0(sp)
 196:	0800                	addi	s0,sp,16
  extern int main();
  main();
 198:	00000097          	auipc	ra,0x0
 19c:	f56080e7          	jalr	-170(ra) # ee <main>
  exit(0);
 1a0:	4501                	li	a0,0
 1a2:	00000097          	auipc	ra,0x0
 1a6:	274080e7          	jalr	628(ra) # 416 <exit>

00000000000001aa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b0:	87aa                	mv	a5,a0
 1b2:	0585                	addi	a1,a1,1
 1b4:	0785                	addi	a5,a5,1
 1b6:	fff5c703          	lbu	a4,-1(a1)
 1ba:	fee78fa3          	sb	a4,-1(a5)
 1be:	fb75                	bnez	a4,1b2 <strcpy+0x8>
    ;
  return os;
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret

00000000000001c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	cb91                	beqz	a5,1e4 <strcmp+0x1e>
 1d2:	0005c703          	lbu	a4,0(a1)
 1d6:	00f71763          	bne	a4,a5,1e4 <strcmp+0x1e>
    p++, q++;
 1da:	0505                	addi	a0,a0,1
 1dc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	fbe5                	bnez	a5,1d2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1e4:	0005c503          	lbu	a0,0(a1)
}
 1e8:	40a7853b          	subw	a0,a5,a0
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret

00000000000001f2 <strlen>:

uint
strlen(const char *s)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cf91                	beqz	a5,218 <strlen+0x26>
 1fe:	0505                	addi	a0,a0,1
 200:	87aa                	mv	a5,a0
 202:	86be                	mv	a3,a5
 204:	0785                	addi	a5,a5,1
 206:	fff7c703          	lbu	a4,-1(a5)
 20a:	ff65                	bnez	a4,202 <strlen+0x10>
 20c:	40a6853b          	subw	a0,a3,a0
 210:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
  for(n = 0; s[n]; n++)
 218:	4501                	li	a0,0
 21a:	bfe5                	j	212 <strlen+0x20>

000000000000021c <memset>:

void*
memset(void *dst, int c, uint n)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 222:	ca19                	beqz	a2,238 <memset+0x1c>
 224:	87aa                	mv	a5,a0
 226:	1602                	slli	a2,a2,0x20
 228:	9201                	srli	a2,a2,0x20
 22a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 22e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 232:	0785                	addi	a5,a5,1
 234:	fee79de3          	bne	a5,a4,22e <memset+0x12>
  }
  return dst;
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret

000000000000023e <strchr>:

char*
strchr(const char *s, char c)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  for(; *s; s++)
 244:	00054783          	lbu	a5,0(a0)
 248:	cb99                	beqz	a5,25e <strchr+0x20>
    if(*s == c)
 24a:	00f58763          	beq	a1,a5,258 <strchr+0x1a>
  for(; *s; s++)
 24e:	0505                	addi	a0,a0,1
 250:	00054783          	lbu	a5,0(a0)
 254:	fbfd                	bnez	a5,24a <strchr+0xc>
      return (char*)s;
  return 0;
 256:	4501                	li	a0,0
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  return 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <strchr+0x1a>

0000000000000262 <gets>:

char*
gets(char *buf, int max)
{
 262:	711d                	addi	sp,sp,-96
 264:	ec86                	sd	ra,88(sp)
 266:	e8a2                	sd	s0,80(sp)
 268:	e4a6                	sd	s1,72(sp)
 26a:	e0ca                	sd	s2,64(sp)
 26c:	fc4e                	sd	s3,56(sp)
 26e:	f852                	sd	s4,48(sp)
 270:	f456                	sd	s5,40(sp)
 272:	f05a                	sd	s6,32(sp)
 274:	ec5e                	sd	s7,24(sp)
 276:	1080                	addi	s0,sp,96
 278:	8baa                	mv	s7,a0
 27a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27c:	892a                	mv	s2,a0
 27e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 280:	4aa9                	li	s5,10
 282:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 284:	89a6                	mv	s3,s1
 286:	2485                	addiw	s1,s1,1
 288:	0344d863          	bge	s1,s4,2b8 <gets+0x56>
    cc = read(0, &c, 1);
 28c:	4605                	li	a2,1
 28e:	faf40593          	addi	a1,s0,-81
 292:	4501                	li	a0,0
 294:	00000097          	auipc	ra,0x0
 298:	19a080e7          	jalr	410(ra) # 42e <read>
    if(cc < 1)
 29c:	00a05e63          	blez	a0,2b8 <gets+0x56>
    buf[i++] = c;
 2a0:	faf44783          	lbu	a5,-81(s0)
 2a4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a8:	01578763          	beq	a5,s5,2b6 <gets+0x54>
 2ac:	0905                	addi	s2,s2,1
 2ae:	fd679be3          	bne	a5,s6,284 <gets+0x22>
    buf[i++] = c;
 2b2:	89a6                	mv	s3,s1
 2b4:	a011                	j	2b8 <gets+0x56>
 2b6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b8:	99de                	add	s3,s3,s7
 2ba:	00098023          	sb	zero,0(s3)
  return buf;
}
 2be:	855e                	mv	a0,s7
 2c0:	60e6                	ld	ra,88(sp)
 2c2:	6446                	ld	s0,80(sp)
 2c4:	64a6                	ld	s1,72(sp)
 2c6:	6906                	ld	s2,64(sp)
 2c8:	79e2                	ld	s3,56(sp)
 2ca:	7a42                	ld	s4,48(sp)
 2cc:	7aa2                	ld	s5,40(sp)
 2ce:	7b02                	ld	s6,32(sp)
 2d0:	6be2                	ld	s7,24(sp)
 2d2:	6125                	addi	sp,sp,96
 2d4:	8082                	ret

00000000000002d6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d6:	1101                	addi	sp,sp,-32
 2d8:	ec06                	sd	ra,24(sp)
 2da:	e822                	sd	s0,16(sp)
 2dc:	e04a                	sd	s2,0(sp)
 2de:	1000                	addi	s0,sp,32
 2e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e2:	4581                	li	a1,0
 2e4:	00000097          	auipc	ra,0x0
 2e8:	172080e7          	jalr	370(ra) # 456 <open>
  if(fd < 0)
 2ec:	02054663          	bltz	a0,318 <stat+0x42>
 2f0:	e426                	sd	s1,8(sp)
 2f2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2f4:	85ca                	mv	a1,s2
 2f6:	00000097          	auipc	ra,0x0
 2fa:	178080e7          	jalr	376(ra) # 46e <fstat>
 2fe:	892a                	mv	s2,a0
  close(fd);
 300:	8526                	mv	a0,s1
 302:	00000097          	auipc	ra,0x0
 306:	13c080e7          	jalr	316(ra) # 43e <close>
  return r;
 30a:	64a2                	ld	s1,8(sp)
}
 30c:	854a                	mv	a0,s2
 30e:	60e2                	ld	ra,24(sp)
 310:	6442                	ld	s0,16(sp)
 312:	6902                	ld	s2,0(sp)
 314:	6105                	addi	sp,sp,32
 316:	8082                	ret
    return -1;
 318:	597d                	li	s2,-1
 31a:	bfcd                	j	30c <stat+0x36>

000000000000031c <atoi>:

int
atoi(const char *s)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 322:	00054683          	lbu	a3,0(a0)
 326:	fd06879b          	addiw	a5,a3,-48
 32a:	0ff7f793          	zext.b	a5,a5
 32e:	4625                	li	a2,9
 330:	02f66863          	bltu	a2,a5,360 <atoi+0x44>
 334:	872a                	mv	a4,a0
  n = 0;
 336:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 338:	0705                	addi	a4,a4,1
 33a:	0025179b          	slliw	a5,a0,0x2
 33e:	9fa9                	addw	a5,a5,a0
 340:	0017979b          	slliw	a5,a5,0x1
 344:	9fb5                	addw	a5,a5,a3
 346:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 34a:	00074683          	lbu	a3,0(a4)
 34e:	fd06879b          	addiw	a5,a3,-48
 352:	0ff7f793          	zext.b	a5,a5
 356:	fef671e3          	bgeu	a2,a5,338 <atoi+0x1c>
  return n;
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  n = 0;
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <atoi+0x3e>

0000000000000364 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 36a:	02b57463          	bgeu	a0,a1,392 <memmove+0x2e>
    while(n-- > 0)
 36e:	00c05f63          	blez	a2,38c <memmove+0x28>
 372:	1602                	slli	a2,a2,0x20
 374:	9201                	srli	a2,a2,0x20
 376:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 37a:	872a                	mv	a4,a0
      *dst++ = *src++;
 37c:	0585                	addi	a1,a1,1
 37e:	0705                	addi	a4,a4,1
 380:	fff5c683          	lbu	a3,-1(a1)
 384:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 388:	fef71ae3          	bne	a4,a5,37c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret
    dst += n;
 392:	00c50733          	add	a4,a0,a2
    src += n;
 396:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 398:	fec05ae3          	blez	a2,38c <memmove+0x28>
 39c:	fff6079b          	addiw	a5,a2,-1
 3a0:	1782                	slli	a5,a5,0x20
 3a2:	9381                	srli	a5,a5,0x20
 3a4:	fff7c793          	not	a5,a5
 3a8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3aa:	15fd                	addi	a1,a1,-1
 3ac:	177d                	addi	a4,a4,-1
 3ae:	0005c683          	lbu	a3,0(a1)
 3b2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b6:	fee79ae3          	bne	a5,a4,3aa <memmove+0x46>
 3ba:	bfc9                	j	38c <memmove+0x28>

00000000000003bc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e422                	sd	s0,8(sp)
 3c0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3c2:	ca05                	beqz	a2,3f2 <memcmp+0x36>
 3c4:	fff6069b          	addiw	a3,a2,-1
 3c8:	1682                	slli	a3,a3,0x20
 3ca:	9281                	srli	a3,a3,0x20
 3cc:	0685                	addi	a3,a3,1
 3ce:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3d0:	00054783          	lbu	a5,0(a0)
 3d4:	0005c703          	lbu	a4,0(a1)
 3d8:	00e79863          	bne	a5,a4,3e8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3dc:	0505                	addi	a0,a0,1
    p2++;
 3de:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e0:	fed518e3          	bne	a0,a3,3d0 <memcmp+0x14>
  }
  return 0;
 3e4:	4501                	li	a0,0
 3e6:	a019                	j	3ec <memcmp+0x30>
      return *p1 - *p2;
 3e8:	40e7853b          	subw	a0,a5,a4
}
 3ec:	6422                	ld	s0,8(sp)
 3ee:	0141                	addi	sp,sp,16
 3f0:	8082                	ret
  return 0;
 3f2:	4501                	li	a0,0
 3f4:	bfe5                	j	3ec <memcmp+0x30>

00000000000003f6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f6:	1141                	addi	sp,sp,-16
 3f8:	e406                	sd	ra,8(sp)
 3fa:	e022                	sd	s0,0(sp)
 3fc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3fe:	00000097          	auipc	ra,0x0
 402:	f66080e7          	jalr	-154(ra) # 364 <memmove>
}
 406:	60a2                	ld	ra,8(sp)
 408:	6402                	ld	s0,0(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret

000000000000040e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40e:	4885                	li	a7,1
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <exit>:
.global exit
exit:
 li a7, SYS_exit
 416:	4889                	li	a7,2
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <wait>:
.global wait
wait:
 li a7, SYS_wait
 41e:	488d                	li	a7,3
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 426:	4891                	li	a7,4
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <read>:
.global read
read:
 li a7, SYS_read
 42e:	4895                	li	a7,5
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <write>:
.global write
write:
 li a7, SYS_write
 436:	48c1                	li	a7,16
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <close>:
.global close
close:
 li a7, SYS_close
 43e:	48d5                	li	a7,21
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <kill>:
.global kill
kill:
 li a7, SYS_kill
 446:	4899                	li	a7,6
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <exec>:
.global exec
exec:
 li a7, SYS_exec
 44e:	489d                	li	a7,7
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <open>:
.global open
open:
 li a7, SYS_open
 456:	48bd                	li	a7,15
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 45e:	48c5                	li	a7,17
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 466:	48c9                	li	a7,18
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 46e:	48a1                	li	a7,8
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <link>:
.global link
link:
 li a7, SYS_link
 476:	48cd                	li	a7,19
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 47e:	48d1                	li	a7,20
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 486:	48a5                	li	a7,9
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <dup>:
.global dup
dup:
 li a7, SYS_dup
 48e:	48a9                	li	a7,10
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 496:	48ad                	li	a7,11
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 49e:	48b1                	li	a7,12
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a6:	48b5                	li	a7,13
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ae:	48b9                	li	a7,14
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 4b6:	48d9                	li	a7,22
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 4be:	48dd                	li	a7,23
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4c6:	48e1                	li	a7,24
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 4ce:	48e5                	li	a7,25
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 4d6:	48e9                	li	a7,26
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4de:	1101                	addi	sp,sp,-32
 4e0:	ec06                	sd	ra,24(sp)
 4e2:	e822                	sd	s0,16(sp)
 4e4:	1000                	addi	s0,sp,32
 4e6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ea:	4605                	li	a2,1
 4ec:	fef40593          	addi	a1,s0,-17
 4f0:	00000097          	auipc	ra,0x0
 4f4:	f46080e7          	jalr	-186(ra) # 436 <write>
}
 4f8:	60e2                	ld	ra,24(sp)
 4fa:	6442                	ld	s0,16(sp)
 4fc:	6105                	addi	sp,sp,32
 4fe:	8082                	ret

0000000000000500 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 500:	7139                	addi	sp,sp,-64
 502:	fc06                	sd	ra,56(sp)
 504:	f822                	sd	s0,48(sp)
 506:	f426                	sd	s1,40(sp)
 508:	0080                	addi	s0,sp,64
 50a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 50c:	c299                	beqz	a3,512 <printint+0x12>
 50e:	0805cb63          	bltz	a1,5a4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 512:	2581                	sext.w	a1,a1
  neg = 0;
 514:	4881                	li	a7,0
 516:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 51a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 51c:	2601                	sext.w	a2,a2
 51e:	00000517          	auipc	a0,0x0
 522:	4ea50513          	addi	a0,a0,1258 # a08 <digits>
 526:	883a                	mv	a6,a4
 528:	2705                	addiw	a4,a4,1
 52a:	02c5f7bb          	remuw	a5,a1,a2
 52e:	1782                	slli	a5,a5,0x20
 530:	9381                	srli	a5,a5,0x20
 532:	97aa                	add	a5,a5,a0
 534:	0007c783          	lbu	a5,0(a5)
 538:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 53c:	0005879b          	sext.w	a5,a1
 540:	02c5d5bb          	divuw	a1,a1,a2
 544:	0685                	addi	a3,a3,1
 546:	fec7f0e3          	bgeu	a5,a2,526 <printint+0x26>
  if(neg)
 54a:	00088c63          	beqz	a7,562 <printint+0x62>
    buf[i++] = '-';
 54e:	fd070793          	addi	a5,a4,-48
 552:	00878733          	add	a4,a5,s0
 556:	02d00793          	li	a5,45
 55a:	fef70823          	sb	a5,-16(a4)
 55e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 562:	02e05c63          	blez	a4,59a <printint+0x9a>
 566:	f04a                	sd	s2,32(sp)
 568:	ec4e                	sd	s3,24(sp)
 56a:	fc040793          	addi	a5,s0,-64
 56e:	00e78933          	add	s2,a5,a4
 572:	fff78993          	addi	s3,a5,-1
 576:	99ba                	add	s3,s3,a4
 578:	377d                	addiw	a4,a4,-1
 57a:	1702                	slli	a4,a4,0x20
 57c:	9301                	srli	a4,a4,0x20
 57e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 582:	fff94583          	lbu	a1,-1(s2)
 586:	8526                	mv	a0,s1
 588:	00000097          	auipc	ra,0x0
 58c:	f56080e7          	jalr	-170(ra) # 4de <putc>
  while(--i >= 0)
 590:	197d                	addi	s2,s2,-1
 592:	ff3918e3          	bne	s2,s3,582 <printint+0x82>
 596:	7902                	ld	s2,32(sp)
 598:	69e2                	ld	s3,24(sp)
}
 59a:	70e2                	ld	ra,56(sp)
 59c:	7442                	ld	s0,48(sp)
 59e:	74a2                	ld	s1,40(sp)
 5a0:	6121                	addi	sp,sp,64
 5a2:	8082                	ret
    x = -xx;
 5a4:	40b005bb          	negw	a1,a1
    neg = 1;
 5a8:	4885                	li	a7,1
    x = -xx;
 5aa:	b7b5                	j	516 <printint+0x16>

00000000000005ac <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ac:	715d                	addi	sp,sp,-80
 5ae:	e486                	sd	ra,72(sp)
 5b0:	e0a2                	sd	s0,64(sp)
 5b2:	f84a                	sd	s2,48(sp)
 5b4:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b6:	0005c903          	lbu	s2,0(a1)
 5ba:	1a090a63          	beqz	s2,76e <vprintf+0x1c2>
 5be:	fc26                	sd	s1,56(sp)
 5c0:	f44e                	sd	s3,40(sp)
 5c2:	f052                	sd	s4,32(sp)
 5c4:	ec56                	sd	s5,24(sp)
 5c6:	e85a                	sd	s6,16(sp)
 5c8:	e45e                	sd	s7,8(sp)
 5ca:	8aaa                	mv	s5,a0
 5cc:	8bb2                	mv	s7,a2
 5ce:	00158493          	addi	s1,a1,1
  state = 0;
 5d2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d4:	02500a13          	li	s4,37
 5d8:	4b55                	li	s6,21
 5da:	a839                	j	5f8 <vprintf+0x4c>
        putc(fd, c);
 5dc:	85ca                	mv	a1,s2
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	efe080e7          	jalr	-258(ra) # 4de <putc>
 5e8:	a019                	j	5ee <vprintf+0x42>
    } else if(state == '%'){
 5ea:	01498d63          	beq	s3,s4,604 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5ee:	0485                	addi	s1,s1,1
 5f0:	fff4c903          	lbu	s2,-1(s1)
 5f4:	16090763          	beqz	s2,762 <vprintf+0x1b6>
    if(state == 0){
 5f8:	fe0999e3          	bnez	s3,5ea <vprintf+0x3e>
      if(c == '%'){
 5fc:	ff4910e3          	bne	s2,s4,5dc <vprintf+0x30>
        state = '%';
 600:	89d2                	mv	s3,s4
 602:	b7f5                	j	5ee <vprintf+0x42>
      if(c == 'd'){
 604:	13490463          	beq	s2,s4,72c <vprintf+0x180>
 608:	f9d9079b          	addiw	a5,s2,-99
 60c:	0ff7f793          	zext.b	a5,a5
 610:	12fb6763          	bltu	s6,a5,73e <vprintf+0x192>
 614:	f9d9079b          	addiw	a5,s2,-99
 618:	0ff7f713          	zext.b	a4,a5
 61c:	12eb6163          	bltu	s6,a4,73e <vprintf+0x192>
 620:	00271793          	slli	a5,a4,0x2
 624:	00000717          	auipc	a4,0x0
 628:	38c70713          	addi	a4,a4,908 # 9b0 <malloc+0x152>
 62c:	97ba                	add	a5,a5,a4
 62e:	439c                	lw	a5,0(a5)
 630:	97ba                	add	a5,a5,a4
 632:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 634:	008b8913          	addi	s2,s7,8
 638:	4685                	li	a3,1
 63a:	4629                	li	a2,10
 63c:	000ba583          	lw	a1,0(s7)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	ebe080e7          	jalr	-322(ra) # 500 <printint>
 64a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b745                	j	5ee <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 650:	008b8913          	addi	s2,s7,8
 654:	4681                	li	a3,0
 656:	4629                	li	a2,10
 658:	000ba583          	lw	a1,0(s7)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	ea2080e7          	jalr	-350(ra) # 500 <printint>
 666:	8bca                	mv	s7,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	b751                	j	5ee <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 66c:	008b8913          	addi	s2,s7,8
 670:	4681                	li	a3,0
 672:	4641                	li	a2,16
 674:	000ba583          	lw	a1,0(s7)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e86080e7          	jalr	-378(ra) # 500 <printint>
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	b7a5                	j	5ee <vprintf+0x42>
 688:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 68a:	008b8c13          	addi	s8,s7,8
 68e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 692:	03000593          	li	a1,48
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	e46080e7          	jalr	-442(ra) # 4de <putc>
  putc(fd, 'x');
 6a0:	07800593          	li	a1,120
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e38080e7          	jalr	-456(ra) # 4de <putc>
 6ae:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b0:	00000b97          	auipc	s7,0x0
 6b4:	358b8b93          	addi	s7,s7,856 # a08 <digits>
 6b8:	03c9d793          	srli	a5,s3,0x3c
 6bc:	97de                	add	a5,a5,s7
 6be:	0007c583          	lbu	a1,0(a5)
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e1a080e7          	jalr	-486(ra) # 4de <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6cc:	0992                	slli	s3,s3,0x4
 6ce:	397d                	addiw	s2,s2,-1
 6d0:	fe0914e3          	bnez	s2,6b8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6d4:	8be2                	mv	s7,s8
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	6c02                	ld	s8,0(sp)
 6da:	bf11                	j	5ee <vprintf+0x42>
        s = va_arg(ap, char*);
 6dc:	008b8993          	addi	s3,s7,8
 6e0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6e4:	02090163          	beqz	s2,706 <vprintf+0x15a>
        while(*s != 0){
 6e8:	00094583          	lbu	a1,0(s2)
 6ec:	c9a5                	beqz	a1,75c <vprintf+0x1b0>
          putc(fd, *s);
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	dee080e7          	jalr	-530(ra) # 4de <putc>
          s++;
 6f8:	0905                	addi	s2,s2,1
        while(*s != 0){
 6fa:	00094583          	lbu	a1,0(s2)
 6fe:	f9e5                	bnez	a1,6ee <vprintf+0x142>
        s = va_arg(ap, char*);
 700:	8bce                	mv	s7,s3
      state = 0;
 702:	4981                	li	s3,0
 704:	b5ed                	j	5ee <vprintf+0x42>
          s = "(null)";
 706:	00000917          	auipc	s2,0x0
 70a:	2a290913          	addi	s2,s2,674 # 9a8 <malloc+0x14a>
        while(*s != 0){
 70e:	02800593          	li	a1,40
 712:	bff1                	j	6ee <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 714:	008b8913          	addi	s2,s7,8
 718:	000bc583          	lbu	a1,0(s7)
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	dc0080e7          	jalr	-576(ra) # 4de <putc>
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	b5d1                	j	5ee <vprintf+0x42>
        putc(fd, c);
 72c:	02500593          	li	a1,37
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	dac080e7          	jalr	-596(ra) # 4de <putc>
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bd4d                	j	5ee <vprintf+0x42>
        putc(fd, '%');
 73e:	02500593          	li	a1,37
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	d9a080e7          	jalr	-614(ra) # 4de <putc>
        putc(fd, c);
 74c:	85ca                	mv	a1,s2
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	d8e080e7          	jalr	-626(ra) # 4de <putc>
      state = 0;
 758:	4981                	li	s3,0
 75a:	bd51                	j	5ee <vprintf+0x42>
        s = va_arg(ap, char*);
 75c:	8bce                	mv	s7,s3
      state = 0;
 75e:	4981                	li	s3,0
 760:	b579                	j	5ee <vprintf+0x42>
 762:	74e2                	ld	s1,56(sp)
 764:	79a2                	ld	s3,40(sp)
 766:	7a02                	ld	s4,32(sp)
 768:	6ae2                	ld	s5,24(sp)
 76a:	6b42                	ld	s6,16(sp)
 76c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 76e:	60a6                	ld	ra,72(sp)
 770:	6406                	ld	s0,64(sp)
 772:	7942                	ld	s2,48(sp)
 774:	6161                	addi	sp,sp,80
 776:	8082                	ret

0000000000000778 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 778:	715d                	addi	sp,sp,-80
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e010                	sd	a2,0(s0)
 782:	e414                	sd	a3,8(s0)
 784:	e818                	sd	a4,16(s0)
 786:	ec1c                	sd	a5,24(s0)
 788:	03043023          	sd	a6,32(s0)
 78c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 790:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 794:	8622                	mv	a2,s0
 796:	00000097          	auipc	ra,0x0
 79a:	e16080e7          	jalr	-490(ra) # 5ac <vprintf>
}
 79e:	60e2                	ld	ra,24(sp)
 7a0:	6442                	ld	s0,16(sp)
 7a2:	6161                	addi	sp,sp,80
 7a4:	8082                	ret

00000000000007a6 <printf>:

void
printf(const char *fmt, ...)
{
 7a6:	711d                	addi	sp,sp,-96
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	1000                	addi	s0,sp,32
 7ae:	e40c                	sd	a1,8(s0)
 7b0:	e810                	sd	a2,16(s0)
 7b2:	ec14                	sd	a3,24(s0)
 7b4:	f018                	sd	a4,32(s0)
 7b6:	f41c                	sd	a5,40(s0)
 7b8:	03043823          	sd	a6,48(s0)
 7bc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c0:	00840613          	addi	a2,s0,8
 7c4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c8:	85aa                	mv	a1,a0
 7ca:	4505                	li	a0,1
 7cc:	00000097          	auipc	ra,0x0
 7d0:	de0080e7          	jalr	-544(ra) # 5ac <vprintf>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6125                	addi	sp,sp,96
 7da:	8082                	ret

00000000000007dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7dc:	1141                	addi	sp,sp,-16
 7de:	e422                	sd	s0,8(sp)
 7e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	00001797          	auipc	a5,0x1
 7ea:	c5a7b783          	ld	a5,-934(a5) # 1440 <freep>
 7ee:	a02d                	j	818 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f0:	4618                	lw	a4,8(a2)
 7f2:	9f2d                	addw	a4,a4,a1
 7f4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	6398                	ld	a4,0(a5)
 7fa:	6310                	ld	a2,0(a4)
 7fc:	a83d                	j	83a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fe:	ff852703          	lw	a4,-8(a0)
 802:	9f31                	addw	a4,a4,a2
 804:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 806:	ff053683          	ld	a3,-16(a0)
 80a:	a091                	j	84e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	6398                	ld	a4,0(a5)
 80e:	00e7e463          	bltu	a5,a4,816 <free+0x3a>
 812:	00e6ea63          	bltu	a3,a4,826 <free+0x4a>
{
 816:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 818:	fed7fae3          	bgeu	a5,a3,80c <free+0x30>
 81c:	6398                	ld	a4,0(a5)
 81e:	00e6e463          	bltu	a3,a4,826 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 822:	fee7eae3          	bltu	a5,a4,816 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 826:	ff852583          	lw	a1,-8(a0)
 82a:	6390                	ld	a2,0(a5)
 82c:	02059813          	slli	a6,a1,0x20
 830:	01c85713          	srli	a4,a6,0x1c
 834:	9736                	add	a4,a4,a3
 836:	fae60de3          	beq	a2,a4,7f0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 83a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 83e:	4790                	lw	a2,8(a5)
 840:	02061593          	slli	a1,a2,0x20
 844:	01c5d713          	srli	a4,a1,0x1c
 848:	973e                	add	a4,a4,a5
 84a:	fae68ae3          	beq	a3,a4,7fe <free+0x22>
    p->s.ptr = bp->s.ptr;
 84e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 850:	00001717          	auipc	a4,0x1
 854:	bef73823          	sd	a5,-1040(a4) # 1440 <freep>
}
 858:	6422                	ld	s0,8(sp)
 85a:	0141                	addi	sp,sp,16
 85c:	8082                	ret

000000000000085e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 85e:	7139                	addi	sp,sp,-64
 860:	fc06                	sd	ra,56(sp)
 862:	f822                	sd	s0,48(sp)
 864:	f426                	sd	s1,40(sp)
 866:	ec4e                	sd	s3,24(sp)
 868:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 86a:	02051493          	slli	s1,a0,0x20
 86e:	9081                	srli	s1,s1,0x20
 870:	04bd                	addi	s1,s1,15
 872:	8091                	srli	s1,s1,0x4
 874:	0014899b          	addiw	s3,s1,1
 878:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 87a:	00001517          	auipc	a0,0x1
 87e:	bc653503          	ld	a0,-1082(a0) # 1440 <freep>
 882:	c915                	beqz	a0,8b6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 886:	4798                	lw	a4,8(a5)
 888:	08977e63          	bgeu	a4,s1,924 <malloc+0xc6>
 88c:	f04a                	sd	s2,32(sp)
 88e:	e852                	sd	s4,16(sp)
 890:	e456                	sd	s5,8(sp)
 892:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 894:	8a4e                	mv	s4,s3
 896:	0009871b          	sext.w	a4,s3
 89a:	6685                	lui	a3,0x1
 89c:	00d77363          	bgeu	a4,a3,8a2 <malloc+0x44>
 8a0:	6a05                	lui	s4,0x1
 8a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8aa:	00001917          	auipc	s2,0x1
 8ae:	b9690913          	addi	s2,s2,-1130 # 1440 <freep>
  if(p == (char*)-1)
 8b2:	5afd                	li	s5,-1
 8b4:	a091                	j	8f8 <malloc+0x9a>
 8b6:	f04a                	sd	s2,32(sp)
 8b8:	e852                	sd	s4,16(sp)
 8ba:	e456                	sd	s5,8(sp)
 8bc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8be:	00001797          	auipc	a5,0x1
 8c2:	d9278793          	addi	a5,a5,-622 # 1650 <base>
 8c6:	00001717          	auipc	a4,0x1
 8ca:	b6f73d23          	sd	a5,-1158(a4) # 1440 <freep>
 8ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d4:	b7c1                	j	894 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8d6:	6398                	ld	a4,0(a5)
 8d8:	e118                	sd	a4,0(a0)
 8da:	a08d                	j	93c <malloc+0xde>
  hp->s.size = nu;
 8dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e0:	0541                	addi	a0,a0,16
 8e2:	00000097          	auipc	ra,0x0
 8e6:	efa080e7          	jalr	-262(ra) # 7dc <free>
  return freep;
 8ea:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ee:	c13d                	beqz	a0,954 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f2:	4798                	lw	a4,8(a5)
 8f4:	02977463          	bgeu	a4,s1,91c <malloc+0xbe>
    if(p == freep)
 8f8:	00093703          	ld	a4,0(s2)
 8fc:	853e                	mv	a0,a5
 8fe:	fef719e3          	bne	a4,a5,8f0 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 902:	8552                	mv	a0,s4
 904:	00000097          	auipc	ra,0x0
 908:	b9a080e7          	jalr	-1126(ra) # 49e <sbrk>
  if(p == (char*)-1)
 90c:	fd5518e3          	bne	a0,s5,8dc <malloc+0x7e>
        return 0;
 910:	4501                	li	a0,0
 912:	7902                	ld	s2,32(sp)
 914:	6a42                	ld	s4,16(sp)
 916:	6aa2                	ld	s5,8(sp)
 918:	6b02                	ld	s6,0(sp)
 91a:	a03d                	j	948 <malloc+0xea>
 91c:	7902                	ld	s2,32(sp)
 91e:	6a42                	ld	s4,16(sp)
 920:	6aa2                	ld	s5,8(sp)
 922:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 924:	fae489e3          	beq	s1,a4,8d6 <malloc+0x78>
        p->s.size -= nunits;
 928:	4137073b          	subw	a4,a4,s3
 92c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92e:	02071693          	slli	a3,a4,0x20
 932:	01c6d713          	srli	a4,a3,0x1c
 936:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 938:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 93c:	00001717          	auipc	a4,0x1
 940:	b0a73223          	sd	a0,-1276(a4) # 1440 <freep>
      return (void*)(p + 1);
 944:	01078513          	addi	a0,a5,16
  }
}
 948:	70e2                	ld	ra,56(sp)
 94a:	7442                	ld	s0,48(sp)
 94c:	74a2                	ld	s1,40(sp)
 94e:	69e2                	ld	s3,24(sp)
 950:	6121                	addi	sp,sp,64
 952:	8082                	ret
 954:	7902                	ld	s2,32(sp)
 956:	6a42                	ld	s4,16(sp)
 958:	6aa2                	ld	s5,8(sp)
 95a:	6b02                	ld	s6,0(sp)
 95c:	b7f5                	j	948 <malloc+0xea>
