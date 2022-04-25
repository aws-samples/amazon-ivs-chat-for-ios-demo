//
//  LoginView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 08/09/2021.
//  

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: ViewModel
    @Binding var isPresent: Bool

    @State var newUser: User
    @State var isStartChattingButtonDisabled: Bool = true
    @State var showLoadingIndicator: Bool = false

    private let horizontalPadding: CGFloat = 16

    init(viewModel: StateObject<ViewModel>, isPresent: Binding<Bool>) {
        self._viewModel = viewModel
        self._isPresent = isPresent
        self.newUser = User(username: "")
    }

    private func dismissKeyboard() {
        UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.6)
                .onTapGesture {
                    isPresent.toggle()
                }

            VStack(alignment: .leading) {
                Text("Introduce yourself")
                    .font(Constants.fAppTitleBold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.horizontal, horizontalPadding)
                TextField("", text: $newUser.username)
                    .padding(.top, 20)
                    .padding(.horizontal, horizontalPadding)
                    .foregroundColor(.white)
                    .font(Constants.fAppRegular)
                    .placeholder(when: newUser.username.isEmpty) {
                        Text("Your name")
                            .padding(.top, 20)
                            .padding(.horizontal, horizontalPadding)
                            .foregroundColor(Color.gray)
                    }
                    .onChange(of: newUser.username, perform: { _ in
                        isStartChattingButtonDisabled = newUser.username.isEmpty
                    })
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                Divider()
                    .frame(height: 1)
                    .background(Constants.buttonDisabled)
                    .padding(.bottom, 20)
                    .padding(.horizontal, horizontalPadding)


                Text("Select avatar")
                    .font(Constants.fAppBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, horizontalPadding)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack() {
                        ForEach(Constants.userAvatarUrls, id: \.self) { url in
                            RemoteImageView(imageURL: url)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                .overlay(newUser.avatarUrl == url ? Circle().stroke(Color.black, lineWidth: 4) : nil)
                                .overlay(newUser.avatarUrl == url ? Circle().stroke(Constants.buttonPrimary, lineWidth: 2) : nil)
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    newUser.avatarUrl = url
                                }
                        }
                    }
                    .frame(maxHeight: 52)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, horizontalPadding)

                Text("Grant permissions")
                    .font(Constants.fAppBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, horizontalPadding)
                HStack {
                    Toggle("Moderation", isOn: $newUser.isModerator)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 16)

                Button(action: {
                    viewModel.user = newUser
                    dismissKeyboard()
                    showLoadingIndicator = true
                }, label: {
                    if showLoadingIndicator {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2, anchor: .center)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    } else {
                        Text("Start chatting")
                            .foregroundColor(Constants.background)
                            .font(Constants.fAppBold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(isStartChattingButtonDisabled ? Constants.buttonDisabled : Constants.buttonPrimary)
                            .cornerRadius(42)
                    }
                })
                    .padding(.bottom, 40)
                    .disabled(isStartChattingButtonDisabled)
                    .padding(.horizontal, horizontalPadding)
            }
            .background(Constants.background)
            .cornerRadius(20)
            .padding(.horizontal, horizontalPadding)
            .onTapGesture {
                dismissKeyboard()
            }
            .onChange(of: viewModel.isAuthorised) { isAuthorised in
                showLoadingIndicator = isAuthorised
                isPresent = !isAuthorised
            }
        }
    }
}
