# frozen_string_literal: true

require_relative "base"

module Powerpoint
  module GoogleServices
    class Presentation < Base
      attr_accessor :presentation_id
      attr_reader :template_name

      METADATA_STRUCTURE = {
        intro: [],
        textual: [],
        picture: [],
        bullet: [],
      }
      BULLET_GLYPH = [
        "BULLET_DISC_CIRCLE_SQUARE",
        "BULLET_DIAMONDX_ARROW3D_SQUARE",
        "BULLET_CHECKBOX",
        "BULLET_ARROW_DIAMOND_DISC",
        "BULLET_STAR_CIRCLE_SQUARE",
        "BULLET_ARROW3D_CIRCLE_SQUARE",
        "BULLET_LEFTTRIANGLE_DIAMOND_DISC",
        "BULLET_DIAMONDX_HOLLOWDIAMOND_SQUARE",
        "BULLET_DIAMOND_CIRCLE_SQUARE",
        "NUMBERED_UPPERALPHA_ALPHA_ROMAN",
      ]
      PER_REQUEST = 10
      MAX_ATTEMPTS = 5

      def initialize(template_name = "")
        super()

        @template_name = template_name
      end

      def presentation(reload: false)
        return @presentation if @presentation && !reload

        create_presentation! unless presentation_id

        presentation_source = slides.get_presentation(presentation_id)

        @presentation = {
          data: presentation_source,
          metadata: map_template(presentation_source),
        }
      end

      def duplicate_slide(object_id_prop, index)
        new_slide_id_prop = "COPY_#{object_id_prop}#{index}"

        duplicate_request = Google::Apis::SlidesV1::DuplicateObjectRequest.new(
          object_id_prop:,
          object_ids: { object_id_prop => new_slide_id_prop },
        )

        batch_update!([Google::Apis::SlidesV1::Request.new(duplicate_object: duplicate_request)])

        presentation(reload: true)

        new_slide_id_prop
      end

      def update_bullet_style(shape_id, bullet_content)
        requests = []

        requests << Google::Apis::SlidesV1::Request.new(
          delete_text: Google::Apis::SlidesV1::DeleteTextRequest.new(
            object_id_prop: shape_id,
            text_range: { type: "ALL" },
          ),
        )

        requests << Google::Apis::SlidesV1::Request.new(
          insert_text: Google::Apis::SlidesV1::InsertTextRequest.new(
            object_id_prop: shape_id,
            insertion_index: 0,
            text: bullet_content,
          ),
        )

        requests << Google::Apis::SlidesV1::Request.new(
          create_paragraph_bullets: Google::Apis::SlidesV1::CreateParagraphBulletsRequest.new(
            object_id_prop: shape_id,
            text_range: { type: "ALL" },
            bullet_preset: BULLET_GLYPH.sample,
          ),
        )
      end

      def replace_all_text(prefix:, field:, content:, object_id_prop:)
        raise "The field #{field} is invalid" unless ["title", "content", "subtitle"].include?(field)

        base_request = Google::Apis::SlidesV1::ReplaceAllTextRequest.new(
          contains_text: { text: "{{#{prefix}_#{field}}}" },
          replace_text: content,
          page_object_ids: [object_id_prop],
        )

        Google::Apis::SlidesV1::Request.new(replace_all_text: base_request)
      end

      def update_slides_position(object_id_prop:, index:)
        raise "The index #{index} is invalid" if index.negative?
        raise "The object_id_prop #{object_id_prop} is invalid" if object_id_prop.empty?

        base_request = Google::Apis::SlidesV1::UpdateSlidesPositionRequest.new(
          slide_object_ids: [object_id_prop],
          insertion_index: index,
        )

        Google::Apis::SlidesV1::Request.new(
          update_slides_position: base_request,
        )
      end

      def remove_unused_slides!
        requests = []

        presentation[:data].slides.each do |slide|
          next if slide.object_id_prop.include?("COPY_")

          requests << Google::Apis::SlidesV1::Request.new(
            delete_object: Google::Apis::SlidesV1::DeleteObjectRequest.new(object_id_prop: slide.object_id_prop),
          )
        end

        if requests.empty?
          return
        end

        batch_update!(requests)
      end

      def save_presentation!(requests)
        requests.each_slice(PER_REQUEST) do |request_chunk|
          attempts = 0

          loop do
            break if attempts >= MAX_ATTEMPTS

            begin
              batch_update!(request_chunk)

              break
            rescue Google::Apis::ClientError => e
              raise e if attempts >= MAX_ATTEMPTS

              sleep(timeout(attempts))

              attempts += 1
            end
          end
        end
      end

      def delete_presentation!
        drive.delete_file(presentation_id)
      end

      def export_presentation(output)
        export = drive.export_file(
          presentation_id,
          "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        )

        File.open(output, "wb") { |file| file.write(export) }

        output
      end

      private

      def batch_update!(requests)
        batch_update_request = Google::Apis::SlidesV1::BatchUpdatePresentationRequest.new(requests:)

        slides.batch_update_presentation(
          presentation_id,
          batch_update_request,
        )
      end

      def create_presentation!
        presentation_metadata = {
          name: "presentation_#{Time.now.to_i}_#{rand(1000)}",
          mime_type: "application/vnd.google-apps.presentation",
        }

        drive_file = drive.copy_file(base_template.id, presentation_metadata)
        self.presentation_id = drive_file.id

        drive_file
      end

      def base_template
        return @base_template if @base_template

        @base_template = Powerpoint::GoogleServices::Template.get_template(template_name:)
      end

      def map_template(presentation_source)
        presentation_source.slides.each_with_object(METADATA_STRUCTURE) do |slide, structure|
          structure.keys.each do |key|
            next unless slide.to_json.include?("#{key}_")

            structure[key] << slide
          end
        end
      end

      def timeout(attempts)
        base = (5..15).to_a.sample

        base * (attempts + 1)
      end
    end
  end
end
