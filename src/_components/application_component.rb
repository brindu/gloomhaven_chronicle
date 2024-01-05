class ApplicationComponent < Bridgetown::Component
  def site
    @site ||= Bridgetown::Current.site
  end
end
