from pathlib import Path
import kagglehub

project_root = Path(__file__).resolve().parents[1]
raw_data_directory = project_root / "data" / "raw"

raw_data_directory.mkdir(parents=True, exist_ok=True)

dataset_path = kagglehub.dataset_download(
    "olistbr/brazilian-ecommerce",
    output_dir=str(raw_data_directory)
)

print(f"Dataset downloaded to: {dataset_path}")