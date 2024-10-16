APP = deskin
SERVER_HANDLER = kevreer
UTILITIES = dizolein

$(APP): $(SERVER_HANDLER).o $(UTILITIES).o
	ld -o $(APP) $(SERVER_HANDLER).o $(UTILITIES).o

$(SERVER_HANDLER).o: $(SERVER_HANDLER).asm 
	nasm -f elf $(SERVER_HANDLER).asm 

$(UTILITIES).o: $(UTILITIES).asm
	nasm -f elf $(UTILITIES).asm
