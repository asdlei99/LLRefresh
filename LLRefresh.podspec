Pod::Spec.new do |s|
  s.name         = "LLRefresh"
  s.version      = "0.0.5"
  s.summary      = "One line of code sets the pull-up to refresh and load more based on MJRefresh."
  s.description  = <<-DESC
  					一行代码设置iOS TableView 或者 CollectionView下拉刷新上拉加载
                   DESC
  s.homepage     = "https://github.com/kevll/LLRefresh"
  s.license      = "MIT"
  s.author             = { "kevll" => "kevliule@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/kevll/LLRefresh.git", :tag => "#{s.version}" }
  s.source_files  = "LLRefresh/*.{h,m}"
  s.requires_arc = true
  s.dependency "MJRefresh"

end
