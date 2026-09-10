# frozen_string_literal: true

module React
  module ServerRendering
    # Shakapacker fingerprints packs under a js/ subdirectory, so the bundle has to be
    # located through the manifest rather than by joining the raw output path.
    class ShakapackerManifestContainer
      def find_asset(filename)
        path = ::URI.parse(::Shakapacker.manifest.lookup!(filename)).path
        ::File.read(::Rails.public_path.join(path.delete_prefix('/')))
      end
    end
  end
end

Rails.application.config.after_initialize do
  React::ServerRendering::BundleRenderer.asset_container_class =
    React::ServerRendering::ShakapackerManifestContainer
end
