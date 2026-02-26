#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/timer.h>
#include <linux/jiffies.h>

MODULE_LICENSE("MIT");
MODULE_AUTHOR("Yocto");
MODULE_DESCRIPTION("Simulated LED kernel module with timer");
MODULE_VERSION("1.0");

/* Timer structure */
static struct timer_list led_timer;

/* LED state: 0 = off, 1 = on */
static int led_state = 0;

/* Timer interval in milliseconds (default: 1000ms = 1 second) */
static int timer_interval = 1000;
module_param(timer_interval, int, 0644);
MODULE_PARM_DESC(timer_interval, "Timer interval in milliseconds (default: 1000)");

/* Timer callback function */
static void led_timer_callback(struct timer_list *t)
{
    /* Toggle LED state */
    led_state = !led_state;
    
    /* Print LED status */
    if (led_state) {
        printk(KERN_INFO "LED on\n");
    } else {
        printk(KERN_INFO "LED off\n");
    }
    
    /* Restart the timer */
    mod_timer(&led_timer, jiffies + msecs_to_jiffies(timer_interval));
}

static int __init simulated_led_init(void)
{
    printk(KERN_INFO "Simulated LED module loaded\n");
    printk(KERN_INFO "Timer interval: %d ms\n", timer_interval);
    
    /* Initialize the timer */
    timer_setup(&led_timer, led_timer_callback, 0);
    
    /* Start the timer */
    mod_timer(&led_timer, jiffies + msecs_to_jiffies(timer_interval));
    
    return 0;
}

static void __exit simulated_led_exit(void)
{
    /* Delete the timer */
    del_timer_sync(&led_timer);
    
    printk(KERN_INFO "Simulated LED module unloaded\n");
}

module_init(simulated_led_init);
module_exit(simulated_led_exit);
