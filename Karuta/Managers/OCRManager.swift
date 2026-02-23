import CoreImage
import ImageIO
import UIKit
import Vision

enum OCRManager {
    static func recognizeText(from image: UIImage) -> String {
        let candidates = makeCandidateImages(from: image)
        var bestText = ""
        var bestScore: Double = 0

        for candidate in candidates {
            let (text, score) = recognize(in: candidate)
            if score > bestScore {
                bestScore = score
                bestText = text
            }
        }

        return bestText
    }

    private static func recognize(in image: UIImage) -> (String, Double) {
        guard let cgImage = image.cgImage else { return ("", 0) }

        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = ["ja-JP"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.015
        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return ("", 0)
        }

        let results = request.results as? [VNRecognizedTextObservation] ?? []
        var strings: [String] = []
        var confidenceSum: Float = 0
        var confidenceCount: Float = 0

        for observation in results {
            guard let candidate = observation.topCandidates(1).first else { continue }
            strings.append(candidate.string)
            confidenceSum += candidate.confidence
            confidenceCount += 1
        }

        let text = strings.joined(separator: " ")
        let averageConfidence = confidenceCount > 0 ? confidenceSum / confidenceCount : 0
        let score = Double(text.count) + Double(averageConfidence) * 10.0
        return (text, score)
    }

    private static func makeCandidateImages(from image: UIImage) -> [UIImage] {
        let normalized = normalize(image)
        let cropped = cropBorder(from: normalized, insetRatio: 0.06)
        let enhanced = enhance(cropped)

        let rotatedLeft = rotate(enhanced, radians: -.pi / 2)
        let rotatedRight = rotate(enhanced, radians: .pi / 2)
        return [enhanced, rotatedLeft, rotatedRight]
    }

    private static func normalize(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? image
    }

    private static func cropBorder(from image: UIImage, insetRatio: CGFloat) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let dx = width * insetRatio
        let dy = height * insetRatio
        let rect = CGRect(x: dx, y: dy, width: width - dx * 2, height: height - dy * 2)
        guard let cropped = cgImage.cropping(to: rect) else { return image }
        return UIImage(cgImage: cropped)
    }

    private static func enhance(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        let adjusted = ciImage
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: 1.35,
                kCIInputBrightnessKey: 0.08
            ])
            .applyingFilter("CISharpenLuminance", parameters: [
                kCIInputSharpnessKey: 0.8
            ])

        let context = CIContext()
        guard let output = context.createCGImage(adjusted, from: adjusted.extent) else { return image }
        return UIImage(cgImage: output)
    }

    private static func rotate(_ image: UIImage, radians: CGFloat) -> UIImage {
        let originalSize = image.size
        let rotatedSize = CGRect(origin: .zero, size: originalSize)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral
            .size

        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        image.draw(in: CGRect(
            x: -originalSize.width / 2,
            y: -originalSize.height / 2,
            width: originalSize.width,
            height: originalSize.height
        ))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage ?? image
    }
}
