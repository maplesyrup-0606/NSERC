import json
import os

def convert_to_coco_format(ref_path, pred_path, out_dir, clip_scores_path=None):
    with open(ref_path, "r") as f:
        ref_file = json.load(f)
    with open(pred_path, "r") as f:
        pred_file = json.load(f)

    clip_scores = None 
    if clip_scores_path :
        with open(clip_scores_path, "r") as f:
            clip_scores = json.load(f)

    os.makedirs(out_dir, exist_ok=True)
    
    variant = os.path.basename(pred_path).split("_captions")[0]
    out_ref_file = os.path.join(out_dir, f"captions_gt.json")
    out_pred_file = os.path.join(out_dir, f"captions_{variant}.json")

    annotations = []
    images = []
    predictions = []

    ann_id = 0
    for img_id_str, ref_captions in ref_file.items():
        img_id = int(img_id_str)
        images.append({ "id": img_id })

        for caption in ref_captions:
            annotations.append({
                "image_id": img_id,
                "id": ann_id,
                "caption": caption.strip()
            })
            ann_id += 1

    ann_id = 0
    for img_id_str, pred_captions in pred_file.items():
        img_id = int(img_id_str)

        if isinstance(pred_captions, list):
            if clip_scores:
                scores = clip_scores.get(img_id_str, {}).get("all", [])
                if scores and len(scores) == len(pred_captions):
                    best_idx = scores.index(max(scores))
                    caption = pred_captions[best_idx]
                else:
                    caption = pred_captions[0]
            else:
                caption = pred_captions[0]
        else:
            caption = pred_captions

        predictions.append({
            "image_id": img_id,
            "caption": caption.strip()
        })


    with open(out_ref_file, "w") as f:
        json.dump({
            "type": "captions",
            "info": {
                "description": "Generated by Mercury's caption conversion tool"
            },
            "licenses" : [],
            "images": images,
            "annotations": annotations
        }, f, indent=2)

    with open(out_pred_file, "w") as f:
        json.dump(predictions, f, indent=2)

    print("✅ COCO-format files created:")
    print(f" - References:  {out_ref_file}")
    print(f" - Predictions: {out_pred_file}")

if __name__ == "__main__" :
    import os

    ref_path = os.path.expanduser("~/NSERC/samples/may26_samples/sampled_captions_1000.json")
    out_dir = os.path.expanduser("~/NSERC/samples/may26_samples/coco_json_format")
    
    pred_path = os.path.expanduser("~/NSERC/samples/may26_samples/answered_captions_wordcap.json")
    clip_path = os.path.expanduser("~/NSERC/samples/may26_samples/metrics/clip/unguided_wordcap_clip.json")
    convert_to_coco_format(ref_path, pred_path, out_dir, clip_path)
    pred_path = os.path.expanduser("~/NSERC/samples/may26_samples/guided_answered_captions_wordcap.json")
    clip_path = os.path.expanduser("~/NSERC/samples/may26_samples/metrics/clip/guided_wordcap_clip.json")
    convert_to_coco_format(ref_path, pred_path, out_dir, clip_path)
    pred_path = os.path.expanduser("~/NSERC/samples/may26_samples/gaussian_answered_captions_wordcap.json")
    clip_path = os.path.expanduser("~/NSERC/samples/may26_samples/metrics/clip/guassian_wordcap_clip.json")
    convert_to_coco_format(ref_path, pred_path, out_dir, clip_path)
