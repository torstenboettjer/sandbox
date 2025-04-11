{ pkgs, ... }:
{
    home.packages = with pkgs; [
      captive-browser
    ];

    home.file.".local/share/applications/captive-browser.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Captive Browser
      GenericName=Web Browser
      Comment=Captive Browser
      Categories=Network;WebBrowser;Security;
      Exec=${pkgs.captive-browser}/bin/captive-browser
      StartupWMClass=Captive Browser
    '';

    xdg.configFile."captive-browser.toml".text = ''
      # browser is the shell (/bin/sh) command executed once the proxy starts.
      # When browser exits, the proxy exits. An extra env var PROXY is available.
      #
      # Here, we use a separate Chrome instance in Incognito mode, so that
      # it can run (and be waited for) alongside the default one, and that
      # it maintains no state across runs. To configure this browser open a
      # normal window in it, settings will be preserved.

      browser = """
          ${pkgs.chromium}/bin/chromium \
          --user-data-dir="$HOME/.config/captive-browser" \
          --enable-features="ClearCrossSiteCrossBrowsingContextGroupWindowName,EnableDrDc,HttpsOnlyMode,PdfUnseasoned,SplitCacheByNetworkIsolationKey,StrictOriginIsolation,StrictExtensionIsolation,WebRtcHideLocalIpsWithMdns,OmniboxUpdatedConnectionSecurityIndicators,OverlayScrollbar,ThrottleDisplayNoneAndVisibilityHiddenCrossOriginIframes,UseOzonePlatform,WebRTCPipeWireCapturer,ReaderMode:discoverability/offer-in-settings,IncognitoClearBrowsingDataDialogForDesktop,DisableQuickAnswersV2Translation" \
          --disable-features="AutofillAddressProfileSavePrompt,AutofillAlwaysReturnCloudTokenizedCard,AutofillCreditCardAuthentication,AutofillCreditCardUploadFeedback,AutofillEnableMerchantBoundVirtualCards,AutofillEnableOfferNotification,AutofillEnableOfferNotificationCrossTabTracking,AutofillParseMerchantPromoCodeFields,AutofillSaveAndFillVPA,AutofillShowTypePredictions,AutofillSuggestVirtualCardsOnIncompleteForm,AutofillUpstream,SyncAutofillWalletOfferData,SyncTrustedVaultPassphrasePromo,SyncTrustedVaultPassphraseRecovery,SyncTrustedVaultPassphrasePromo,SyncTrustedVaultPassphraseRecovery,SecurePaymentConfirmationSyncTrustedVaultPassphrasePromo,SyncAutofillWalletOfferData,WebPaymentsExperimentalFeatures',FontAccess,GenericSensorExtraClasses,HappinessTrackingSurveysForDesktopDemo,LensRegionSearch,LiteVideo,MediaEngagementBypassAutoplayPolicies,NavigationPredictor,NetworkTimeServiceQuerying,NtpModules,OptimizationGuideModelDownloading,PreloadMediaEngagementData,ServiceWorkerSubresourceFilter,TabHoverCardImages,WebBundles" \
          --ozone-platform=wayland \
          --enable-potentially-annoying-security-features \
          --enable-strict-mixed-content-checking \
          --enable-strict-powerful-feature-restrictions \
          --site-per-process \
          --disable-gpu \
          --disable-remote-fonts \
          --disable-3d-apis \
          --disable-accelerated-2d-canvas \
          --disable-accelerated-video-decode \
          --disable-file-system \
          --disable-notifications \
          --disable-speech \
          --disable-speech-api \
          --disable-reading-from-canvas \
          --disable-background-networking \
          --disable-auto-reload \
          --disable-media-session-api \
          --disable-webgl \
          --disable-webgl2 \
          --disable-webrtc-hw-encoding \
          --disable-webrtc-hw-decoding \
          --no-pings \
          --no-crash-upload \
          --no-report-upload \
          --no-vr-runtime \
          --no-wifi \
          --force-prefers-reduced-motion \
          --force-dark-mode \
          --disable-software-video-decoders \
          --disable-dinosaur-easter-egg \
          --disable-file-manager-touch-mode \
          --no-default-browser-check \
          --no-first-run \
          --disable-network-portal-notification \
          --disable-client-side-phishing-detection \
          --disable-client-side-phishing-protection \
          --disable-default-apps \
          --disable-gaia-services \
          --disable-sync \
          --disable-sync-preferences \
          --disable-sync-types \
          --allow-browser-signin=false \
          --disable-device-discovery-notifications \
          --disable-domain-reliability \
          --disable-fonts-googleapis-references \
          --disable-field-trial-config \
          --disable-translate \
          --disable-touch-adjustment \
          --disable-wake-on-wifi \
          --disable-offer-upload-credit-cards \
          --disable-breakpad \
          --disable-crash-reporter \
          --disable-field-trial-config \
          --data-reduction-proxy-server-experiments-disabled \
          --lang=en-US \
          --disable-ntp-popular-sites \
          --disable-offer-store-unmasked-wallet-cards \
          --disable-office-editing-component-extension \
          --disable-fine-grained-time-zone-detection \
          --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36" \
          --window-size=1200,800 \
          --no-first-run --no-default-browser-check --new-window --incognito \
          --proxy-server="socks5://$PROXY" \
          http://www.msftconnecttest.com/connecttest.txt
      """

      # dhcp-dns is the shell (/bin/sh) command executed to obtain the DHCP
      # DNS server address. The first match of an IPv4 regex is used.
      # IPv4 only, because let's be real, it's a captive portal.
      #
      # `wlp3s0` is your network interface (eth0, wlan0 ...)
      #
      #dhcp-dns = "nmcli dev show wlp170s0 | grep IP4.DNS"
      #dhcp-dns = "nmcli dev show wlp170s0 | awk '/IP4.DNS\\[1\\]:/{print $2}'"
      #dhcp-dns = "nmcli --terse --get-values IP4.DNS device show wlp170s0"
      dhcp-dns = "nmcli --terse --get-values IP4.DNS device show $(nmcli --terse device | awk -F':' '/.:wifi:./{ print $1 }')"
      #dhcp-dns = "echo 1.1.1.1"
      #dhcp-dns = "resolvectl dns | grep wlp170s0"

      # socks5-addr is the listen address for the SOCKS5 proxy server.
      socks5-addr = "127.0.0.1:1666"
    '';
}
