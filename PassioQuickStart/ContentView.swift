import SwiftUI
import PassioNutritionAISDK

struct ContentView: View {
    @StateObject private var viewModel = FoodScannerViewModel()
    @State private var isShowingScanner = false
    @State private var activeTab = 0
    
    var body: some View {
        TabView(selection: $activeTab) {
            // Camera Scanner Tab
            NavigationView {
                VStack {
                    if let currentScan = viewModel.currentScan {
                        if let image = currentScan.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                        Text("Recognized: \(currentScan.name)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: FoodDetailView(foodItem: currentScan)) {
                            Text("View Details")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.green)
                                .cornerRadius(10)
                                .padding()
                        }
                    } else {
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Scan food to get started")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    Spacer()
                    
                    if !viewModel.scannedFoods.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Scans")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.scannedFoods) { food in
                                        NavigationLink(destination: FoodDetailView(foodItem: food)) {
                                            VStack {
                                                if let image = food.image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                } else {
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                        .padding(20)
                                                        .background(Color.gray.opacity(0.2))
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
                                                
                                                Text(food.name)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                                    .frame(width: 100)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 150)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 2)
                        .padding()
                    }
                    
                    Button(action: {
                        isShowingScanner = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Scan Food")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                .navigationTitle("Passio Food Scanner")
                .sheet(isPresented: $isShowingScanner) {
                    FoodScannerView(viewModel: viewModel)
                        .onDisappear {
                            isShowingScanner = false
                        }
                }
            }
            .tabItem {
                Label("Camera", systemImage: "camera")
            }
            .tag(0)
            
            // Image Recognition Tab
            NavigationView {
                ImageRecognitionView()
            }
            .tabItem {
                Label("Gallery", systemImage: "photo")
            }
            .tag(1)
            
            // History Tab (placeholder for now)
            NavigationView {
                List {
                    ForEach(viewModel.scannedFoods) { food in
                        NavigationLink(destination: FoodDetailView(foodItem: food)) {
                            FoodListCellView(foodItem: food, showConfidence: false)
                        }
                    }
                }
                .navigationTitle("History")
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
            .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 