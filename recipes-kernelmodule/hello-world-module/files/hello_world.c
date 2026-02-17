#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("MIT");
MODULE_AUTHOR("Yocto");
MODULE_DESCRIPTION("Simple hello world kernel module");
MODULE_VERSION("1.0");

static int __init hello_world_init(void)
{
    printk(KERN_INFO "Hello World from kernel module!\n");
    return 0;
}

static void __exit hello_world_exit(void)
{
    printk(KERN_INFO "Goodbye from kernel module!\n");
}

module_init(hello_world_init);
module_exit(hello_world_exit);
