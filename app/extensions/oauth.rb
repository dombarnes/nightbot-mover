class OAuth
  User = Struct.new(
    :_id,
    :name,
    :displayName,
    :provider,
    :providerId,
    :avatar,
    :admin
  )
end
