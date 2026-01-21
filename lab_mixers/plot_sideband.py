import matplotlib.pyplot as plt
import numpy as np

def draw_spectral_block(ax, center_freq, width, box_height, 
                        spike_offsets, spike_heights, 
                        label, label_y_offset=0.2, color='black', 
                        mirror=False):
    """
    Helper function to draw a spectral band (box + spikes).
    
    Parameters:
    - ax: The matplotlib axis.
    - center_freq: Center frequency of the block.
    - width: Width of the rectangular base.
    - box_height: Height of the rectangular base.
    - spike_offsets: List of frequency offsets for spikes relative to center.
    - spike_heights: List of heights for the spikes.
    - mirror: If True, flips the spike pattern horizontally (for mixer images).
    """
    
    # 1. Draw the Box (Outline only)
    # Left, Top, Right lines
    left = center_freq - width / 2
    right = center_freq + width / 2
    
    ax.hlines(box_height, left, right, colors=color, linewidth=0.8)
    ax.vlines(left, 0, box_height, colors=color, linewidth=0.8)
    ax.vlines(right, 0, box_height, colors=color, linewidth=0.8)
    
    # 2. Draw Spikes
    real_offsets = np.array(spike_offsets)
    real_heights = np.array(spike_heights)
    
    if mirror:
        # Flip offsets to mirror the shape across the center frequency
        real_offsets = -real_offsets
    
    for off, h in zip(real_offsets, real_heights):
        x = center_freq + off
        # Draw line from top of box to spike height
        ax.plot([x, x], [box_height, h], color=color, linewidth=1.2)
    
    # 3. Add Label
    if label:
        ax.text(center_freq, max(spike_heights) + label_y_offset, label, 
                ha='center', va='bottom', fontweight='bold', fontsize=10)

def setup_axis(ax, title):
    """Configures axis limits, ticks, and titles to match the style."""
    ax.set_xlim(-2800, 2800)
    ax.set_ylim(0, 2.1)
    
    # Title
    ax.set_title(title, fontweight='bold', fontsize=11)
    
    # X-axis formatting
    ax.set_xlabel("Freq", fontweight='bold', fontsize=9)
    ax.tick_params(direction='in', which='both', top=True, right=True)
    ax.minorticks_on()
    
    # Center Dotted Line
    ax.axvline(0, color='gray', linestyle=':', linewidth=1.5)
    
    # Horizontal line at 0
    ax.axhline(0, color='black', linewidth=0.8)

# --- Signal Definitions ---

# LO Frequency
LO_FREQ = 1000

# USB Definition (at RF)
# Relative to LO, let's say it's centered at +250
USB_OFFSET = 300 
USB_WIDTH = 250
USB_BOX_H = 0.8
# Spikes: Short, Medium, Tall (Ascending freq)
USB_SPIKE_OFFS = [-80, 0, 80]
USB_SPIKE_H = [1.0, 1.2, 1.4]

# LSB Definition (at RF)
# Relative to LO, let's say it's centered at -250
LSB_OFFSET = -300
LSB_WIDTH = 250
LSB_BOX_H = 0.3
# Spikes: Tall, Short (Ascending freq)
LSB_SPIKE_OFFS = [-60, 60]
LSB_SPIKE_H = [0.7, 0.5]


# --- Plotting ---

fig, axes = plt.subplots(5, 1,
                         figsize=(8, 12),
                         constrained_layout=True,
                         sharex=True)

# Panel 1: RF Spectrum
ax = axes[0]
setup_axis(ax, "RF Spectrum")

# Draw LO
ax.annotate("", xy=(LO_FREQ, 1.8), xytext=(LO_FREQ, 0), arrowprops=dict(arrowstyle="->", color="black"))
ax.text(LO_FREQ, 1.9, "LO", ha='center', fontweight='bold')

# Draw USB at RF
draw_spectral_block(ax, LO_FREQ + USB_OFFSET, USB_WIDTH, USB_BOX_H, 
                    USB_SPIKE_OFFS, USB_SPIKE_H, "USB")

# Draw LSB at RF
draw_spectral_block(ax, LO_FREQ + LSB_OFFSET, LSB_WIDTH, LSB_BOX_H, 
                    LSB_SPIKE_OFFS, LSB_SPIKE_H, "LSB")


# Panel 2: DSB Mixer Output for ONLY the USB
# Real Mixing: Signal appears at +Offset and -Offset.
# The negative frequency image is mirrored.
ax = axes[1]
setup_axis(ax, "DSB mixer output for ONLY the USB")

# Positive Side (Original shape preserved)
draw_spectral_block(ax, USB_OFFSET, USB_WIDTH, USB_BOX_H, 
                    USB_SPIKE_OFFS, USB_SPIKE_H, "USB")
# Negative Side (Mirrored)
draw_spectral_block(ax, -USB_OFFSET, USB_WIDTH, USB_BOX_H, 
                    USB_SPIKE_OFFS, USB_SPIKE_H, "USB", mirror=True)


# Panel 3: DSB Mixer Output for ONLY the LSB
ax = axes[2]
setup_axis(ax, "DSB mixer output for ONLY the LSB")

