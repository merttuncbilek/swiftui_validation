//
//  ContentView.swift
//  SwiftUI_Validation
//
//  Created by Mert TUNÇBİLEK (Dijital Kanallar Uygulama Geliştirme Müdürlüğü) on 16.12.2023.
//

import SwiftUI

struct ContentView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var name: String = ""
    @State var surname: String = ""
    @State var agreement: Bool = false
    @State var selectedCity: String = "Choose City"
    let cityList = ["Choose City", "İstanbul", "Bursa", "Ankara"]
    
    @State var isPageValid: Bool = false
    
    var body: some View {
        TextFormView {   isValid in
            VStack {
                TextField("Email", text: $email)
                    .validate {
                        let value = email.count > 6 && email.contains("@")
                        print("Email validation checked -> \(value)")
                        isPageValid = value
                        return value
                    }
                TextField("Name", text: $name)
                    .validate {
                        let value = name.count > 3
                        print("Name validation checked -> \(value)")
                        return value
                    }
                TextField("Surname", text: $surname)
                    .validate {
                        let value = surname.count > 3
                        print("Surname validation checked -> \(value)")
                        return value
                    }
                SecureField("Password", text: $password)
                    .validate {
                        let value = password.count > 8
                        print("Password validation checked -> \(value)")
                        return value
                    }
                Toggle("Accept Agreement", isOn: $agreement)
                    .validate {
                        return agreement
                    }
                Picker("Select City", selection: $selectedCity) {
                    ForEach(cityList, id: \.self) {
                        Text($0)
                    }
                }
                .validate {
                    return selectedCity != "Choose City"
                }
                Spacer().frame(height: 300)
                Button {} label: {
                    Text("Sign Up")
                        .padding(.all)
                        .background(.red.opacity(isPageValid ? 1.0 : 0.5))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
}

///We created a ValidationPreferenceKey that adopted PreferenceKey. Check the Documentation for detailed explanation. The main purpose of this preferenceKey is, collecting all child views' validation values in a single Bool array. So we can check if all editable fields are valid or not.s
struct ValidationPreferenceKey: PreferenceKey {
    static var defaultValue = [Bool]()

    static func reduce(value: inout [Bool], nextValue: () -> [Bool]) {
        value += nextValue()
    }
}

///We create a ValidationModifier that adopted ViewModifier protocol. Check the documentation for detailed explanation for using and adopting ViewModifiers.
struct ValidationModifier: ViewModifier {
    let validation: () -> Bool
    func body(content: Content) -> some View {
        content.preference(key: ValidationPreferenceKey.self,
                           value: [validation()])
    }
}

protocol Validatable {
    associatedtype ValidatableView: View
    func validate(_ flag: @escaping () -> Bool) -> ValidatableView
}

extension Validatable where Self: View {
    func validate(_ flag: @escaping () -> Bool) -> some View {
        self.modifier(ValidationModifier(validation: flag))
    }
}

extension Picker: Validatable {}

extension Toggle: Validatable {}

extension TextField: Validatable {}

extension SecureField: Validatable {}

///We need to define a custom view that can check all it's child views validity.
struct TextFormView<Content: View>: View {
    ///Collect all child views' validation states that are coming from PreferenceKey in this array.
    @State var validationSeeds = [Bool]()
    ///This must be defined for CustomView. We defined our customView body content that returns Bool value which indicates validation of child views.
    @ViewBuilder var content: (() -> Bool) -> Content
    
    var body: some View {
        content {
            print("View Rendered.")
            ///The Validation check is working for all state updates.
            return !validationSeeds.contains(false)
        }.onPreferenceChange(ValidationPreferenceKey.self) { value in
            ///Sets the latest preference value from PreferenceKey.
            validationSeeds = value
        }
    }
    
}

#Preview {
    ContentView()
}
