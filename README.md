# Socket
*It's a simple (yet broken, wip) unix socket implementation. This time I've tried to write clean asm. I still have a lot
to learn.*

## Wanna try?
**To compile source code:**
```sh
nasm -felf64 nasm.asm && ld nasm.o -o nasm
```

**To connect a client:**

```sh
nc 127.0.0.1 34676
```

## Check it by yourself

```sh
netstat -tlnp
```

**you might see something like:**

```sh
tcp        0      0 127.0.0.16:34676        0.0.0.0:*               LISTEN      48591/./nasm
```

**Go check your file descriptor:**
```sh
ls -la /proc/$(pidof nasm)/fd
```