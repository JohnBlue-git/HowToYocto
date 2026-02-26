# Simulated LED Kernel Module

A kernel module recipe for Yocto that simulates LED blinking using a Linux kernel timer. The module periodically toggles an LED state and prints "LED on" or "LED off" messages to the kernel log.

## Overview

This recipe creates a kernel module that:
- Uses a Linux kernel timer to simulate LED blinking
- Toggles LED state (on/off) at configurable intervals
- Prints "LED on" or "LED off" to kernel log (viewable via `dmesg`)
- Auto-loads at system boot time
- Supports runtime configuration via module parameter

## Features

### Timer-based LED Simulation
- **Periodic Execution**: Uses `timer_list` and `mod_timer()` to execute periodically
- **State Toggle**: Alternates between LED on and LED off states
- **Configurable Interval**: Default 1 second (1000ms), adjustable via module parameter

### Module Parameter
- **`timer_interval`**: Control the blinking speed (in milliseconds)
- **Default**: 1000ms (1 second)
- **Runtime Configurable**: Can be changed without reloading the module
- **Permission**: 0644 (readable by all, writable by root)

## Files

```
simulated-led-module/
├── simulated-led-module.bb    # BitBake recipe
├── README.md                  # This documentation
└── files/
    ├── simulated_led.c        # Kernel module source code
    └── Makefile               # Build instructions
```

## Installation Location

The compiled kernel module is installed at:
```
/lib/modules/<kernel-version>/updates/simulated_led.ko
```

For example:
```
/lib/modules/6.6.111-yocto-standard/updates/simulated_led.ko
```

## Technical Implementation

### Kernel Timer Mechanism

The module uses the Linux kernel timer API:

```c
struct timer_list led_timer;  // Timer structure

// Initialize timer with callback function
timer_setup(&led_timer, led_timer_callback, 0);

// Start/restart timer
mod_timer(&led_timer, jiffies + msecs_to_jiffies(timer_interval));

// Cleanup timer
del_timer_sync(&led_timer);
```

### Timer Callback Function

```c
static void led_timer_callback(struct timer_list *t)
{
    led_state = !led_state;  // Toggle state
    
    if (led_state) {
        printk(KERN_INFO "LED on\n");
    } else {
        printk(KERN_INFO "LED off\n");
    }
    
    // Reschedule timer for next execution
    mod_timer(&led_timer, jiffies + msecs_to_jiffies(timer_interval));
}
```

### Key Concepts

1. **`timer_setup()`**: Initializes a timer with a callback function (kernel 4.15+)
2. **`mod_timer()`**: Starts or modifies a timer to expire at a specific time
3. **`jiffies`**: Kernel's time counter (ticks since boot)
4. **`msecs_to_jiffies()`**: Converts milliseconds to jiffies
5. **`del_timer_sync()`**: Safely removes timer before module unload

## Usage

### Load the Module

The module auto-loads at boot. To manually load:
```bash
modprobe simulated_led
```

### View LED Messages

```bash
# View kernel messages
dmesg | tail -20

# Watch in real-time
dmesg -w

# Filter for LED messages
dmesg | grep LED
```

Expected output:
```
[  123.456789] Simulated LED module loaded
[  123.456790] Timer interval: 1000 ms
[  124.456791] LED on
[  125.456792] LED off
[  126.456793] LED on
[  127.456794] LED off
...
```

### Configure Timer Interval

#### At Module Load Time

```bash
# Load with 500ms interval (faster blinking)
modprobe simulated_led timer_interval=500

# Load with 2000ms interval (slower blinking)
modprobe simulated_led timer_interval=2000
```

#### At Runtime

```bash
# Change to 250ms interval (very fast blinking)
echo 250 > /sys/module/simulated_led/parameters/timer_interval

# Change to 3000ms interval (slow blinking)
echo 3000 > /sys/module/simulated_led/parameters/timer_interval
```

**Note**: Runtime changes take effect on the next timer cycle.

#### View Current Interval

```bash
cat /sys/module/simulated_led/parameters/timer_interval
```

### Unload the Module

```bash
modprobe -r simulated_led
# or
rmmod simulated_led
```

### Module Information

```bash
# View module details
modinfo simulated_led

# Check if module is loaded
lsmod | grep simulated_led

# View module parameters
ls -l /sys/module/simulated_led/parameters/
cat /sys/module/simulated_led/parameters/timer_interval
```

## Auto-Load Configuration

The recipe includes `KERNEL_MODULE_AUTOLOAD += "simulated_led"` which automatically:
- Creates `/etc/modules-load.d/simulated_led.conf` with the module name
- Ensures the module loads at system startup
- Uses the default timer interval (1000ms) unless configured otherwise

### Configure Default Timer Interval at Boot

To set a different default interval at boot, create or modify:

```bash
# /etc/modprobe.d/simulated_led.conf
options simulated_led timer_interval=500
```

Then the module will load with 500ms interval at every boot.

## Building

### Add to Your Image

Edit your image recipe (e.g., `johnblue-image.bb`):

```bitbake
IMAGE_INSTALL:append = " \
    simulated-led-module \
"
```

### Build the Module

```bash
# Build only the module
bitbake simulated-led-module

# Build the entire image with the module
bitbake johnblue-image
```

### Development Build

```bash
# Clean and rebuild
bitbake simulated-led-module -c clean
bitbake simulated-led-module
```

## Debugging

### Check Module Load Status

```bash
# Check if module loaded successfully
dmesg | grep "Simulated LED"

# Check module info
lsmod | grep simulated_led
```

### Common Issues

#### Module Not Auto-Loading

Check if auto-load configuration was created:
```bash
cat /etc/modules-load.d/simulated_led.conf
```

Should contain:
```
simulated_led
```

#### Timer Not Firing

Check kernel log for errors:
```bash
dmesg | grep -i error
dmesg | grep simulated_led
```

#### Module Load Fails

```bash
# Check for dependency issues
modprobe -v simulated_led

# Check kernel version compatibility
uname -r
ls /lib/modules/$(uname -r)/updates/
```

## Development Notes

### Timer Best Practices

1. **Always use `del_timer_sync()`**: Ensures timer is fully stopped before module unload
2. **Reschedule in callback**: Use `mod_timer()` in callback for periodic execution
3. **Use `jiffies` for timing**: Kernel's standard time reference
4. **Convert time units**: Use `msecs_to_jiffies()` for milliseconds

### Potential Enhancements

1. **GPIO Control**: Extend to control actual GPIO pins
2. **sysfs Interface**: Add sysfs entries for LED state readback
3. **Multiple LEDs**: Support multiple simulated LEDs
4. **Pattern Control**: Support different blinking patterns (pulse, fade, etc.)
5. **Frequency Control**: Add frequency/duty cycle parameters

## Comparison with hello-world-module

| Feature | hello-world-module | simulated-led-module |
|---------|-------------------|---------------------|
| Complexity | Simple init/exit | Timer + state machine |
| Execution | One-time (init/exit) | Periodic (timer-based) |
| Output | Static messages | Dynamic state changes |
| Parameters | None | Configurable interval |
| Use Case | Learning basics | Simulating hardware |
| Timer Usage | No | Yes (kernel timer) |

## License

MIT License

## References

- [Linux Kernel Timer Documentation](https://www.kernel.org/doc/html/latest/timers/timers-howto.html)
- [Yocto Kernel Module Development](https://docs.yoctoproject.org/kernel-dev/common.html)
- [Linux Device Drivers (Chapter 7: Time)](https://lwn.net/Kernel/LDD3/)
