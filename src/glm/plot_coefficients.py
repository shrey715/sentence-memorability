import matplotlib.pyplot as plt
import numpy as np
import os

# Set backend to Agg for headless environments
plt.switch_backend('Agg')

def main():
    # Fixed values and improved aesthetics as requested by the user
    # Order: HH, HL, LH (matches the "threshold drop" story)
    conditions = ['HH', 'HL', 'LH']
    betas = [0.0549, 0.0533, 0.0493]
    ses   = [0.0196, 0.0195, 0.0194]
    pvals = ['p = .005', 'p = .006', 'p = .011']

    ci_lo = [b - 1.96*se for b, se in zip(betas, ses)]
    ci_hi = [b + 1.96*se for b, se in zip(betas, ses)]

    fig, ax = plt.subplots(figsize=(5, 2.8))

    # Reference line at 0 (= LL reference)
    ax.axvline(0, color='#E53935', linestyle='--', linewidth=1.5, zorder=1)
    
    # Shaded region highlights the significant positive effect vs LL
    # Tracks the upper bounds of the CIs
    ax.axvspan(0, max(ci_hi) + 0.005, alpha=0.07, color='#1565C0', zorder=0)

    for i, (cond, b, lo, hi, p) in enumerate(zip(conditions, betas, ci_lo, ci_hi, pvals)):
        # Plot CI whisker
        ax.plot([lo, hi], [i, i], color='#1565C0', linewidth=2.2, zorder=2)
        # Plot point estimate
        ax.plot(b, i, 'o', color='#1565C0', markersize=8, zorder=3)
        # Add p-value next to the CI
        ax.text(hi + 0.002, i, p, va='center', fontsize=9, color='#1565C0')

    # Y-axis labels (HH, HL, LH)
    ax.set_yticks(range(3))
    ax.set_yticklabels(conditions, fontsize=12, fontweight='bold')
    
    # X-axis label
    ax.set_xlabel('β vs. LL  (HC3 robust, 95% CI)', fontsize=9.5)
    
    # Title
    ax.set_title('GLM: Corrected IR  |  ref = LL\ncontrolling for trial position',
                 fontsize=10.5, fontweight='bold', pad=8)

    # Tighten axes to eliminate dead space and focus on the findings
    ax.set_xlim(-0.01, 0.115)
    ax.set_ylim(-0.6, 2.6)
    
    # Aesthetics: Despine
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    # Annotate the LL reference line directly
    ax.text(0.001, -0.55, 'LL (β = 0)', color='#E53935', fontsize=8)

    plt.tight_layout()
    
    # Output path
    output_path = 'outputs/glm/glm_corrected_ir.png'
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"Successfully generated final fixed coefficient plot at: {output_path}")

if __name__ == "__main__":
    main()
