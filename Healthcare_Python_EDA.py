"""
Healthcare Data Analysis - Python EDA Script
Project: Hospital Patient Analytics | Tool: Python (Pandas, Matplotlib, Seaborn)
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

# ── Color palette (teal/clinical theme) ───────────────────────────────────────
PALETTE = ['#028090', '#00A896', '#02C39A', '#F0F3BD', '#C8D5B9', '#065A82', '#1C7293']
plt.rcParams.update({'font.family': 'DejaVu Sans', 'axes.spines.top': False,
                     'axes.spines.right': False, 'figure.facecolor': 'white'})

df = pd.read_csv('/home/claude/patient_records.csv')
df['Admit_Date'] = pd.to_datetime(df['Admit_Date'])
df['Month'] = df['Admit_Date'].dt.to_period('M').astype(str)

print("=" * 60)
print("HEALTHCARE ANALYTICS - PYTHON EDA SUMMARY")
print("=" * 60)
print(f"\nDataset Shape: {df.shape}")
print(f"Date Range: {df['Admit_Date'].min().date()} → {df['Admit_Date'].max().date()}")
print(f"\nMissing Values:\n{df.isnull().sum()[df.isnull().sum()>0]}")
print(f"\nKey Stats:")
print(df[['Length_of_Stay_Days','Bill_Amount','Patient_Satisfaction_Score']].describe().round(2).to_string())

# ── Figure 1: Multi-panel EDA ─────────────────────────────────────────────────
fig = plt.figure(figsize=(20, 14))
fig.suptitle('Healthcare Analytics – Exploratory Data Analysis Dashboard', 
             fontsize=18, fontweight='bold', color='#065A82', y=0.98)
gs = gridspec.GridSpec(3, 3, figure=fig, hspace=0.45, wspace=0.35)

# 1) Admissions by month
ax1 = fig.add_subplot(gs[0, :2])
monthly = df.groupby('Month').size().reset_index(name='Admissions')
ax1.bar(range(len(monthly)), monthly['Admissions'], color='#028090', alpha=0.85, edgecolor='white')
ax1.set_xticks(range(len(monthly)))
ax1.set_xticklabels([m[-5:] for m in monthly['Month']], rotation=45, ha='right', fontsize=8)
ax1.set_title('Monthly Hospital Admissions (2023)', fontweight='bold', color='#065A82')
ax1.set_ylabel('Number of Patients')
ax1.axhline(monthly['Admissions'].mean(), color='#F96167', linestyle='--', linewidth=1.5, label='Avg')
ax1.legend()

# 2) Dept distribution
ax2 = fig.add_subplot(gs[0, 2])
dept_counts = df['Department'].value_counts()
colors_pie = ['#028090','#00A896','#02C39A','#065A82','#1C7293','#21295C','#0D9488']
wedges, texts, autotexts = ax2.pie(dept_counts, labels=None, autopct='%1.1f%%',
                                    colors=colors_pie[:len(dept_counts)], startangle=90,
                                    pctdistance=0.8)
for at in autotexts: at.set_fontsize(7)
ax2.set_title('Patients by Department', fontweight='bold', color='#065A82')
ax2.legend(dept_counts.index, loc='lower center', bbox_to_anchor=(0.5, -0.3),
           ncol=2, fontsize=7)

# 3) Avg Bill by Insurance
ax3 = fig.add_subplot(gs[1, 0])
ins_bill = df.groupby('Insurance_Type')['Bill_Amount'].mean().sort_values()
bars = ax3.barh(ins_bill.index, ins_bill.values, color=PALETTE[:5])
ax3.set_title('Avg Bill Amount by Insurance', fontweight='bold', color='#065A82')
ax3.set_xlabel('USD ($)')
for i, v in enumerate(ins_bill.values):
    ax3.text(v + 200, i, f'${v:,.0f}', va='center', fontsize=8)

# 4) Length of Stay distribution
ax4 = fig.add_subplot(gs[1, 1])
ax4.hist(df['Length_of_Stay_Days'], bins=30, color='#00A896', edgecolor='white', alpha=0.85)
ax4.set_title('Length of Stay Distribution', fontweight='bold', color='#065A82')
ax4.set_xlabel('Days')
ax4.set_ylabel('Count')
med = df['Length_of_Stay_Days'].median()
ax4.axvline(med, color='#F96167', linestyle='--', linewidth=2, label=f'Median: {med}d')
ax4.legend()

# 5) Satisfaction vs LOS scatter
ax5 = fig.add_subplot(gs[1, 2])
ax5.scatter(df['Length_of_Stay_Days'], df['Patient_Satisfaction_Score'],
            alpha=0.25, color='#028090', s=20)
z = np.polyfit(df['Length_of_Stay_Days'], df['Patient_Satisfaction_Score'], 1)
p = np.poly1d(z)
xline = np.linspace(1, df['Length_of_Stay_Days'].quantile(0.95), 100)
ax5.plot(xline, p(xline), 'r--', linewidth=2)
corr = df[['Length_of_Stay_Days','Patient_Satisfaction_Score']].corr().iloc[0,1]
ax5.set_title(f'Satisfaction vs LOS (r={corr:.2f})', fontweight='bold', color='#065A82')
ax5.set_xlabel('Length of Stay (Days)')
ax5.set_ylabel('Satisfaction Score')

# 6) Readmission rate by dept
ax6 = fig.add_subplot(gs[2, :2])
readmit = df.groupby('Department')['Readmitted_30Days'].mean().mul(100).sort_values(ascending=False)
colors_bar = ['#F96167' if v > 12 else '#028090' for v in readmit.values]
ax6.bar(readmit.index, readmit.values, color=colors_bar, edgecolor='white')
ax6.set_title('30-Day Readmission Rate by Department (%)', fontweight='bold', color='#065A82')
ax6.set_ylabel('Readmission Rate (%)')
ax6.axhline(readmit.mean(), color='#1C7293', linestyle='--', linewidth=1.5, label=f'Avg: {readmit.mean():.1f}%')
ax6.legend()
for i, v in enumerate(readmit.values):
    ax6.text(i, v + 0.2, f'{v:.1f}%', ha='center', fontsize=9)

# 7) Outcome breakdown
ax7 = fig.add_subplot(gs[2, 2])
oc = df['Outcome'].value_counts()
ax7.bar(oc.index, oc.values, color=PALETTE[:len(oc)], edgecolor='white')
ax7.set_title('Patient Outcomes', fontweight='bold', color='#065A82')
ax7.set_ylabel('Count')
ax7.tick_params(axis='x', rotation=20)

plt.savefig('/home/claude/eda_dashboard.png', dpi=150, bbox_inches='tight')
print("\nEDA chart saved: eda_dashboard.png")

# ── Figure 2: Financial deep-dive ─────────────────────────────────────────────
fig2, axes = plt.subplots(1, 3, figsize=(18, 5))
fig2.suptitle('Financial & Revenue Analysis', fontsize=16, fontweight='bold', color='#065A82')

# Revenue by hospital
hosp_rev = df.groupby('Hospital')['Bill_Amount'].sum() / 1e6
axes[0].barh(hosp_rev.index, hosp_rev.values, color='#028090')
axes[0].set_title('Total Revenue by Hospital ($ Millions)', fontweight='bold')
axes[0].set_xlabel('Revenue ($M)')
for i, v in enumerate(hosp_rev.values):
    axes[0].text(v + 0.05, i, f'${v:.1f}M', va='center', fontsize=9)

# Insurance coverage heatmap
cov = df.groupby(['Department','Insurance_Type'])['Insurance_Paid'].mean().unstack(fill_value=0)
sns.heatmap(cov / 1000, annot=True, fmt='.0f', cmap='Blues', ax=axes[1], linewidths=0.5)
axes[1].set_title('Avg Insurance Coverage by Dept ($K)', fontweight='bold')
axes[1].tick_params(axis='x', rotation=30)

# Cost per LOS bucket
df['LOS_Bucket'] = pd.cut(df['Length_of_Stay_Days'], bins=[0,3,7,14,30,200],
                           labels=['1-3d','4-7d','8-14d','15-30d','30+d'])
los_cost = df.groupby('LOS_Bucket', observed=True)['Bill_Amount'].mean()
axes[2].plot(los_cost.index.astype(str), los_cost.values, 'o-', color='#028090',
             linewidth=2.5, markersize=8)
axes[2].fill_between(range(len(los_cost)), los_cost.values, alpha=0.2, color='#028090')
axes[2].set_xticks(range(len(los_cost)))
axes[2].set_xticklabels(los_cost.index.astype(str))
axes[2].set_title('Avg Bill Amount by LOS Bucket', fontweight='bold')
axes[2].set_ylabel('Avg Bill ($)')
axes[2].yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f'${x:,.0f}'))
for ax in axes: ax.spines['top'].set_visible(False); ax.spines['right'].set_visible(False)

plt.tight_layout()
plt.savefig('/home/claude/financial_analysis.png', dpi=150, bbox_inches='tight')
print("Financial chart saved: financial_analysis.png")

# ── Print key KPIs ─────────────────────────────────────────────────────────────
print("\n── KEY KPIs ──────────────────────────────────────────")
print(f"Total Patients: {len(df):,}")
print(f"Total Revenue: ${df['Bill_Amount'].sum():,.0f}")
print(f"Avg Length of Stay: {df['Length_of_Stay_Days'].mean():.1f} days")
print(f"Overall Readmission Rate: {df['Readmitted_30Days'].mean()*100:.1f}%")
print(f"Avg Patient Satisfaction: {df['Patient_Satisfaction_Score'].mean():.1f}/10")
print(f"Highest Readmission Dept: {readmit.idxmax()} ({readmit.max():.1f}%)")
print(f"Lowest Satisfaction Dept: {df.groupby('Department')['Patient_Satisfaction_Score'].mean().idxmin()}")
