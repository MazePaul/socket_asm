# Deskin
*I don't know what it really is. At the beginning it was a simple unix socket implementation in x_86. But now, it looks
like a server responding to client commands. For this project, I've tried to write clean asm.*

## Wanna try?
**To compile source code:**
```bash
nasm -f elf64 dizolein.asm && nasm -f elf64 kevreer.asm && ld dizolein.o kevreer.o -o deskin
```

**To connect a client:**
```bash
nc 127.0.0.1 34676
```

**Commands**

Once you've connected to the server, you can type into the client:
```bash
read
```

## Check it by yourself

```bash
netstat -tlnp
```

**you might see something like:**

```bash
tcp        0      0 127.0.0.16:34676        0.0.0.0:*               LISTEN      48591/./nasm
```

**Go check your file descriptor:**
```bash
ls -la /proc/$(pidof nasm)/fd
```
