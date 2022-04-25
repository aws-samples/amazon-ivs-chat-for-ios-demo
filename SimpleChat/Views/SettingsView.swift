//
//  SettingsView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 15/09/2021.
//  

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var isPresent: Bool

    @State private var playbackUrl: String
    @State private var useCustomStreamUrl: Bool
    @State private var isValid: Bool = true

    private var isPlaybackUrlValid: Bool {
        let isValid = playbackUrl.lowercased().starts(with: "https://") &&
            playbackUrl.lowercased().split(separator: ".").last == "m3u8"
        return useCustomStreamUrl ? isValid : true
    }

    init(viewModel: ViewModel, isPresent: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresent = isPresent
        self.useCustomStreamUrl = viewModel.useCustomStreamUrl
        self.playbackUrl = viewModel.customPlaybackUrl
    }

    @ViewBuilder private func topBar() -> some View {
        HStack {
            Button("Cancel") {
                isPresent.toggle()
            }
            .foregroundColor(.white)
            Spacer()
            Text("Settings")
                .foregroundColor(.white)
                .font(Constants.fAppTitleRegular)
                .padding(.leading, -16)
            Spacer()
            Button("Save") {
                viewModel.useCustomStreamUrl = useCustomStreamUrl
                viewModel.customPlaybackUrl = playbackUrl
                isPresent.toggle()
            }
            .font(Constants.fAppTitleBold)
            .foregroundColor(Constants.buttonPrimary)
            .opacity(isPlaybackUrlValid ? 1 : 0.3)
            .disabled(!isPlaybackUrlValid)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Constants.backgroundSettings.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                topBar()
                    .padding(.horizontal, 16)

                HStack {
                    Text("Custom live stream")
                        .foregroundColor(.white)
                        .font(Constants.fAppTitleRegular)
                        .padding(.horizontal, 16)
                    Spacer()
                    Toggle("", isOn: $useCustomStreamUrl)
                        .padding(.horizontal, 16)
                }
                .frame(height: 44)
                .background(Constants.backgroundInput)
                .onTapGesture {
                    useCustomStreamUrl.toggle()
                }

                if useCustomStreamUrl {
                    TextField("", text: $playbackUrl)
                        .foregroundColor(isValid ? .white : Constants.appRed)
                        .placeholder(when: playbackUrl.isEmpty) {
                            Text("Paste your Payback URL")
                                .foregroundColor(.gray)
                        }
                        .frame(height: 44)
                        .modifier(ClearButton(text: $playbackUrl))
                        .padding(.horizontal, 16)
                        .background(Constants.backgroundInput)
                        .onChange(of: playbackUrl, perform: { _ in
                            isValid = isPlaybackUrlValid
                        })

                    if !isValid {
                        Text("Invalid Playback URL")
                            .foregroundColor(Constants.appRed)
                            .font(Constants.fAppSmall)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }

                } else {
                    Text("Use your own custom Amazon IVS stream in this demo")
                        .foregroundColor(.gray)
                        .font(Constants.fAppSmall)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }

                if viewModel.user != nil {
                    Button("Log out") {
                        viewModel.user = nil
                        isPresent = false
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Constants.backgroundInput)
                    .foregroundColor(Constants.appRed)
                    .padding(.vertical, 20)
                }
            }
        }
        .onTapGesture {
            UIApplication.shared
                .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
