//
//  PhotoUtils.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/15.
//

import Foundation
import SwiftUI

func resizeImageMaintainingAspectRatio(image: UIImage, newWidth: CGFloat) -> UIImage {
    let aspectRatio = image.size.height / image.size.width
    let newHeight = newWidth * aspectRatio
    
    let size = CGSize(width: newWidth, height: newHeight)
    let renderer = UIGraphicsImageRenderer(size: size)
    let newImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
    return newImage
}
