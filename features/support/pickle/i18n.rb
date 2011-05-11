# -*- coding: utf-8 -*-
module Pickle::I18n
  class << self
    def model_translations
      @model_translations ||= {}
    end

    def model_attribute_translations
      @model_attribute_translations ||= {}
    end

    def translate(pickle_config, locale)
      # pickle_config.factories の中身はこんな感じ
      #   {"product"=>#<Pickle::Adapter::FactoryGirl:0x00000102b0b618 @klass=Product(id: integer, name: string, price: decimal, created_at: datetime, updated_at: datetime), @name="product">}
      # モデルの日本語名についてもfactoryを設定します
      # pickle_config.factories['商品'] = pickle_config.factories['product']
      I18n.t(:activemodel, :locale => locale).tap do |translations|
        model_translations.update(translations[:models].stringify_keys.invert)
        translations[:attributes].each do |model_name, attrs|
          model_attribute_translations[model_name.to_s] = attrs.stringify_keys.invert
        end
      end
      model_translations.each do |key, value|
        pickle_config.factories[key] = pickle_config.factories[value]
      end
    end

  end
end


Pickle::Session.module_eval do

  def create_model_with_i18n_attribute_names(orig_pickle_ref, orig_fields = nil)
    pickle_ref = Pickle::I18n.model_translations[orig_pickle_ref] || orig_pickle_ref
    raise ArgumentError, "No model_translation found: #{orig_pickle_ref}" unless orig_pickle_ref

    if attr_trans = Pickle::I18n.model_attribute_translations[pickle_ref]
      case orig_fields
      when String then
        fields = orig_fields.dup
        attr_trans.each{|k,v| fields.gsub!(k, v)}
      when Hash then
        fields = orig_fields.inject({}){|d, (k, v)| d[ attr_trans[k] || k ] = v; d }
      else
        raise "Unsupported fields: #{fields.inspect}"
      end
    end
    fields ||= orig_fields

    create_model_without_i18n_attribute_names(pickle_ref, fields)
  end

  unless instance_methods.include?(:create_model_without_i18n_attribute_names)
    alias_method :create_model_without_i18n_attribute_names, :create_model
    alias_method :create_model, :create_model_with_i18n_attribute_names
  end
end


Pickle::Parser.module_eval do
  def match_field
    # "(?:\\w+: #{match_value})"
    "(?:\s*[^:]+: #{match_value})"
  end

  def capture_key_and_value_in_field
    # "(?:(\\w+): #{capture_value})"
    "(?:\s*([^:]+): #{capture_value})"
  end
end
