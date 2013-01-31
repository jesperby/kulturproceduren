(function($) {
    $(function() {
        $("textarea.wysiwyg").tinymce({
            script_url: "/javascripts/tiny_mce/tiny_mce.js",
            content_css: "http://www.malmo.se/assets-2.0/css/external-core.css,/stylesheets/tinymce-content.css",
            language: "sv",

            theme: "advanced",
            theme_advanced_buttons1: "bold,italic,underline,strikethrough,|,bullist,numlist,|,link,unlink,|,formatselect",
            theme_advanced_blockformats: "p,h1,h2,h3,h4,h5,h6,blockquote",
            theme_advanced_path: false,

            valid_elements: "a[href|target|title],b,strong,i,em,span[style],p,ul,ol,li,h1,h2,h3,h4,h5,h6,blockquote"
        });
    });
})(jQuery);
