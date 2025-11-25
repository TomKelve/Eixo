import numpy as np
import torch
from timm import create_model
from torchvision import transforms
from torchvision.transforms import functional as F
from torchvision.models import mobilenet_v3_small, MobileNet_V3_Small_Weights

BR_ALIASES = {
    "rice": "arroz branco",
    "beans": "feijão carioca",
    "grilled_chicken": "frango grelhado",
    "beef": "carne bovina grelhada",
    "salad": "salada",
    "pasta": "macarrão",
    "egg": "ovo",
}


def map_to_br(label_en: str) -> str:
    normalized = label_en.lower().replace(" ", "_")
    return BR_ALIASES.get(normalized, label_en)


class ClassifierService:
    def __init__(self):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        try:
            weights = MobileNet_V3_Small_Weights.IMAGENET1K_V1
            self.model = mobilenet_v3_small(weights=weights)
            self.transform = weights.transforms()
            self.classes = weights.meta.get("categories", [])
        except Exception:
            self.model = create_model("efficientnet_b0", pretrained=True)
            self.model.eval()
            self.transform = transforms.Compose(
                [
                    transforms.ToPILImage(),
                    transforms.Resize(256),
                    transforms.CenterCrop(224),
                    transforms.ToTensor(),
                    transforms.Normalize(
                        mean=[0.485, 0.456, 0.406],
                        std=[0.229, 0.224, 0.225],
                    ),
                ]
            )
            self.classes = []

        self.model.to(self.device)
        self.model.eval()

    def predict_topk(self, crop_rgb: np.ndarray, k: int = 3):
        pil_image = F.to_pil_image(crop_rgb)
        image_tensor = self.transform(pil_image).unsqueeze(0).to(self.device)
        with torch.no_grad():
            logits = self.model(image_tensor)
            probs = torch.softmax(logits, dim=1)
            topk_probs, topk_indices = torch.topk(probs, k=min(k, probs.shape[1]))

        results = []
        for prob, idx in zip(topk_probs[0].cpu().numpy(), topk_indices[0].cpu().numpy()):
            if self.classes:
                label = self.classes[idx]
            else:
                label = f"class_{idx}"
            results.append((label, float(prob)))
        return results
