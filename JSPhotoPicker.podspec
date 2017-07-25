Pod::Spec.new do |s|

s.name         = "JSPhotoPicker"
s.version      = "0.0.6"
s.summary      = "图片选择器"
s.description  = <<-DESC
                    image picker
                    DESC
s.homepage     = "https://github.com/J-yezi/JSPhotoPicker"
s.license      = "MIT"
s.author             = { "J-yezi" => "yehao1020@gmail.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/J-yezi/JSPhotoPicker.git", :tag => s.version }
s.source_files  = "JSPhotoPicker/**/*.swift"
s.resource_bundles = {
    'JSPhotoPicker' => ["JSPhotoPicker/**/*.png"]
}
s.frameworks = "UIKit", "Foundation", "Photos"
s.requires_arc = true

end
