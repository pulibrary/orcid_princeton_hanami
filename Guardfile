# frozen_string_literal: true

# Ignore nix/devbox/postgres working dirs (listen/guard patterns)
ignore %r{^/nix/store/}
ignore %r{^\./nix/store/}
ignore %r{^\.devbox/}
ignore %r{^\./\.devbox/}
ignore %r{^\.postgres/}
ignore %r{^\./\.postgres/}
ignore %r{^\.tmp/}
ignore %r{^\./\.tmp/}

group :server do
  guard "puma", port: ENV.fetch("HANAMI_PORT", 2300) do
    watch(%r{^(app|config|lib|slices)(/[^/]+)*\.(rb|erb|haml|slim)$}i)
  end
end

