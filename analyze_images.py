#!/usr/bin/env python3
import os
from PIL import Image
import glob

def analyze_image(path):
    try:
        img = Image.open(path)
        width, height = img.size
        mode = img.mode
        format = img.format
        # 获取一些像素样本
        pixels = list(img.getdata())
        # 计算平均颜色
        if len(pixels) > 0:
            avg_color = tuple(sum(c) // len(c) for c in zip(*pixels[:10000]))
        else:
            avg_color = None
        return {
            'path': os.path.basename(path),
            'width': width,
            'height': height,
            'mode': mode,
            'format': format,
            'avg_color': avg_color,
            'size_kb': os.path.getsize(path) // 1024
        }
    except Exception as e:
        return {'path': path, 'error': str(e)}

def main():
    folder = './cankao'
    images = glob.glob(os.path.join(folder, '*.jpg'))
    print(f"找到 {len(images)} 张图片")
    for img_path in images:
        info = analyze_image(img_path)
        print(f"\n{info['path']}:")
        if 'error' in info:
            print(f"  错误: {info['error']}")
        else:
            print(f"  尺寸: {info['width']}x{info['height']}")
            print(f"  格式: {info['format']}, 模式: {info['mode']}")
            print(f"  文件大小: {info['size_kb']} KB")
            if info['avg_color']:
                print(f"  平均颜色 (RGB): {info['avg_color']}")
        # 尝试检测是否为截图：检查是否包含大量白色或标准UI颜色
        # 简单检查：如果平均颜色接近白色，可能是背景
        if 'avg_color' in info and info['avg_color']:
            r,g,b = info['avg_color']
            if r > 200 and g > 200 and b > 200:
                print("  可能包含浅色背景")

if __name__ == '__main__':
    main()