# Positive Side (Original shape preserved in terms of absolute bandwidth order)
# Note: LSB was below LO. When mixed (RF-LO), it lands at negative freq. 
# The image freq lands at positive. 
# Visually in the image: Positive side matches RF LSB shape (Tall, Short).
draw_spectral_block(ax, abs(LSB_OFFSET), LSB_WIDTH, LSB_BOX_H, 
                    LSB_SPIKE_OFFS, LSB_SPIKE_H, "LSB")
# Negative Side (Mirrored)
draw_spectral_block(ax, -abs(LSB_OFFSET), LSB_WIDTH, LSB_BOX_H, 
                    LSB_SPIKE_OFFS, LSB_SPIKE_H, "LSB", mirror=True)


# Panel 4: DSB Mixer Output for BOTH LSB and USB
# Superposition of Panel 2 and 3.
# The boxes stack because they occupy the same baseband bandwidth.
ax = axes[3]
setup_axis(ax, "DSB mixer output for BOTH LSB and USB")

# Calculate stacked heights
combined_box_h = USB_BOX_H + LSB_BOX_H

# Positive Side Stack
# Draw the combined box outline
draw_spectral_block(ax, abs(USB_OFFSET), USB_WIDTH, combined_box_h, 
                    [], [], None) # Empty lists = just draw box
# Draw USB spikes (on top of the combined box? No, image shows them extending from their respective "contributions")
# Actually, the image shows the spikes sticking out of a single tall box.
# We will draw the spikes relative to the combined floor or just overlay them.
# Let's draw the USB spikes normally, but shifted up by LSB height? 
# Or just draw them both. The image implies summation. 
# To make it look like the image, we draw both sets of spikes on the combined box.
# Re-using the function is tricky for stacking, so we manually call it for spikes.

# Draw the Box
left = abs(USB_OFFSET) - USB_WIDTH/2
right = abs(USB_OFFSET) + USB_WIDTH/2
ax.hlines(combined_box_h, left, right, linewidth=0.8)
ax.vlines(left, 0, combined_box_h, linewidth=0.8)
ax.vlines(right, 0, combined_box_h, linewidth=0.8)

# Draw Positive Spikes (USB + LSB)
# USB Spikes
for off, h in zip(USB_SPIKE_OFFS, USB_SPIKE_H):
    x = abs(USB_OFFSET) + off
    # We add LSB_BOX_H to the visual base of the spike to represent stacking energy
    ax.plot([x, x], [combined_box_h, h + LSB_BOX_H], color='black')

# LSB Spikes
for off, h in zip(LSB_SPIKE_OFFS, LSB_SPIKE_H):
    x = abs(LSB_OFFSET) + off
    ax.plot([x, x], [combined_box_h, h + USB_BOX_H], color='black')

ax.text(abs(USB_OFFSET), max(USB_SPIKE_H) + LSB_BOX_H + 0.2, "LSB+USB", 
        ha='center', fontweight='bold')


# Negative Side Stack (Mirrored)
left = -abs(USB_OFFSET) - USB_WIDTH/2
right = -abs(USB_OFFSET) + USB_WIDTH/2
ax.hlines(combined_box_h, left, right, linewidth=0.8)
ax.vlines(left, 0, combined_box_h, linewidth=0.8)
ax.vlines(right, 0, combined_box_h, linewidth=0.8)

# Draw Negative Spikes (Mirrored)
# USB Spikes (Mirrored)
for off, h in zip(USB_SPIKE_OFFS, USB_SPIKE_H):
    x = -abs(USB_OFFSET) - off # Mirror offset
    ax.plot([x, x], [combined_box_h, h + LSB_BOX_H], color='black')

# LSB Spikes (Mirrored)
for off, h in zip(LSB_SPIKE_OFFS, LSB_SPIKE_H):
    x = -abs(LSB_OFFSET) - off # Mirror offset
    ax.plot([x, x], [combined_box_h, h + USB_BOX_H], color='black')

ax.text(-abs(USB_OFFSET), max(USB_SPIKE_H) + LSB_BOX_H + 0.2, "LSB+USB", 
        ha='center', fontweight='bold')


# Panel 5: SSB Mixer Output
# Complex Mixing: Shifts the spectrum to the left by LO.
# LSB (originally at LO - 300) -> Moves to -300.
# USB (originally at LO + 300) -> Moves to +300.
# No mirroring occurs, just translation.
ax = axes[4]
setup_axis(ax, "SSB mixer output")

# USB (shifted to +300)
draw_spectral_block(ax, USB_OFFSET, USB_WIDTH, USB_BOX_H, 
                    USB_SPIKE_OFFS, USB_SPIKE_H, "USB")

# LSB (shifted to -300)
draw_spectral_block(ax, LSB_OFFSET, LSB_WIDTH, LSB_BOX_H, 
                    LSB_SPIKE_OFFS, LSB_SPIKE_H, "LSB")

# Adjust layout and save
# Remove x-labels from top 4 plots
for i in range(5):
    if i < 4:
        axes[i].set_xlabel("")
    axes[i].set_ylabel("Power")
    axes[i].set_xlim(-500, 1500)

plt.show()
