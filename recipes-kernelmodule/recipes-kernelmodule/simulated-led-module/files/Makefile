obj-m += simulated_led.o

all:
	make -C $(KERNEL_SRC) M=$(PWD) modules

clean:
	make -C $(KERNEL_SRC) M=$(PWD) clean

install:
	make -C $(KERNEL_SRC) M=$(PWD) modules_install INSTALL_MOD_PATH=$(INSTALL_MOD_PATH)
