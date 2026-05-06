import matplotlib.pyplot as plt
import numpy as np
import os

# Set backend to Agg for headless environments
plt.switch_backend('Agg')

def main():
    # Data provided by the user (validated against descriptive statistics)
    conditions = ['HH', 'HL', 'LH', 'LL']
    means = [0.689, 0.691, 0.679, 0.632]
    
    # Premium colors: Blue for reference conditions, Red for the unique LL drop
    colors = ['#3498db', '#3498db', '#3498db', '#e74c3c'] 
    
    fig, ax = plt.subplots(figsize=(5, 4))
    
    # Create bars with slight rounded appearance/premium feel
    bars = ax.bar(conditions, means, color=colors, width=0.6, 
                  edgecolor='white', linewidth=1.2, alpha=0.9)
    
    # Set Y limits to emphasize the relative difference (threshold effect)
    ax.set_ylim(0.58, 0.72)
    
    # Add reference line for the LL mean to highlight the gap
    ll_mean = 0.632
    ax.axhline(y=ll_mean, color='#e74c3c', linestyle='--', linewidth=1, alpha=0.4)
    
    # Labels and Title
    ax.set_ylabel("Mean Corrected Interaction Rate (IR)", fontsize=10, fontweight='500')
    ax.set_xlabel("Noun Condition", fontsize=10, fontweight='500')
    ax.set_title("Corrected IR by Noun Condition", fontsize=12, fontweight='bold', pad=20)
    
    # Annotate the unique drop in LL
    # Placing it clearly above the LL bar
    ax.text(3, 0.645, 'p < .001\nvs. all', ha='center', va='bottom', fontsize=9, 
            color='#e74c3c', fontweight='bold')

    # Grid for easier value estimation
    ax.grid(axis='y', linestyle=':', alpha=0.3)
    ax.set_axisbelow(True)
    
    # Clean up spines
    for spine in ['top', 'right']:
        ax.spines[spine].set_visible(False)
    
    # Add exact values on top of bars for precision
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.002,
                f'{height:.3f}', ha='center', va='bottom', fontsize=8, alpha=0.7)

    plt.tight_layout()
    
    # Output path
    output_path = "outputs/glm/corrected_ir_bar.png"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"Successfully generated bar chart at: {output_path}")

if __name__ == "__main__":
    main()
