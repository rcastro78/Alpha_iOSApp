import Foundation
import WebKit

final class PDFGenerator: NSObject {

    static let shared = PDFGenerator()

    private var continuation: CheckedContinuation<Data, Error>?
    private var webView: WKWebView?

    func generate(from html: String) async throws -> Data {

        try await withCheckedThrowingContinuation { continuation in

            self.continuation = continuation

            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 595, height: 842))
            webView.navigationDelegate = self

            self.webView = webView

            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}

extension PDFGenerator: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        Task {

            do {

                let config = WKPDFConfiguration()

                let pdf = try await webView.pdf(configuration: config)

                continuation?.resume(returning: pdf)

            } catch {

                continuation?.resume(throwing: error)
            }

            continuation = nil
            self.webView = nil
        }
    }
}

private extension WKWebView {

    func pdf(configuration: WKPDFConfiguration) async throws -> Data {

        try await withCheckedThrowingContinuation { continuation in

            createPDF(configuration: configuration) { result in

                continuation.resume(with: result)
            }
        }
    }
}