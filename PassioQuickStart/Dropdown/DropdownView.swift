import SwiftUI

struct DropdownView<T: Identifiable & CustomStringConvertible>: View {
    @Binding var isOpen: Bool
    @Binding var selectedOption: T?
    var options: [T]
    var onOptionSelected: ((T) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dropdown header
            Button(action: {
                withAnimation {
                    isOpen.toggle()
                }
            }) {
                HStack {
                    Text(selectedOption?.description ?? "Select an option")
                        .foregroundColor(selectedOption == nil ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Dropdown options
            if isOpen {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(options) { option in
                            Button(action: {
                                selectedOption = option
                                onOptionSelected?(option)
                                withAnimation {
                                    isOpen = false
                                }
                            }) {
                                HStack {
                                    Text(option.description)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedOption?.id as? AnyHashable == option.id as? AnyHashable {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    selectedOption?.id as? AnyHashable == option.id as? AnyHashable ?
                                    Color.blue.opacity(0.1) : Color(.systemBackground)
                                )
                            }
                            
                            if option.id as? AnyHashable != options.last?.id as? AnyHashable {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .frame(height: min(CGFloat(options.count) * 44, 220))
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 5)
                .zIndex(1)
            }
        }
    }
}

// A simple dropdown option model for use with the dropdown
struct DropdownOption: Identifiable, CustomStringConvertible {
    var id = UUID()
    var value: String
    
    var description: String {
        return value
    }
}

// Example usage
struct DropdownExample: View {
    @State private var isDropdownOpen = false
    @State private var selectedOption: DropdownOption?
    
    let options = [
        DropdownOption(value: "Option 1"),
        DropdownOption(value: "Option 2"),
        DropdownOption(value: "Option 3"),
        DropdownOption(value: "Option 4"),
        DropdownOption(value: "Option 5")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dropdown Example")
                .font(.headline)
            
            DropdownView(
                isOpen: $isDropdownOpen,
                selectedOption: $selectedOption,
                options: options
            )
            .frame(maxWidth: .infinity)
            
            if let selected = selectedOption {
                Text("Selected: \(selected.value)")
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Dropdown")
    }
}

struct DropdownView_Previews: PreviewProvider {
    static var previews: some View {
        DropdownExample()
    }
} 