//
//  ContentView.swift
//  TextToImage
//
//  Created by Ethan Key on 8/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var descriptionText: String = ""
    @State private var generatedImage: UIImage?
    @State private var isFetching: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter description here", text: $descriptionText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Generate Image") {
                    guard !descriptionText.isEmpty else { return }  // This return is outside the view builder, so it's okay.
                    isFetching = true
                    generatedImage = UIImage(named: "placeholder")  // Set placeholder when button is pressed.
                    NetworkManager.shared.fetchImageFromText(description: descriptionText) { image, error in
                        DispatchQueue.main.async {
                            isFetching = false
                            if let image = image {
                                self.generatedImage = image
                            } else {
                                print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
                                self.generatedImage = UIImage(named: "errorImage")  // Set error image if fetch fails.
                            }
                        }
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(isFetching ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(isFetching)


                if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .padding()
                }
            }
            .navigationBarTitle("Image Generator")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
